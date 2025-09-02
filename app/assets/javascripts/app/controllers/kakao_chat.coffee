class KakaoChat extends App.ControllerSubContent
  header: __('카카오톡 상담')
  
  constructor: ->
    # console.log 'KakaoChat constructor called'
    super
    # console.log 'KakaoChat super constructor completed'
    # console.log 'KakaoChat @el after super:', @el
    
    # 현재 화면이 활성화되어 있음을 표시
    @isActive = true
    
    # 강제로 다른 뷰들 정리하고 목록 뷰 설정
    console.log 'KakaoChat constructor - forcing activeView to chat_list'
    @setActiveView('kakao_chat_list')
    
    # 약간의 지연 후에도 다시 설정 (확실하게)
    @delay(=>
      @setActiveView('kakao_chat_list')
      console.log 'KakaoChat constructor - confirmed active view:', KakaoChat.getActiveView()
    , 50, 'confirm_list_view')
    
    # 추가로 100ms 후에도 다시 설정
    @delay(=>
      @setActiveView('kakao_chat_list')
      console.log 'KakaoChat constructor - final confirmation active view:', KakaoChat.getActiveView()
    , 100, 'final_confirm_list_view')
    
    # 네비게이션 하이라이트 즉시 적용
    @forceNavHighlight()
    
    # TaskManager 이벤트 바인딩으로 하이라이트 유지
    @controllerBind('task:show', (data) =>
      if data.key is 'KakaoChat'
        @forceNavHighlight()
    )
    
    # 설정 변경 시 메뉴 렌더링 이벤트 바인딩
    @controllerBind('menu:render', =>
      # featureActive가 false이면 아무것도 하지 않음
      try
        return if !@featureActive()
        @forceNavHighlight()
      catch error
        # console.log 'Error in menu:render featureActive check:', error
        return
    )
    
    # WebSocket 이벤트 바인딩
    @bindWebSocketEvents()
    
    # 주기적 새로고침 (폴백)
    @startPeriodicRefresh()
    
    # 세션 목록 로드
    @loadSessions()
    
    # console.log 'KakaoChat constructor completed'

  # 네비게이션 하이라이트 강제 적용 메서드
  forceNavHighlight: =>
    @navupdate('#kakao_chat')
    $('.js-menu .is-active').removeClass('is-active')
    $('.js-menu [href="#kakao_chat"]').addClass('is-active')
    
    # 여러 번 지연 적용으로 확실하게 보장
    @delay(=>
      $('.js-menu .is-active').removeClass('is-active')
      $('.js-menu [href="#kakao_chat"]').addClass('is-active')
    , 10, 'force_highlight_1')
    
    @delay(=>
      $('.js-menu .is-active').removeClass('is-active')
      $('.js-menu [href="#kakao_chat"]').addClass('is-active')
    , 100, 'force_highlight_2')

  # 네비게이션 표시 여부 결정
  featureActive: ->
    # console.log 'featureActive called - App.Setting exists:', !!App.Setting
    
    # App.Setting이 아직 로드되지 않은 경우 기본값 반환
    if !App.Setting || !App.Setting.get
      # console.log 'App.Setting not ready, returning default true'
      return true
    
    try
      setting = App.Setting.get('kakao_integration')
      # console.log 'featureActive - kakao_integration setting:', setting
      
      # 설정이 undefined인 경우 (아직 로드되지 않음) 기본값 true 반환
      if setting is undefined
        # console.log 'Setting undefined, returning default true'
        return true
      
      result = Boolean(setting)
      # console.log 'featureActive returning:', result
      return result
    catch error
      # 설정이 존재하지 않거나 아직 로드되지 않은 경우 기본값 반환
      # console.log 'kakao_integration setting not available:', error.message
      # console.log 'Returning default true'
      return true

  # 주기적 새로고침 시작 (WebSocket 폴백)
  startPeriodicRefresh: =>
    # 30초마다 세션 목록 새로고침
    @refreshInterval = setInterval(=>
      console.log 'Periodic refresh triggered'
      @loadSessions()
    , 30000)  # 30초 간격

  # 정리 시 인터벌 제거
  release: =>
    console.log 'KakaoChat release called'
    @isActive = false
    @setActiveView(null)
    
    if @refreshInterval
      clearInterval(@refreshInterval)
      @refreshInterval = null
      
    # 모든 delay 취소
    @clearDelay('kakao_refresh')
    @clearDelay('kakao_read_refresh')
    @clearDelay('kakao_assignment_refresh')
    @clearDelay('kakao_counter_update_render')
    @clearDelay('force_highlight_1')
    @clearDelay('force_highlight_2')
    @clearDelay('render_highlight_1')
    @clearDelay('render_highlight_2')
    @clearDelay('confirm_list_view')
    @clearDelay('final_confirm_list_view')
    
    console.log 'KakaoChat released, isActive:', @isActive, 'activeView:', KakaoChat.getActiveView()
    super if super

  # 현재 활성화된 뷰 설정 (전역 상태)
  setActiveView: (viewName) =>
    if window.App
      oldView = window.App.activeKakaoView
      window.App.activeKakaoView = viewName
      console.log "KakaoChat setActiveView: #{oldView} -> #{viewName}"
    else
      console.log 'KakaoChat setActiveView: window.App not available'
    
  # 현재 활성화된 뷰 확인
  @getActiveView: =>
    window.App?.activeKakaoView || null

  # 카카오톡 상담 세션 목록 로드
  loadSessions: =>
    # console.log 'Loading KakaoTalk chat sessions...'
    
    App.Ajax.request(
      id: 'kakao_chat_sessions'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions"
      success: (data) =>
        # console.log 'Sessions loaded:', data
        @sessions = data.sessions || []
        @updateNavMenu()  # CTI 패턴: 네비게이션 업데이트
        @render()
      error: (xhr, status, error) =>
        # console.error 'Failed to load sessions:', error
        @sessions = []
        @updateNavMenu()  # 오류 시에도 네비게이션 업데이트
        @render()
    )

  render: =>
    # console.log 'KakaoChat render called with sessions:', @sessions?.length || 0
    
    # 렌더링 시점에 activeView 재확인 및 설정
    console.log 'KakaoChat render - current activeView before setting:', KakaoChat.getActiveView()
    @setActiveView('kakao_chat_list')
    console.log 'KakaoChat render - activeView after setting:', KakaoChat.getActiveView()
    
    # 전역 접근을 위해 window에 인스턴스 저장 (개발/테스트용)
    window.kakaoChat = @
    
    # 강력한 네비게이션 하이라이트 적용
    @forceNavHighlight()
    
    # 추가 지연 적용으로 확실하게 보장
    @delay(=>
      @forceNavHighlight()
    , 200, 'render_highlight_1')
    
    @delay(=>
      @forceNavHighlight()
    , 500, 'render_highlight_2')
    
    if !@sessions
      # 로딩 중일 때
      html = '''
        <div class="main flex vertical">
          <h2 class="logotype">카카오톡 상담</h2>
          <div class="loading icon"></div>
          <div class="center">세션 목록을 불러오는 중...</div>
        </div>
      '''
    else if @sessions.length == 0
      # 세션이 없을 때
      html = '''
        <div class="main flex vertical">
          <h2 class="logotype">카카오톡 상담</h2>
          <div class="hero-unit">
            <h1>진행 중인 상담이 없습니다</h1>
            <p>새로운 카카오톡 상담 요청을 기다리고 있습니다.</p>
          </div>
        </div>
      '''
    else
      # 세션 목록이 있을 때 - Zammad 표준 테이블 레이아웃
      # 데이터 필드명 수정
      sessionsList = @sessions.map((session) =>
        statusClass = switch session.status
          when 'active' then 'success'
          when 'waiting' then 'warning' 
          when 'ended' then 'neutral'
          when 'transferred' then 'info'
          else 'neutral'
               
        unreadBadge = if session.unread_count > 0
          "<span class='badge badge-danger'>#{session.unread_count}</span>"
        else
          ""
        
        agentInfo = if session.agent_name
          session.agent_name
        else
          "미배정"
        
        # 마지막 메시지 발신 주체에 따른 색상 클래스 결정
        lastMsgClass = switch session.last_message_sender
          when 'customer' then 'last-message-customer'
          when 'agent' then 'last-message-agent'
          when 'system' then 'last-message-system'
          else ''
        
        """
        <tr class="session-row" data-session-id="#{session.session_id}" data-id="#{session.id}">
          <td>
            <strong>#{session.customer_name}</strong> #{unreadBadge}
            <br>
            <small class="text-muted">#{session.session_id}</small>
          </td>
          <td>
            <span class="label label-#{statusClass}">#{@getStatusText(session.status)}</span>
          </td>
          <td>
            <div class="last-message">
              #{if session.last_message_content then App.Utils.textCleanup(session.last_message_content, 50) else '메시지 없음'}
            </div>
            <small class="text-muted #{lastMsgClass}">
              발신: #{if session.last_message_sender == 'customer' then '고객' else if session.last_message_sender == 'agent' then '상담원' else '시스템'}
            </small>
          </td>
          <td>#{agentInfo}</td>
          <td>
            #{@humanTime(session.last_message_at)}
          </td>
        </tr>
        """
      ).join('')
      
      html = """
        <div class="main">
          <div class="header">
            <div class="header-title">
              <h1>카카오톡 상담 <small>(#{@sessions.length}개 세션)</small></h1>
            </div>
            <div class="header-button">
              <div class="btn btn--action js-refresh" title="새로고침">
                새로고침
              </div>
            </div>
          </div>
          
          <div class="content">
            <div class="table-overview">
              <table class="table table-striped table-hover">
                <thead>
                  <tr>
                    <th style="width: 200px;">고객</th>
                    <th style="width: 100px;">상태</th>
                    <th>마지막 메시지</th>
                    <th style="width: 120px;">담당자</th>
                    <th style="width: 160px;">시간</th>
                  </tr>
                </thead>
                <tbody>
                  #{sessionsList}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      """
    
    @el.html(html)
    
    # 이벤트 바인딩
    @bindEvents()

  # 이벤트 바인딩
  bindEvents: =>
    # 세션 행 클릭 시 상세 페이지로 이동
    @el.on('click', '.session-row', (e) =>
      sessionId = $(e.currentTarget).data('session-id')
      console.log 'session click', sessionId      
      @navigate("#kakao_chat/#{sessionId}")
    )
    
    # 새로고침 버튼
    @el.one('click', '.js-refresh', (e) =>
      e.preventDefault()
      @loadSessions()
    )
    
  # 상태 텍스트 변환 - 새로운 상태에 맞게 수정
  getStatusText: (status) ->
    switch status
      when 'waiting' then '대기중'
      when 'active' then '진행중'
      when 'ended' then '종료됨'
      when 'transferred' then '이관됨'
      else '알 수 없음'

  # WebSocket 이벤트 바인딩
  bindWebSocketEvents: =>
    console.log 'Binding WebSocket events for KakaoChat'
    
    # CTI 패턴을 따라 구현
        # WebSocket 이벤트 바인딩
    @controllerBind('kakao_message_received', (data) =>
      console.log 'KakaoChat received kakao_message_received event:', data
      console.log 'Current active view:', KakaoChat.getActiveView()
      
      # 현재 채팅 목록 화면에 있을 때만 처리
      if @isActive and KakaoChat.getActiveView() is 'kakao_chat_list'
        console.log 'Processing message event in chat list view'
        delay = =>
          @loadSessions()
          @updateNavMenu()
        @delay(delay, 1000, 'kakao_refresh')
      else
        console.log 'Ignoring message event - not in chat list view'
    )
    
    # 메시지 읽음 상태 업데이트
    @controllerBind('kakao_messages_read', (data) =>
      console.log 'KakaoChat received kakao_messages_read event:', data
      console.log 'Current active view:', KakaoChat.getActiveView()
      
      # 현재 채팅 목록 화면에 있을 때만 처리
      if @isActive and KakaoChat.getActiveView() is 'kakao_chat_list'
        console.log 'Processing messages read event in chat list view'
        delay = =>
          @loadSessions()
          @updateNavMenu()
        @delay(delay, 500, 'kakao_read_refresh')
      else
        console.log 'Ignoring messages read event - not in chat list view'
    )
    
    # 상담원 할당 알림
    @controllerBind('kakao_agent_assigned', (data) =>
      console.log 'KakaoChat received kakao_agent_assigned event:', data
      console.log 'Current active view:', KakaoChat.getActiveView()
      
      # 현재 채팅 목록 화면에 있을 때만 처리
      if @isActive and KakaoChat.getActiveView() is 'kakao_chat_list'
        console.log 'Processing agent assigned event in chat list view'
        delay = =>
          @loadSessions()
          @updateNavMenu()
        @delay(delay, 500, 'kakao_assignment_refresh')
      else
        console.log 'Ignoring agent assigned event - not in chat list view'
    )
    
    # 카운터 업데이트 이벤트도 처리
    @controllerBind('kakao_counter_update', (data) =>
      console.log 'KakaoChat received kakao_counter_update event:', data
      console.log 'Current active view:', KakaoChat.getActiveView()
      
      # 현재 채팅 목록 화면에 있을 때만 처리
      if @isActive and KakaoChat.getActiveView() is 'kakao_chat_list'
        console.log 'Processing counter update event in chat list view'
        delay = =>
          @updateNavMenu()
        @delay(delay, 100, 'kakao_counter_update_render')
      else
        console.log 'Ignoring counter update event - not in chat list view'
      'kakao_counter_update'
    )
    
    # WebSocket 연결 상태 확인 (안전하게 처리)
    try
      if window.App and App.WebSocket and App.WebSocket.channel and typeof App.WebSocket.channel is 'function'
        channel = App.WebSocket.channel()
        if channel and channel.state
          console.log 'WebSocket connection status:', channel.state
        else
          console.log 'WebSocket channel available but no state'
      else
        console.log 'WebSocket not available'
    catch error
      console.log 'Error checking WebSocket status:', error.message

  # 수동 새로고침 (테스트용)
  manualRefresh: =>
    console.log 'Manual refresh triggered'
    @loadSessions()

  # 네비게이션 카운터 기능 추가 (CTI 패턴)
  counter: =>
    count = 0
    console.log 'KakaoChat counter() called, sessions:', @sessions?.length || 0
    if @sessions and Array.isArray(@sessions)
      for session in @sessions
        # waiting, active 상태 모두 실제 읽지 않은 메시지 개수만큼 카운트
        if (session.status is 'waiting' or session.status is 'active') and session.unread_count > 0
          sessionCount = parseInt(session.unread_count) || 0
          count += sessionCount
          console.log "Session #{session.id}: status=#{session.status}, unread_count=#{session.unread_count}, adding #{sessionCount}"
    console.log 'Final counter value:', count
    count

