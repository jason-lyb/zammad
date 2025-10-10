class App.Search extends App.Controller
  @extend App.PopoverProvidable
  @extend App.TicketMassUpdatable

  @ticketSearchColumns: [ 'number', 'title', 'customer', 'group', 'owner', 'created_at' ]

  elements:
    '.js-search': 'searchInput'
    '.js-date-from': 'dateFromInput'  # 추가
    '.js-date-to': 'dateToInput'      # 추가
    '.js-owner-select': 'ownerSelect' # 추가

  events:
    'click .js-emptySearch': 'empty'
    'submit form.search-holder': 'preventDefault'
    'keyup .js-search': 'listNavigate'
    'click .js-tab': 'showTab'
    'input .js-search': 'updateFilledClass'
    'click .js-page': 'paginate'
    'click .js-sort': 'sortByColumn'
    'change .js-date-from': 'onDateChange'  # 추가
    'change .js-date-to': 'onDateChange'    # 추가
    'change .js-owner-select': 'onOwnerChange' # 추가

  @include App.ValidUsersForTicketSelectionMethods

  constructor: ->
    super

    @savedOrderBy    = {}
    @resultPaginated = {}
    @result          = {}
    @queue           = {}

    current = App.TaskManager.get(@taskKey).state
    if current && current.query
      @query = current.query

    # 날짜 기본값 설정
    @dateFrom = current?.dateFrom || @getTodayString()
    @dateTo = current?.dateTo || @getTodayString()
    @ownerId = current?.ownerId || ''  # 담당자 ID 추가

    # update taskbar with new meta data
    App.TaskManager.touch(@taskKey)

    @globalSearch = new App.GlobalSearch(
      render: @renderResult
      limit: 50
    )

    @render()

    # rerender view, e. g. on langauge change
    @controllerBind('ui:rerender', =>
      @render()
    )

    load = (data) =>
      App.Collection.loadAssets(data.assets)
      @formMeta = data.form_meta
      console.log 'formMeta loaded from TicketOverviewCollection:', @formMeta
      # formMeta가 로드되면 다시 렌더링
      if @formMeta
        @render()
    @bindId = App.TicketOverviewCollection.bind(load)
    
    # 500ms 후에 formMeta 확인하고 없으면 직접 로드
    setTimeout(=>
      @loadFormMeta()
    , 500)

  # formMeta 직접 로드 (ticket_create와 동일한 방식)
  loadFormMeta: =>
    if @formMeta && @formMeta.dependencies && @formMeta.dependencies.group_id
      console.log 'formMeta already loaded and valid, skipping'
      return
    
    console.log 'Loading formMeta from ticket_create API...'
    @ajax(
      type: 'GET'
      url: "#{@apiPath}/ticket_create"
      processData: true
      success: (data) =>
        App.Collection.loadAssets(data.assets)
        @formMeta = data.form_meta
        console.log 'formMeta loaded from ticket_create API:', @formMeta
        # formMeta 로드 후 다시 렌더링
        @render()
      error: (xhr, status, error) =>
        console.log 'Failed to load formMeta:', error
    )

  release: =>
    App.TicketOverviewCollection.unbindById(@bindId)

  meta: =>
    title = @query || App.i18n.translateInline('Extended Search')

    meta =
      url:   @url()
      id:    ''
      head:  title
      title: title
      iconClass: 'searchdetail'
    meta

  url: ->
    '#search'

  show: (params) =>
    if @table
      @table.show()

    @navupdate(url: '#search', type: 'menu')

    if !_.isEmpty(params.query) # When opening detailed search from the global search
      @$('.js-search').val(params.query).trigger('keyup')
    else if @query # When coming back to detailed search taskbar from another taskbar
      @reloadCurrentSearch()

  hide: ->
    if @table
      @table.hide()

  reloadCurrentSearch: =>
    if !_.isEmpty(@getSavedOrderBy())
      modelsToLoad = _.keys(@savedOrderBy)
      modelsToLoad = _.without(modelsToLoad, @model)
      modelsToLoad.push('all')

      @queue = { query: @query, models: modelsToLoad }

      @goToPaginated(@model, @getSavedOrderBy().page)
    else
      modelsToLoad = _.keys(@savedOrderBy)

      @queue = { query: @query, models: modelsToLoad }

      @search(-1, true)

  changed: ->
    # nothing

  # 오늘 날짜를 YYYY-MM-DD 형식으로 반환하는 헬퍼 메서드
  getTodayString: ->
    today = new Date()
    year = today.getFullYear()
    month = String(today.getMonth() + 1).padStart(2, '0')
    day = String(today.getDate()).padStart(2, '0')
    "#{year}-#{month}-#{day}"

  render: ->
    console.log 'render() called'
    currentState = App.TaskManager.get(@taskKey).state
    if !@query
      if currentState && currentState.query
        @query = currentState.query

    if !@model
      if currentState && currentState.model
        @model = currentState.model
      else
        @model = 'Ticket'

    # 날짜 기본값 설정
    @dateFrom = current?.dateFrom || @getTodayString()
    @dateTo = current?.dateTo || @getTodayString()
    @ownerId = current?.ownerId || ''  # 담당자 ID 추가

    @tabs = []
    for model in App.Config.get('models_searchable')
      model = model.replace(/::/g, '')
      tab =
        name: App[model]?.display_name || model
        model: model
        count: 0
        active: false
      if @model == model
        tab.active = true
      @tabs.push tab

    # build view
    console.log 'About to call getAgents()'
    agents = @getAgents()
    console.log 'getAgents() returned:', agents
    
    elLocal = $(App.view('search/index')(
      query: @query
      tabs: @tabs
      dateFrom: @dateFrom    # 추가
      dateTo: @dateTo        # 추가
      ownerId: @ownerId      # 담당자 ID 추가
      agents: agents   # 담당자 목록 추가
    ))

    if App.User.current().permission('ticket.agent')
      @controllerTicketBatch.releaseController() if @controllerTicketBatch
      @controllerTicketBatch = new App.TicketBatch(
        el:       elLocal.filter('.js-batch-overlay')
        parent:   @
        parentEl: elLocal
        appEl:    @appEl
        batchSuccess: =>
          @search(0, true)
      )

    @html elLocal

    # 렌더링 후 필드 값 설정
    @dateFromInput = @$('.js-date-from')
    @dateToInput = @$('.js-date-to')
    @ownerSelect = @$('.js-owner-select')

    if @dateFromInput.length > 0
      @dateFromInput.val(@dateFrom)
    if @dateToInput.length > 0
      @dateToInput.val(@dateTo)
    if @ownerSelect.length > 0
      @ownerSelect.val(@ownerId)

    if @query || @hasDateRange() || @hasOwner()
      @search(500, true)

  # 날짜 범위가 설정되어 있는지 확인
  hasDateRange: ->
    (@dateFrom && @dateFrom.length > 0) || (@dateTo && @dateTo.length > 0)

  # 담당자가 설정되어 있는지 확인
  hasOwner: ->
    @ownerId && @ownerId.length > 0

  # 담당자 목록 가져오기 (티켓 생성에서 사용하는 formMeta 방식)
  getAgents: ->
    agents = []
    
    console.log 'getAgents called, formMeta:', @formMeta
    console.log 'formMeta.dependencies:', @formMeta?.dependencies
    console.log 'formMeta.dependencies.group_id:', @formMeta?.dependencies?.group_id
    
    # 1순위: formMeta 사용
    if @formMeta?.dependencies?.group_id
      # 모든 그룹의 담당자 ID를 수집
      allOwnerIds = []
      for groupId, deps of @formMeta.dependencies.group_id
        if deps.owner_id && _.isArray(deps.owner_id)
          allOwnerIds = _.union(allOwnerIds, deps.owner_id)
      
      # 중복 제거
      allOwnerIds = _.uniq(allOwnerIds)
      
      console.log 'Found owner IDs from formMeta:', allOwnerIds
      
      # User 객체로 변환하고 정렬
      for ownerId in allOwnerIds
        user = App.User.find(ownerId)
        if user
          agents.push(
            id: user.id
            name: user.displayName() || "#{user.firstname} #{user.lastname}".trim() || user.login
            login: user.login
            email: user.email
          )
    
    # formMeta에서 찾지 못했거나 없는 경우 폴백 사용
    if agents.length == 0
      console.log 'No agents found from formMeta, using fallback method'
      
      # Agent 권한을 가진 모든 사용자 검색
      try
        # 현재 사용자가 볼 수 있는 모든 그룹 가져오기
        currentUser = App.User.current()
        if currentUser
          allGroupIds = currentUser.allGroupIds('read')
          console.log 'Current user groups:', allGroupIds
          
          # 각 그룹의 멤버들 확인
          uniqueUserIds = []
          for groupId in allGroupIds || []
            group = App.Group.find(groupId)
            if group && group.user_ids
              uniqueUserIds = _.union(uniqueUserIds, group.user_ids)
          
          console.log 'Found user IDs from groups:', uniqueUserIds
          
          # User 객체로 변환
          for userId in uniqueUserIds
            user = App.User.find(userId)
            if user && user.active
              agents.push(
                id: user.id
                name: user.displayName() || "#{user.firstname} #{user.lastname}".trim() || user.login
                login: user.login
                email: user.email
              )
      catch error
        console.log 'Error in fallback method:', error
        
        # 최종 폴백: 모든 활성 사용자 중에서 Agent 권한 확인
        allUsers = App.User.all()
        console.log 'Using final fallback - total users:', allUsers.length
        
        for user in allUsers
          continue unless user.active
          
          # Agent 권한 확인
          hasAgentPermission = false
          
          if user.role_ids && user.role_ids.length > 0
            for roleId in user.role_ids
              role = App.Role.find(roleId)
              if role && role.permissions && _.contains(role.permissions, 'ticket.agent')
                hasAgentPermission = true
                break
          
          if hasAgentPermission
            agents.push(
              id: user.id
              name: user.displayName() || "#{user.firstname} #{user.lastname}".trim() || user.login
              login: user.login
              email: user.email
            )
    
    console.log 'Final agents found:', agents.length, agents
    
    # 이름순으로 정렬
    _.sortBy(agents, 'name')

  listNavigate: (e) =>
    @resultPaginated = {}

    if e.keyCode is 27 # close on esc
      @empty()
      return

    # on other keys, show result
    @navigate "#search/#{encodeURIComponent(@searchInput.val())}"
    @savedOrderBy = {}
    @search(0)

  empty: =>
    @searchInput.val('')
    todayString = @getTodayString()
    if @dateFromInput && @dateFromInput.length > 0
      @dateFromInput.val(todayString)
    if @dateToInput && @dateToInput.length > 0
      @dateToInput.val(todayString)
    if @ownerSelect && @ownerSelect.length > 0
      @ownerSelect.val('')
    @query = ''
    @dateFrom = todayString
    @dateTo = todayString
    @ownerId = ''
    @updateFilledClass()
    @updateTask()
    @delayedRemoveAnyPopover()

  # 기존 search 메서드는 그대로 유지
  search: (delay, force = false, skipRendering = false) =>
    query = @searchInput.val().trim()

    # 쿼리에 날짜 범위를 추가해서 전달
    finalQuery = @buildQueryWithDateRange(query)

    if !force
      return if !finalQuery && !@hasDateRange() && !@hasOwner()
      return if finalQuery is @lastFinalQuery && !@dateChanged() && !@ownerChanged()
    
    @query = query  # 원본 쿼리는 사용자 입력만 저장
    @lastFinalQuery = finalQuery  # 마지막 최종 쿼리 저장
    @updateTask()

    if delay is 0
      delay = 500
      if query.length > 2
        delay = 350
      else if query.length > 4
        delay = 200

    # GlobalSearch에 날짜 파라미터 포함해서 호출
    searchParams = 
      delay: delay
      query: @lastFinalQuery
      skipRendering: skipRendering
      
    # 날짜 파라미터 추가
    if @dateFrom && @dateFrom.length > 0
      searchParams.date_from = @dateFrom
    if @dateTo && @dateTo.length > 0
      searchParams.date_to = @dateTo
    # 담당자 파라미터 추가
    if @ownerId && @ownerId.length > 0
      searchParams.owner_id = @ownerId

    console.log '[Search] Calling GlobalSearch with params:', searchParams

    @globalSearch.search(searchParams)
  
    # 쿼리에 날짜 범위와 담당자를 추가하는 메서드
  buildQueryWithDateRange: (baseQuery) ->
    # 기본 쿼리 정리
    cleanQuery = baseQuery.trim()
    conditions = []
    
    # 날짜 범위 쿼리 생성
    if @dateFrom && @dateTo && @dateFrom.length > 0 && @dateTo.length > 0
      conditions.push("created_at:[#{@dateFrom} TO #{@dateTo}]")
    else if @dateFrom && @dateFrom.length > 0
      conditions.push("created_at:[#{@dateFrom} TO *]")
    else if @dateTo && @dateTo.length > 0
      conditions.push("created_at:[* TO #{@dateTo}]")
    
    # 담당자 조건 추가
    if @ownerId && @ownerId.length > 0
      conditions.push("owner_id:#{@ownerId}")
    
    # 최종 쿼리 조합
    allConditions = conditions.join(' ')
    if cleanQuery && allConditions
      "#{cleanQuery} #{allConditions}"
    else if allConditions
      allConditions
    else
      cleanQuery

  # 날짜가 변경되었는지 확인
  dateChanged: ->
    @dateFrom != @lastDateFrom || @dateTo != @lastDateTo

  # 담당자가 변경되었는지 확인
  ownerChanged: ->
    @ownerId != @lastOwnerId



  buildResultCacheKey: (offset, direction, column, object) -> {
    "#{object}-#{offset}-#{direction}-#{column}"
  }

  renderResult: (result = {}, params = undefined) =>
    if !_.isUndefined(params?.offset)
      @renderPaginatedSearchResult(result, params)
    else
      @renderInitialSearchResult(result, params)

    @loadNextInQueue()

  renderPaginatedSearchResult: (result, params) =>
    for klassName, metadata of result
      @resultPaginated[klassName] ||= {}

      cacheKey = @buildResultCacheKey(params?.offset, params?.orderDirection, params?.orderBy, klassName)
      @resultPaginated[klassName][cacheKey] = metadata.items

      @result[klassName] ||= {}
      @result[klassName].total_count = metadata.total_count

      if @model is klassName
        @renderTab(klassName, metadata.items || [])

  renderInitialSearchResult: (result, params) =>
    @result = result
    # @savedOrderBy = {}
    for tab in @tabs
      count = result[tab.model]?.total_count || 0
      @$(".js-tab#{tab.model} .js-counter").text(count)

      if !params?.skipRendering and @model is tab.model
        @renderTab(tab.model, result[tab.model]?.items || [])

  loadNextInQueue: =>
    if @queue?.query != @query
      @queue = {}
      return

    nextModel = @queue.models.shift()

    if !nextModel
      @queue = {}
    else if nextModel is 'all'
      @search(-1, true, true)
    else
      @goToPaginated(nextModel, @savedOrderBy[nextModel]?.page)

  showTab: (e) =>
    tabs = $(e.currentTarget).closest('.tabs')
    tabModel = $(e.currentTarget).data('tab-content')
    tabs.find('.js-tab').removeClass('active')
    $(e.currentTarget).addClass('active')


    savedOrder = @savedOrderBy[tabModel]

    items = if !savedOrder
              @result[tabModel]?.items
            else
              cacheKey = @buildResultCacheKey(savedOrder.page * 50, savedOrder.orderDirection, savedOrder.orderBy, tabModel)
              @resultPaginated?[tabModel]?[cacheKey]

    @renderTab(tabModel, items || [])

  renderTab: (model, localList) =>

    # remember last shown model
    if @model isnt model
      @model = model
      @updateTask()

    list = []
    for item in localList
      object = App[model].fullLocal(item.id)
      list.push object
    if model is 'Ticket'

      openTicket = (id,e) =>
        # open ticket via task manager to provide task with overview info
        ticket = App.Ticket.findNative(id)
        App.TaskManager.execute(
          key:        "Ticket-#{ticket.id}"
          controller: 'TicketZoom'
          params:
            ticket_id:   ticket.id
            overview_id: @overview.id
          show:       true
        )
        @navigate ticket.uiUrl()

      checkbox = @permissionCheck('ticket.agent') ? true : false

      callbackCheckbox = (id, checked, e) =>
        if @shouldShowBulkForm()
          @bulkForm.render()
          @bulkForm.show()
        else
          @bulkForm.hide()

        if @lastChecked && e.shiftKey
          # check items in a row
          currentItem = $(e.currentTarget).parents('.item')
          lastCheckedItem = $(@lastChecked).parents('.item')
          items = currentItem.parent().children()

          if currentItem.index() > lastCheckedItem.index()
            # current item is below last checked item
            startId = lastCheckedItem.index()
            endId = currentItem.index()
          else
            # current item is above last checked item
            startId = currentItem.index()
            endId = lastCheckedItem.index()

          items.slice(startId+1, endId).find('[name="bulk"]').prop('checked', (-> !@checked))

        @lastChecked = e.currentTarget
        @bulkForm.updateTicketIdsBulkForm(e)

      ticket_ids = []
      for item in localList
        ticket_ids.push item.id

      localeEl = @$('.js-content')
      @table.releaseController() if @table
      @table = new App.TicketList(
        tableId:    "find_#{model}"
        el:         localeEl
        columns:    @constructor.ticketSearchColumns
        ticket_ids: ticket_ids
        radio:      false
        checkbox:   checkbox
        orderBy:        @getSavedOrderBy()?.orderBy
        orderDirection: @getSavedOrderBy()?.orderDirection
        bindRow:
          events:
            'click': openTicket
        bindCheckbox:
          events:
            'click': callbackCheckbox
          select_all: callbackCheckbox
        sortClickCallback: @saveOrderBy
        pagerAjax:    true
      )

      updateSearch = =>
        @delay(@reloadCurrentSearch, 100)

      @bulkForm.releaseController() if @bulkForm
      @bulkForm = new App.TicketBulkForm(
        el:           @el.find('.bulkAction')
        holder:       localeEl
        view:         @view
        batchSuccess: updateSearch
        noSidebar:    true
      )

      # start bulk action observ
      localElement = @$('.js-content')
      if localElement.find('input[name="bulk"]:checked').length isnt 0
        @bulkForm.show()

      # show/hide bulk action
      localElement.on('change', 'input[name="bulk"], input[name="bulk_all"]', (e) =>
        if @shouldShowBulkForm()
          @bulkForm.show()
        else
          @bulkForm.hide()
          @bulkForm.reset()
      )

      # deselect bulk_all if one item is uncheck observ
      localElement.on('change', '[name="bulk"]', (e) ->
        bulkAll = localElement.find('[name="bulk_all"]')
        checkedCount = localElement.find('input[name="bulk"]:checked').length
        checkboxCount = localElement.find('input[name="bulk"]').length
        if checkedCount is 0
          bulkAll.prop('indeterminate', false)
          bulkAll.prop('checked', false)
        else
          if checkedCount is checkboxCount
            bulkAll.prop('indeterminate', false)
            bulkAll.prop('checked', true)
          else
            bulkAll.prop('checked', false)
            bulkAll.prop('indeterminate', true)
      )
    else
      openObject = (id,e) =>
        object = App[@model].fullLocal(id)
        @navigate object.uiUrl()

      @table.releaseController() if @table
      @table = new App.ControllerTable(
        orderBy: @getSavedOrderBy()?.orderBy
        orderDirection: @getSavedOrderBy()?.orderDirection
        tableId: "find_#{model}"
        el:      @$('.js-content')
        model:   App[model]
        objects: list
        bindRow:
          events:
            'click': openObject
        sortClickCallback: @saveOrderBy
        pagerEnabled: false
        orderEnabled: false
        pagerAjax: true
      )

    @renderPagination()

  renderPagination: =>
    object = @el.find('.js-tab.active').data('tab-content')
    page   = @getSavedOrderBy()?.page || 0
    count  = @result[object]?.total_count || 0
    pages  = Math.ceil(count / 50) - 1

    if (!pages && !page) || count == 0
      @$('.js-pager').html('')
      return

    pager = App.view('generic/table_pager')(
      page:  page
      pages: pages
    )

    @$('.js-pager').html(pager)

  paginate: (e) =>
    @preventDefaultAndStopPropagation(e)

    page   = parseInt($(e.currentTarget).attr('data-page'))
    object = @el.find('.js-tab.active').data('tab-content')

    ordering = @savedOrderBy[@model] || {}
    ordering.page = page

    @savedOrderBy[@model] = ordering

    @goToPaginated(object, page)

  sortByColumn: (e) =>
    @preventDefaultAndStopPropagation(e)

    newColumn = $(e.currentTarget).closest('[data-column-key]').attr('data-column-key')

    config = _.find App[@model].configure_attributes, (elem) -> elem.name == newColumn

    # There's no reliable way to sort to-many relations. Sorry.
    return if config.multiple && config.relation

    current = @getSavedOrderBy()

    newOrderDirection = if current?.orderBy == newColumn && current?.orderDirection == 'ASC'
                          'DESC'
                        else
                          'ASC'

    @savedOrderBy[@model] = { orderBy: newColumn, orderDirection: newOrderDirection }
    @goToPaginated(@model, 0)

  goToPaginated: (object, page) =>
    savedOrder = @savedOrderBy[object]

    @globalSearch.search(
      query: @query
      object:object
      offset: (page || 0) * 50
      orderBy: savedOrder?.orderBy
      orderDirection: savedOrder?.orderDirection
      delay: -1
    )

  # 날짜 변경 시 호출되는 메서드
  onDateChange: (e) =>
    @dateFrom = @dateFromInput.val() if @dateFromInput
    @dateTo = @dateToInput.val() if @dateToInput

    # 자동으로 날짜 필터 적용
    @updateTask()
    
    # 검색어가 있을 때만 자동 검색
    @search(500, true)

  # 담당자 변경 시 호출되는 메서드
  onOwnerChange: (e) =>
    @ownerId = @ownerSelect.val() if @ownerSelect

    # 자동으로 담당자 필터 적용
    @updateTask()
    
    # 자동 검색 실행
    @search(500, true)

    # 자동으로 날짜 필터 적용 (버튼 클릭 없이)
  autoApplyDateFilter: =>
    # 기존 검색어에서 날짜 범위 제거
    currentQuery = @searchInput.val().trim()
    cleanQuery = @removeDateFromQuery(currentQuery)
    
    # 새로운 날짜 범위 추가
    if @dateFrom && @dateTo
      dateQuery = "created_at:[#{@dateFrom} TO #{@dateTo}]"
      newQuery = if cleanQuery
                   "#{cleanQuery} #{dateQuery}"
                 else
                   dateQuery
    else if @dateFrom
      dateQuery = "created_at:[#{@dateFrom} TO *]"
      newQuery = if cleanQuery
                   "#{cleanQuery} #{dateQuery}"
                 else
                   dateQuery
    else if @dateTo
      dateQuery = "created_at:[* TO #{@dateTo}]"
      newQuery = if cleanQuery
                   "#{cleanQuery} #{dateQuery}"
                 else
                   dateQuery
    else
      # 날짜가 모두 비어있으면 기존 쿼리만 유지
      newQuery = cleanQuery

    # 검색 입력 필드 업데이트
    @searchInput.val(newQuery)
    @updateFilledClass()
    
    # 딜레이를 두고 검색 실행 (너무 빠른 연속 입력 방지)
    @search(800, true)

  # 날짜 필터 적용 버튼 클릭 (이제 즉시 적용용)
  applyDateFilter: (e) =>
    e.preventDefault()
    
    @dateFrom = @dateFromInput.val() if @dateFromInput
    @dateTo = @dateToInput.val() if @dateToInput
    
    @autoApplyDateFilter()    

  # 쿼리에서 기존 날짜 범위 제거
  removeDateFromQuery: (query) ->
    return '' if !query
    
    # created_at:[날짜범위] 패턴 제거
    cleanQuery = query.replace(/created_at:\[[^\]]+\]/g, '')
    # updated_at:[날짜범위] 패턴도 제거
    cleanQuery = cleanQuery.replace(/updated_at:\[[^\]]+\]/g, '')
    # close_at:[날짜범위] 패턴도 제거  
    cleanQuery = cleanQuery.replace(/close_at:\[[^\]]+\]/g, '')
    
    # 연속된 공백 정리
    cleanQuery = cleanQuery.replace(/\s+/g, ' ').trim()
    cleanQuery

  updateTask: =>
    current = App.TaskManager.get(@taskKey).state
    return if !current
    current.query = @query
    current.model = @model
    current.dateFrom = @dateFrom  # 추가
    current.dateTo = @dateTo      # 추가
    current.ownerId = @ownerId    # 담당자 ID 추가
    App.TaskManager.update(@taskKey, { state: current })
    App.TaskManager.touch(@taskKey)

  updateFilledClass: ->
    @searchInput.toggleClass 'is-empty', !@searchInput.val()

  shouldShowBulkForm: =>
    items = @$('table').find('input[name="bulk"]:checked')
    return false if items.length == 0

    ticket_ids        = _.map(items, (el) -> $(el).val() )
    ticket_group_ids  = _.map(App.Ticket.findAll(ticket_ids), (ticket) -> ticket.group_id)
    ticket_group_ids  = _.uniq(ticket_group_ids)
    allowed_group_ids = App.User.find(@Session.get('id')).allGroupIds('change')
    allowed_group_ids = _.map(allowed_group_ids, (id_string) -> parseInt(id_string, 10) )
    _.every(ticket_group_ids, (id) -> id in allowed_group_ids)

  getSavedOrderBy: =>
    @savedOrderBy[@model]

  saveOrderBy: (table) =>
    return if !table

    @savedOrderBy[@model] = { orderBy: table.orderBy, orderDirection: table.orderDirection }

class Router extends App.ControllerPermanent
  @requiredPermission: ['*']

  constructor: (params) ->
    super

    # check authentication
    @authenticateCheckRedirect()

    query = undefined
    if !_.isEmpty(params.query)
      query = decodeURIComponent(params.query)

    # cleanup params
    clean_params =
      query: query

    App.TaskManager.execute(
      key:        'Search'
      controller: 'Search'
      params:     clean_params
      show:       true
    )

App.Config.set('search', Router, 'Routes')
App.Config.set('search/:query', Router, 'Routes')
