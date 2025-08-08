class App.GlobalSearch extends App.Controller
  ajaxCount: 0
  constructor: ->
    super
    @searchResultCache = {}
    @lastParams = undefined
    @apiPath = App.Config.get('api_path')
    @ajaxId = "search-#{Math.floor( Math.random() * 999999 )}"

  search: (params) =>
    query = params.query

    # 날짜 범위를 포함한 캐시 키 생성
    cacheKey = @searchResultCacheKey(query, params)

    # use cache for search result
    currentTime = new Date
    if !params.force && @searchResultCache[cacheKey] && @searchResultCache[cacheKey].time > currentTime.setSeconds(currentTime.getSeconds() - 20)
      if @ajaxRequestId
        App.Ajax.abort(@ajaxRequestId)
      @ajaxStart(params)
      @renderTry(@searchResultCache[cacheKey].result, query, params)
      delayCallback = =>
        @ajaxStop(params)
      @delay(delayCallback, 700)
      return

    delayCallback = =>

      @ajaxStart(params)

      delayCallback = ->
        if params.callbackLongerAsExpected
          params.callbackLongerAsExpected()
      @delay(delayCallback, 10000, 'global-search-ajax-longer-as-expected')

      # API 요청 데이터 구성
      requestData = 
        query: query
        by_object: true
        objects: params.object
        limit: @limit || 10
        offset: params.offset
        order_by: params.orderDirection
        sort_by: params.orderBy

      # 날짜 범위 파라미터 추가
      if params.date_from
        requestData.date_from = params.date_from
        console.log '[GlobalSearch] Adding date_from:', params.date_from
        
      if params.date_to
        requestData.date_to = params.date_to
        console.log '[GlobalSearch] Adding date_to:', params.date_to

      console.log '[GlobalSearch] Request data:', requestData

      @ajaxRequestId = App.Ajax.request(
        id:   @ajaxId
        type: 'GET'
        url: "#{@apiPath}/search"
        data: requestData
        processData: true
        success: (data, status, xhr) =>
          console.log '[GlobalSearch] Response received:', data
          
          @clearDelay('global-search-ajax-longer-as-expected')
          App.Collection.loadAssets(data.assets)

          userProfileAccess         = @permissionCheck(App.Config.get('user/profile/:user_id', 'Routes').requiredPermission)
          organizationProfileAccess = @permissionCheck(App.Config.get('organization/profile/:organization_id', 'Routes').requiredPermission)

          result = {}
          for klassName, metadata of data.result
            # user and organization are allowed via API but should not show # up for customers because there are no profile pages for customers
            continue if klassName is 'User' && !userProfileAccess
            continue if klassName is 'Organization' && !organizationProfileAccess

            klass = App[klassName]

            if !klass.find
              App.Log.error('_globalSearchSingleton', "No such model App.#{klassName}")
              continue

            item_objects = []

            for item_id in metadata.object_ids
              item_object = klass.find(item_id)

              if !item_object.searchResultAttributes
                App.Log.error('_globalSearchSingleton', "No such model #{klassName.toLocaleLowerCase()}.searchResultAttributes()")
                continue

              item_objects.push(item_object.searchResultAttributes())

            result[klassName] = { items: item_objects, total_count: metadata.total_count }

          @ajaxStop(params)
          @renderTry(result, query, params)
        error: (xhr, status, error) =>
          console.error '[GlobalSearch] Request failed:', status, error
          if xhr.responseText
            try
              errorData = JSON.parse(xhr.responseText)
              console.error '[GlobalSearch] Error details:', errorData
            catch
              console.error '[GlobalSearch] Response text:', xhr.responseText
          @clearDelay('global-search-ajax-longer-as-expected')
          @ajaxStop(params)
      )
    @delay(delayCallback, params.delay || 1, 'global-search-ajax')

  ajaxStart: (params) =>
    @ajaxCount++
    if params.callbackStart
      params.callbackStart()

  ajaxStop: (params) =>
    @ajaxCount--
    if @ajaxCount == 0 && params.callbackStop
      params.callbackStop()

  renderTry: (result, query, params) =>
    cacheKey = @searchResultCacheKey(query, params)

    if query
      if _.isEmpty(result)
        if params.callbackNoMatch
          params.callbackNoMatch()
      else
        if params.callbackMatch
          params.callbackMatch()

      # if result hasn't changed, do not rerender
      if !params.force && @lastParams is params && @searchResultCache[cacheKey]
        diff = difference(@searchResultCache[cacheKey].result, result)
        if _.isEmpty(diff)
          return

      @lastParams = params

      # cache search result
      @searchResultCache[cacheKey] =
        result: result
        time: new Date

    @render(result, params)

  # 캐시 키에 날짜 범위 정보 포함
  searchResultCacheKey: (query, params) ->
    dateFromKey = params.date_from || ''
    dateToKey = params.date_to || ''
    "#{query}-#{params.object}-#{params.offset}-#{params.orderDirection}-#{params.orderBy}-#{dateFromKey}-#{dateToKey}"

  close: =>
    @lastParams = undefined