# App 네임스페이스에 즉시 등록
App.KakaoChat = KakaoChat

# Router 클래스 (TaskManager 방식)
class KakaoChatRouter extends App.ControllerPermanent
  constructor: (params) ->
    super
    # console.log 'KakaoChatRouter constructor called with params:', params

    # 인증 확인
    @authenticateCheckRedirect()
    
    # 라우터 레벨에서 activeView 강제 설정
    console.log 'KakaoChatRouter - forcing activeView to chat_list'
    if window.App
      window.App.activeKakaoView = 'kakao_chat_list'
      console.log 'KakaoChatRouter - set activeView to:', window.App.activeKakaoView
    
    # 네비게이션 하이라이트 강제 적용 (여러 번)
    @navupdate('#kakao_chat')
    $('.js-menu .is-active').removeClass('is-active')
    $('.js-menu [href="#kakao_chat"]').addClass('is-active')
    
    # TaskManager 실행 후에도 하이라이트 유지
    @delay(=>
      $('.js-menu .is-active').removeClass('is-active')
      $('.js-menu [href="#kakao_chat"]').addClass('is-active')
    , 100, 'router_highlight_1')
    
    @delay(=>
      $('.js-menu .is-active').removeClass('is-active')
      $('.js-menu [href="#kakao_chat"]').addClass('is-active')
    , 300, 'router_highlight_2')

    # console.log 'KakaoChatRouter about to execute TaskManager...'
    # TaskManager로 실행 - 컨트롤러를 문자열로 참조
    App.TaskManager.execute(
      key:        'KakaoChat'
      controller: 'KakaoChat'
      params:     params
      show:       true
      persistent: true
    )
    # console.log 'KakaoChatRouter TaskManager.execute completed'

# TaskManager permanentTask 등록 (설정 상태는 featureActive에서 확인)
App.Config.set('KakaoChat', {
  controller: 'KakaoChat'
  permission: ['ticket.agent']
}, 'permanentTask')

# Router 방식으로 등록
App.Config.set('kakao_chat', KakaoChatRouter, 'Routes')

# NavBar 메뉴 항목 등록 - CTI 스타일과 동일하게 설정
App.Config.set('KakaoChat', { 
  prio: 1250, 
  parent: '', 
  name: __('카카오톡 상담'), 
  target: '#kakao_chat', 
  key: 'KakaoChat', 
  shown: true, 
  permission: ['ticket.agent'], 
  class: 'chat',
  counter: true
}, 'NavBar')

# console.log 'KakaoChat controllers loaded successfully'