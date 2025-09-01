class KakaoChat extends App.ControllerSubContent
  header: __('카카오톡 상담')
  
  constructor: ->
    # console.log 'KakaoChat constructor called'
    super
    # console.log 'KakaoChat super constructor completed'
    # console.log 'KakaoChat @el after super:', @el
    
    # 설정 변경 시 메뉴 렌더링 이벤트 바인딩
    @controllerBind('menu:render', =>
      # featureActive가 false이면 아무것도 하지 않음
      try
        return if !@featureActive()
      catch error
        # console.log 'Error in menu:render featureActive check:', error
        return
    )
    
    # 세션 목록 로드
    @loadSessions()
    
    # console.log 'KakaoChat constructor completed'

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
        @render()
      error: (xhr, status, error) =>
        # console.error 'Failed to load sessions:', error
        @sessions = []
        @render()
    )

  render: =>
    # console.log 'KakaoChat render called with sessions:', @sessions?.length || 0
    
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
            <small class="text-muted">
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

  # 네비게이션 카운터 기능 추가
  counter: =>
    count = 0
    console.log 'KakaoChat counter() called, sessions:', @sessions?.length || 0
    if @sessions && Array.isArray(@sessions)
      for session in @sessions
        # waiting 상태: 새로운 상담 요청으로 카운트 1
        # active 상태: 실제 읽지 않은 메시지 개수만큼 카운트
        if session.status == 'waiting'
          count += 1  # waiting은 항상 1개로 카운트
          console.log "Session #{session.id}: status=#{session.status}, adding 1 (new consultation)"
        else if session.status == 'active' && session.unread_count > 0
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

# console.log 'KakaoChat controllers loaded successfully'