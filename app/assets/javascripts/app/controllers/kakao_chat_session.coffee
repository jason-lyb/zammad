class KakaoChatSession extends App.ControllerSubContent
  header: __('카카오톡 상담 세션')
  
  constructor: (params) ->
    super
    
    # 세션 ID 추출
    @sessionId = params.session_id
    console.log 'KakaoChatSession constructor called with sessionId:', @sessionId
    
    # 현재 화면이 활성화되어 있음을 표시
    @isActive = true
    @setActiveView('kakao_chat_session')
    
    # 데이터 초기화
    @session = null
    @messages = []
    @agents = []
    @loadingMessages = false
    @sendingMessage = false
    @loadingSession = false
    
    # WebSocket 이벤트 바인딩 (constructor에서만 1회 실행)
    @bindWebSocketEvents()
    
    # 세션 데이터 로드는 show에서만 실행
    #@loadSession()
    
    # 상담원 목록 로드는 show에서만 실행
    #@loadAgents()

  show: (params) =>
    # 화면 진입마다 데이터 초기화 및 Ajax 호출
    @sessionId = params.session_id
    @isActive = true
    @setActiveView('kakao_chat_session')
    @session = null
    @messages = []
    @agents = []
    @loadingMessages = false
    @sendingMessage = false
    @loadingSession = false
    
    # activeView 유지를 위한 주기적 확인
    @startActiveViewMonitor()
    
    # 순차적으로 데이터 로드
    @loadSession().then =>
      @loadMessages()  # 세션 로드 완료 후 메시지 로드
    @loadAgents()
    # WebSocket 이벤트 바인딩은 constructor에서만 하므로 여기서는 제거

  # 세션 데이터 로드
  loadSession: =>
    console.log 'Loading session data for:', @sessionId
    
    # 이미 로딩 중이면 중단
    if @loadingSession
      console.log 'Session loading already in progress, skipping'
      return Promise.resolve()
    
    @loadingSession = true
    
    new Promise((resolve, reject) =>
      App.Ajax.request(
        id: 'kakao_chat_session_show'
        type: 'GET'
        url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}"
        success: (data) =>
          @loadingSession = false
          console.log 'Session data loaded:', data
          @session = data.session
          # loadMessages 호출 제거 - 메시지는 WebSocket 이벤트나 명시적 호출로만 로드
          resolve(data)
        error: (xhr, status, error) =>
          @loadingSession = false
          console.error 'Failed to load session:', error
          @renderError('세션을 불러올 수 없습니다.')
          reject(error)
      )
    )

  # 메시지 목록 로드
  loadMessages: (skipRender = false, isRealTimeUpdate = false) =>
    return unless @sessionId  # sessionId 검증 추가
    
    # Ajax 요청이 이미 진행 중이면 중단
    requestId = "kakao_chat_messages_#{@sessionId}"
    if @loadingMessages
      console.log 'Messages loading already in progress, skipping'
      return
    
    @loadingMessages = true
    console.log 'Loading messages for session:', @sessionId
    console.log 'Current messages count:', @messages?.length || 0
    console.log 'Is real-time update:', isRealTimeUpdate
    
    App.Ajax.request(
      id: requestId
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/messages"
      success: (data) =>
        @loadingMessages = false
        try
          console.log 'Messages loaded:', data
          
          newMessages = data.messages || []
          console.log 'New message count:', newMessages.length
          
          # 실시간 업데이트이고 기존 메시지가 있는 경우 - 새 메시지만 추가
          if isRealTimeUpdate and @messages?.length > 0
            existingIds = @messages.map((msg) -> msg.id)
            addedMessages = newMessages.filter((msg) -> 
              existingIds.indexOf(msg.id) is -1  # 'not in' 대신 indexOf 사용
            )
            
            if addedMessages.length > 0
              console.log 'Found new messages:', addedMessages.length
              @messages = newMessages
              @addNewMessagesToDOM(addedMessages)
              @markMessagesAsRead()
            else
              console.log 'No new messages found'
            return
          
          # 처음 로드이거나 전체 재렌더링
          console.log 'Full message reload'
          @messages = newMessages
          if not skipRender
            @render()
            @markMessagesAsRead()
            
        catch error
          console.error 'Error processing messages:', error
          @renderError('메시지 처리 중 오류가 발생했습니다.')
          
      error: (xhr, status, error) =>
        @loadingMessages = false
        console.error 'Failed to load messages:', error
        console.error 'XHR status:', status
        console.error 'XHR response:', xhr.responseText
        
        # 실시간 업데이트 실패 시에는 에러 화면을 표시하지 않음
        unless isRealTimeUpdate
          @renderError('메시지를 불러올 수 없습니다.')
    )

  # 새 메시지를 DOM에 추가 (스크롤 위치 유지)
  addNewMessagesToDOM: (newMessages) =>
    console.log 'Adding new messages to DOM:', newMessages.length
    
    messagesList = @el.find('.messages-list')
    return unless messagesList.length > 0
    
    # 새 메시지 HTML 생성
    newMessagesHtml = newMessages.map((message) =>
      @renderSingleMessage(message)
    ).join('')
    
    # 기존 메시지 목록에 새 메시지 추가
    if messagesList.find('.no-messages').length > 0
      # "메시지가 없습니다" 메시지가 있으면 제거하고 새 메시지 추가
      messagesList.html(newMessagesHtml)
    else
      # 기존 메시지에 새 메시지 추가
      messagesList.append(newMessagesHtml)
    
    # 메시지 개수 업데이트
    @el.find('.messages-container h3').text("메시지 목록 (#{@messages.length}개)")
    
    # 새 메시지 추가 후 부드럽게 스크롤
    @smoothScrollToBottom()

  # 단일 메시지 HTML 렌더링
  renderSingleMessage: (message) =>
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

  # 부드러운 스크롤
  smoothScrollToBottom: =>
    messagesList = @el.find('.messages-list')
    if messagesList.length > 0
      # 애니메이션을 사용하여 부드럽게 스크롤
      messagesList.animate(
        scrollTop: messagesList[0].scrollHeight
      , 300)  # 300ms 동안 부드럽게 스크롤
      console.log 'Smooth scrolled to bottom of messages'

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
    console.log 'Current activeView before render:', KakaoChatSession.getActiveView()
    
    if not @session
      @renderLoading()
      return
    
    # 메시지 목록 HTML 생성
    messagesList = @messages.map((message) =>
      @renderSingleMessage(message)
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
    
    # 메시지 목록을 맨 아래로 스크롤
    @smoothScrollToBottom()
    
    # 초기 렌더링 완료 후 읽음 처리
    @markMessagesAsRead()

  # 기존 scrollToBottom 메서드 (즉시 스크롤)
  scrollToBottom: =>
    @delay(=>
      messagesList = @el.find('.messages-list')
      if messagesList.length > 0
        messagesList.scrollTop(messagesList[0].scrollHeight)
        console.log 'Scrolled to bottom of messages'
    , 100, 'scroll_to_bottom')

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
    # 기존 이벤트 제거 (중복 방지)
    @el.off('click.kakao-session')
    @el.off('keydown.kakao-session')
    
    # 목록으로 돌아가기
    @el.on('click.kakao-session', '.js-back', (e) =>
      e.preventDefault()
      console.log 'Navigating back to chat list, releasing session view'
      # 명시적으로 상세화면 정리
      @isActive = false
      @setActiveView(null)
      @navigate('#kakao_chat')
    )
    
    # 메시지 전송
    @el.on('click.kakao-session', '.js-send-message', (e) =>
      e.preventDefault()
      @sendMessage()
    )
    
    # Enter 키로 메시지 전송
    @el.on('keydown.kakao-session', '.js-message-input', (e) =>
      if e.keyCode is 13 and not e.shiftKey  # Enter without Shift
        e.preventDefault()
        @sendMessage()
    )
    
    # 상담 종료
    @el.on('click.kakao-session', '.js-end-session', (e) =>
      e.preventDefault()
      @endSession()
    )
    
    # 담당자 변경
    @el.on('click.kakao-session', '.js-assign-agent', (e) =>
      e.preventDefault()
      @assignAgent()
    )

  # 메시지 전송
  sendMessage: =>
    content = @el.find('.js-message-input').val()?.trim()
    return if not content
    
    # 이미 전송 중이면 중단
    if @sendingMessage
      console.log 'Message already being sent, skipping'
      return
    
    @sendingMessage = true
    console.log 'Sending message:', content
    
    App.Ajax.request(
      id: 'kakao_chat_send_message'
      type: 'POST'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/messages"
      data: JSON.stringify(content: content)
      processData: false
      success: (data) =>
        @sendingMessage = false
        console.log 'Message sent successfully:', data
        @el.find('.js-message-input').val('')
        
        # activeView 유지 확인
        if KakaoChatSession.getActiveView() isnt 'kakao_chat_session'
          console.log 'Restoring activeView to kakao_chat_session after message send'
          @setActiveView('kakao_chat_session')
        
        # loadSession 호출 제거 - WebSocket 이벤트가 모든 업데이트를 처리함
        # loadMessages 호출 제거 - WebSocket 이벤트가 자동으로 처리함
      error: (xhr, status, error) =>
        @sendingMessage = false
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
        # loadSession 호출 제거 - WebSocket 이벤트가 세션 정보를 자동으로 업데이트함
        # loadMessages 호출 제거 - WebSocket 이벤트가 자동으로 처리함
      error: (xhr, status, error) =>
        console.error 'Failed to assign agent:', error
        alert('담당자 변경에 실패했습니다.')
    )

  # WebSocket 이벤트 바인딩
  bindWebSocketEvents: =>
    # 새 메시지 수신 시 자동 새로고침
    @controllerBind('kakao_message_received', (data) =>
      console.log 'KakaoChatSession received kakao_message_received:', data
      console.log 'Current session ID:', @sessionId
      console.log 'Current active view:', KakaoChatSession.getActiveView()
      console.log 'Session isActive:', @isActive
      console.log 'Event session ID (data.session_id):', data.session_id
      console.log 'Event session ID (data.data?.session_id):', data.data?.session_id
      
      # 이 컨트롤러가 활성화되어 있고, 현재 세션 상세 화면이며, 해당 세션의 메시지일 때만 처리
      if not @isActive
        console.log 'Ignoring message event - session controller not active'
        return
      
      currentView = KakaoChatSession.getActiveView()
      if currentView isnt 'kakao_chat_session'
        console.log 'Ignoring message event - not in session detail view, current view:', currentView
        console.log 'Attempting to restore activeView to kakao_chat_session'
        @setActiveView('kakao_chat_session')
        # activeView 복원 후 다시 확인
        if KakaoChatSession.getActiveView() isnt 'kakao_chat_session'
          console.log 'Failed to restore activeView, still ignoring event'
          return
        console.log 'Successfully restored activeView, proceeding with event'
      
      # 두 가지 방식으로 세션 ID 확인 (데이터 구조가 다를 수 있음)
      eventSessionId = data.session_id || data.data?.session_id
      console.log 'Final event session ID:', eventSessionId
      
      if eventSessionId is @sessionId
        console.log 'Session ID matches! Loading new messages...'
        
        # 세션 정보도 함께 업데이트 (메시지에 포함된 세션 데이터 사용)
        if data.session
          console.log 'Updating session info from WebSocket data'
          @session = data.session
        
        # 새 메시지만 추가하는 방식으로 로드
        @loadMessages(false, true)
        
        # 현재 세션 상세 화면에 있으므로 자동으로 읽음 처리
        console.log 'Auto-marking messages as read (user viewing session detail)'
        @markMessagesAsRead()
      else
        console.log 'Session ID does not match, ignoring event'
    )
    
    # 메시지 읽음 상태 업데이트
    @controllerBind('kakao_messages_read', (data) =>
      console.log 'KakaoChatSession received kakao_messages_read:', data
      console.log 'Current active view:', KakaoChatSession.getActiveView()
      console.log 'Session isActive:', @isActive
      console.log 'Event data structure - data.data exists?:', !!data.data
      console.log 'Event data structure - data.session_id:', data.session_id
      console.log 'Event data structure - data.data?.session_id:', data.data?.session_id
      
      # 데이터 구조 확인: session_id가 최상위에 있는 경우와 data 안에 있는 경우 모두 처리
      eventSessionId = data.session_id || data.data?.session_id
      console.log 'Extracted session ID:', eventSessionId, 'vs current session:', @sessionId
      
      # 이 컨트롤러가 활성화되어 있고, 해당 세션의 이벤트일 때만 처리
      if @isActive and eventSessionId is @sessionId
        console.log 'Processing messages read event in session detail view'
        console.log 'Messages marked as read by:', data.read_by_agent || data.data?.read_by_agent
        # 필요시 UI 업데이트 (예: 읽음 표시)
        @updateReadStatus(data.data || data)
      else
        console.log 'Ignoring messages read event - not in session detail view or different session'
        console.log 'Conditions: isActive=', @isActive, 'sessionMatch=', (eventSessionId is @sessionId)
    )
    
    # 상담원 할당 알림
    @controllerBind('kakao_agent_assigned', (data) =>
      console.log 'KakaoChatSession received kakao_agent_assigned:', data
      console.log 'Current active view:', KakaoChatSession.getActiveView()
      console.log 'Session isActive:', @isActive
      
      # 이 컨트롤러가 활성화되어 있고, 해당 세션의 이벤트일 때만 처리
      if @isActive and data.data?.session_id is @sessionId
        console.log 'Processing agent assigned event in session detail view'
        console.log 'Agent assigned to session:', data.data.agent_name
        
        # 세션 정보 업데이트 (WebSocket 데이터 사용)
        if data.data.session
          console.log 'Updating session info from agent assignment event'
          @session = data.data.session
        # loadSession 호출 제거 - WebSocket 데이터로 업데이트
      else
        console.log 'Ignoring agent assigned event - not in session detail view or different session'
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

  # 정리 시 활성 뷰 해제
  release: =>
    console.log 'KakaoChatSession release called for session:', @sessionId
    @isActive = false
    @setActiveView(null)
    
    # activeView 모니터 정리
    @stopActiveViewMonitor()
    
    # 모든 delay 취소
    @clearDelay('mark_messages_read')
    @clearDelay('auto_scroll')
    @clearDelay('load_messages')
    
    # 세션 데이터 완전 초기화
    @session = null
    @messages = []
    @agents = []
    @loadingMessages = false
    @sendingMessage = false
    @loadingSession = false

    # 컨트롤러 바인딩 해제 (중복 바인딩 방지)
    @controllerUnbind('kakao_message_received')
    @controllerUnbind('kakao_messages_read')
    @controllerUnbind('kakao_agent_assigned')
    
    console.log 'KakaoChatSession released, isActive:', @isActive, 'activeView:', KakaoChatSession.getActiveView()
    super if super

  # 현재 활성화된 뷰 설정 (전역 상태)
  setActiveView: (viewName) =>
    if window.App
      oldView = window.App.activeKakaoView
      window.App.activeKakaoView = viewName
      console.log "KakaoChatSession setActiveView: #{oldView} -> #{viewName}"
    else
      console.log 'KakaoChatSession setActiveView: window.App not available'
    
  # 현재 활성화된 뷰 확인
  @getActiveView: =>
    window.App?.activeKakaoView || null

  # activeView 모니터링 시작
  startActiveViewMonitor: =>
    # 기존 모니터 정리
    @stopActiveViewMonitor()
    
    # 2초마다 activeView 확인 및 복원
    @activeViewMonitor = setInterval(=>
      if @isActive and KakaoChatSession.getActiveView() isnt 'kakao_chat_session'
        console.log 'ActiveView monitor: restoring kakao_chat_session view'
        @setActiveView('kakao_chat_session')
    , 2000)
    
    console.log 'ActiveView monitor started'

  # activeView 모니터링 중지
  stopActiveViewMonitor: =>
    if @activeViewMonitor
      clearInterval(@activeViewMonitor)
      @activeViewMonitor = null
      console.log 'ActiveView monitor stopped'

  # 메시지 읽음 처리 (디바운스)
  markMessagesAsRead: =>
    return unless @sessionId and @isActive
    
    # 현재 세션 상세 화면에 있을 때만 읽음 처리
    currentView = KakaoChatSession.getActiveView()
    if currentView isnt 'kakao_chat_session'
      console.log 'Skipping mark as read - not in session detail view, current view:', currentView
      console.log 'Attempting to restore activeView for markMessagesAsRead'
      @setActiveView('kakao_chat_session')
      # 복원 후 다시 확인
      if KakaoChatSession.getActiveView() isnt 'kakao_chat_session'
        console.log 'Failed to restore activeView for markMessagesAsRead, skipping'
        return
      console.log 'Successfully restored activeView for markMessagesAsRead'
    
    console.log 'markMessagesAsRead called for session:', @sessionId, 'isActive:', @isActive, 'currentView:', KakaoChatSession.getActiveView()
    
    # 디바운스: 500ms 내에 여러 호출이 있으면 마지막 것만 실행
    @delay(=>
      # 실행 시점에 다시 한번 확인
      if not @isActive or KakaoChatSession.getActiveView() isnt 'kakao_chat_session'
        console.log 'Canceling mark as read - view changed during delay or not in session detail'
        return
        
      console.log 'Executing delayed mark messages as read for session:', @sessionId
      
      App.Ajax.request(
        id: 'kakao_chat_mark_read'
        type: 'POST'
        url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/read"
        success: (data) =>
          console.log 'Messages marked as read successfully:', data
          if data.read_count > 0
            console.log "Marked #{data.read_count} messages as read, new unread count: #{data.unread_count}"
        error: (xhr, status, error) =>
          console.error 'Failed to mark messages as read:', error
          console.error 'Response:', xhr.responseText if xhr.responseText
      )
    , 500, 'mark_messages_read')

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
