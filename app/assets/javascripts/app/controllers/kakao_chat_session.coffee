class KakaoChatSession extends App.ControllerSubContent
  header: __('카카오톡 상담 세션')
  
  constructor: (params) ->
    super
    
    # 세션 ID 추출
    @sessionId = params.session_id
    console.log 'KakaoChatSession constructor called with sessionId:', @sessionId
    
    # 데이터 초기화
    @session = null
    @messages = []
    @agents = []
    
    # 세션 데이터 로드
    @loadSession()
    
    # 상담원 목록 로드
    @loadAgents()
    
    # WebSocket 이벤트 바인딩
    @bindWebSocketEvents()

  # 세션 데이터 로드
  loadSession: =>
    console.log 'Loading session data for:', @sessionId
    
    App.Ajax.request(
      id: 'kakao_chat_session_show'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}"
      success: (data) =>
        console.log 'Session data loaded:', data
        @session = data.session
        @loadMessages()
      error: (xhr, status, error) =>
        console.error 'Failed to load session:', error
        @renderError('세션을 불러올 수 없습니다.')
    )

  # 메시지 목록 로드
  loadMessages: =>
    console.log 'Loading messages for session:', @sessionId
    
    App.Ajax.request(
      id: 'kakao_chat_messages'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/messages"
      success: (data) =>
        console.log 'Messages loaded:', data
        @messages = data.messages || []
        @render()
      error: (xhr, status, error) =>
        console.error 'Failed to load messages:', error
        @renderError('메시지를 불러올 수 없습니다.')
    )

  # 상담원 목록 로드
  loadAgents: =>
    App.Ajax.request(
      id: 'kakao_chat_agents'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/agents"
      success: (data) =>
        console.log 'Agents loaded:', data
        @agents = data.agents || []
      error: (xhr, status, error) =>
        console.error 'Failed to load agents:', error
        @agents = []
    )

  # 화면 렌더링
  render: =>
    console.log 'Rendering session view'
    
    # highlight navbar - 네비게이션 하이라이트 적용
    @navupdate('#kakao_chat')
    
    if not @session
      @renderLoading()
      return
    
    # 메시지 목록 HTML 생성
    messagesList = @messages.map((message) =>
      senderClass = switch message.sender_type
        when 'customer' then 'customer'
        when 'agent' then 'agent'
        when 'system' then 'system'
        else 'unknown'
      
      timeStr = if message.sent_at
        @humanTime(message.sent_at)
      else
        '시간 없음'
      
      # 상담원 메시지는 오른쪽 정렬, 나머지는 왼쪽 정렬
      alignmentClass = if message.sender_type is 'agent' then 'message-right' else 'message-left'
      
      """
      <div class="message message-#{senderClass} #{alignmentClass}">
        <div class="message-bubble">
          <div class="message-header">
            <strong>#{message.sender_name || message.sender_type}</strong>
            <span class="time">#{timeStr}</span>
          </div>
          <div class="message-content">
            #{App.Utils.htmlEscape(message.content)}
          </div>
        </div>
      </div>
      """
    ).join('')
    
    # 세션 상태 표시
    statusClass = switch @session.status
      when 'active' then 'success'
      when 'waiting' then 'warning'
      when 'ended' then 'neutral'
      else 'neutral'
    
    statusText = switch @session.status
      when 'waiting' then '대기중'
      when 'active' then '진행중'
      when 'ended' then '종료됨'
      else '알 수 없음'
    
    html = """
      <div class="main">
        <div class="header">
          <div class="header-title">
            <h1>
              #{@session.customer_name} 
              <small>#{@session.session_id}</small>
            </h1>
            <div class="session-info">
              <span class="label label-#{statusClass}">#{statusText}</span>
              <span class="agent-info">
                담당자: #{@session.agent_name || '미배정'}
              </span>
            </div>
          </div>
          <div class="header-button" style="display: flex; justify-content: space-between; align-items: center;">
            <div class="btn btn--action btn--header js-back" title="목록으로">
                ← 목록
            </div>
            #{if @session.status in ['active', 'waiting'] then '<div class="btn btn--danger btn--header js-end-session" title="상담 종료">상담 종료</div>' else ''}
          </div>
        </div>
        
        <div class="content">
          <div class="session-details">
            <div class="customer-info customer-info-row">
              <h3>고객 정보</h3>
              <div class="customer-info-horizontal">
                <span><strong>이름:</strong> #{@session.customer_name}</span>
                <span><strong>세션 ID:</strong> #{@session.session_id}</span>
                <span><strong>시작 시간:</strong> #{if @session.started_at then @humanTime(@session.started_at) else '없음'}</span>
                <span><strong>진행 시간:</strong> #{@session.duration || '0분'}</span>
              </div>
            </div>
            
            #{if @session.status in ['active', 'waiting'] then @renderAgentAssignment() else ''}
          </div>
          
          <div class="messages-container">
            <h3>메시지 목록 (#{@messages.length}개)</h3>
            <div class="messages-list">
              #{if @messages.length > 0 then messagesList else '<div class="no-messages">메시지가 없습니다.</div>'}
            </div>
          </div>
          
          #{if @session.status in ['active', 'waiting'] then @renderMessageInput() else ''}
        </div>
      </div>
    """
    
    @el.html(html)
    @bindEvents()

  # 메시지 입력 폼 렌더링
  renderMessageInput: =>
    placeholder = if @session.status is 'waiting' then '메시지를 입력하세요... (첫 메시지 전송 시 상담이 시작됩니다)' else '메시지를 입력하세요...'
    """
    <div class="message-input-container">
      <h3>메시지 보내기</h3>
      <div class="message-input-form">
        <textarea class="js-message-input" placeholder="#{placeholder}" rows="3"></textarea>
        <div class="form-actions">
          <button class="btn btn--primary js-send-message">전송</button>
        </div>
      </div>
    </div>
    """

  # 담당자 배정 UI 렌더링
  renderAgentAssignment: =>
    agentOptions = @agents.map((agent) =>
      selected = if agent.id is @session.agent_id then 'selected' else ''
      """<option value="#{agent.id}" #{selected}>#{agent.name}</option>"""
    ).join('')
    
    """
    <div class="agent-assignment">
      <h3>담당자 관리</h3>
      <div class="form-group horizontal-layout">
        <label>담당 상담원:</label>
        <select class="form-control js-agent-select">
          <option value="">담당자 선택</option>
          #{agentOptions}
        </select>
        <button class="btn btn--secondary js-assign-agent">담당자 변경</button>
      </div>
    </div>
    """

  # 로딩 화면
  renderLoading: =>
    html = '''
      <div class="main flex vertical">
        <h2 class="logotype">카카오톡 상담 세션</h2>
        <div class="loading icon"></div>
        <div class="center">세션 정보를 불러오는 중...</div>
      </div>
    '''
    @el.html(html)

  # 오류 화면
  renderError: (message) =>
    html = """
      <div class="main flex vertical">
        <h2 class="logotype">카카오톡 상담 세션</h2>
        <div class="hero-unit">
          <h1>오류</h1>
          <p>#{message}</p>
          <div class="btn btn--action js-back">← 목록으로 돌아가기</div>
        </div>
      </div>
    """
    @el.html(html)
    @bindEvents()

  # 이벤트 바인딩
  bindEvents: =>
    # 목록으로 돌아가기
    @el.on('click', '.js-back', (e) =>
      e.preventDefault()
      @navigate('#kakao_chat')
    )
    
    # 메시지 전송
    @el.on('click', '.js-send-message', (e) =>
      e.preventDefault()
      @sendMessage()
    )
    
    # Enter 키로 메시지 전송
    @el.on('keydown', '.js-message-input', (e) =>
      if e.keyCode is 13 and not e.shiftKey  # Enter without Shift
        e.preventDefault()
        @sendMessage()
    )
    
    # 상담 종료
    @el.on('click', '.js-end-session', (e) =>
      e.preventDefault()
      @endSession()
    )
    
    # 담당자 변경
    @el.on('click', '.js-assign-agent', (e) =>
      e.preventDefault()
      @assignAgent()
    )

  # 메시지 전송
  sendMessage: =>
    content = @el.find('.js-message-input').val()?.trim()
    return if not content
    
    console.log 'Sending message:', content
    
    App.Ajax.request(
      id: 'kakao_chat_send_message'
      type: 'POST'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/messages"
      data: JSON.stringify(content: content)
      processData: false
      success: (data) =>
        console.log 'Message sent successfully:', data
        @el.find('.js-message-input').val('')
        @loadSession()  # 세션 정보 새로고침 (상태 변경 반영)
        @loadMessages()  # 메시지 목록 새로고침
      error: (xhr, status, error) =>
        console.error 'Failed to send message:', error
        alert('메시지 전송에 실패했습니다.')
    )

  # 상담 종료
  endSession: =>
    return unless confirm('상담을 종료하시겠습니까?')
    
    App.Ajax.request(
      id: 'kakao_chat_end_session'
      type: 'POST'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/end"
      success: (data) =>
        console.log 'Session ended successfully:', data
        @navigate('#kakao_chat')
      error: (xhr, status, error) =>
        console.error 'Failed to end session:', error
        alert('상담 종료에 실패했습니다.')
    )

  # 담당자 변경
  assignAgent: =>
    agentId = @el.find('.js-agent-select').val()
    return if not agentId
    
    selectedAgent = @agents.find((agent) => agent.id.toString() is agentId)
    return unless selectedAgent
    
    return unless confirm("담당자를 '#{selectedAgent.name}'로 변경하시겠습니까?")
    
    App.Ajax.request(
      id: 'kakao_chat_assign_agent'
      type: 'POST'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/assign"
      data: JSON.stringify(agent_id: agentId)
      processData: false
      success: (data) =>
        console.log 'Agent assigned successfully:', data
        @loadSession()  # 세션 정보 새로고침
        @loadMessages() # 메시지 목록 새로고침 (시스템 메시지 포함)
      error: (xhr, status, error) =>
        console.error 'Failed to assign agent:', error
        alert('담당자 변경에 실패했습니다.')
    )

  # WebSocket 이벤트 바인딩
  bindWebSocketEvents: =>
    # 새 메시지 수신 시 자동 새로고침
    @controllerBind('kakao_message_received', (data) =>
      if data.data?.session_id is @sessionId
        console.log 'New message received for current session'
        delay = =>
          @loadMessages()
        @delay(delay, 500, 'kakao_session_message_refresh')
    )
    
    # 메시지 읽음 상태 업데이트
    @controllerBind('kakao_messages_read', (data) =>
      if data.data?.session_id is @sessionId
        console.log 'Messages marked as read by:', data.data.read_by_agent
        # 필요시 UI 업데이트 (예: 읽음 표시)
        @updateReadStatus(data.data)
    )
    
    # 상담원 할당 알림
    @controllerBind('kakao_agent_assigned', (data) =>
      if data.data?.session_id is @sessionId
        console.log 'Agent assigned to session:', data.data.agent_name
        @loadSession() # 세션 정보 새로고침
    )

  # 읽음 상태 UI 업데이트
  updateReadStatus: (data) =>
    # 담당자 정보나 읽음 상태 관련 UI 업데이트
    if data.read_by_agent
      # 읽음 처리한 상담원 정보 표시 (선택사항)
      console.log "Session read by: #{data.read_by_agent}"
    
    # unread_count 업데이트가 있으면 반영
    if data.unread_count?
      @session.unread_count = data.unread_count if @session

# App 네임스페이스에 등록
App.KakaoChatSession = KakaoChatSession

# Router 등록
class KakaoChatSessionRouter extends App.ControllerPermanent
  constructor: (params) ->
    super
    
    # 인증 확인
    @authenticateCheckRedirect()
    
    # TaskManager로 실행
    App.TaskManager.execute(
      key:        "KakaoChatSession-#{params.session_id}"
      controller: 'KakaoChatSession'
      params:     params
      show:       true
      persistent: true
    )

App.Config.set('kakao_chat/:session_id', KakaoChatSessionRouter, 'Routes')

console.log 'KakaoChatSession controller loaded successfully'
