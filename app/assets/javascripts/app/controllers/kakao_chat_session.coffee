class KakaoChatSession extends App.ControllerSubContent
  header: __('카카오톡 상담 세션')
  
  constructor: (params) ->
    super
    
    # 세션 ID 추출
    @sessionId = params.session_id
    console.log 'KakaoChatSession constructor called with sessionId:', @sessionId
    
    # 현재 화면이 활성화되어 있음을 표시
    @isActive = true
    @internalView = 'kakao_chat_session'  # 내부 상태만 관리, 네비게이션은 별도
    
    # 데이터 초기화
    @session = null
    @messages = []
    @agents = []
    @loadingMessages = false
    @sendingMessage = false
    @loadingSession = false
    
    # WebSocket 이벤트 바인딩 (constructor에서만 1회 실행)
    @bindWebSocketEvents()
    
    # menu:render 이벤트 바인딩 - 네비게이션 하이라이트 유지
    @controllerBind('menu:render', =>
      if @isActive and @internalView is 'kakao_chat_session'
        console.log 'KakaoChatSession menu:render event - maintaining navigation highlight'
        # 세션 상세 화면에서는 카카오톡 상담 메뉴 하이라이트 유지
        @delay(=>
          @navupdate '#kakao_chat'
        , 10, 'nav_highlight_maintain')
    )
    
    # 세션 데이터 로드는 show에서만 실행
    #@loadSession()
    
    # 상담원 목록 로드는 show에서만 실행
    #@loadAgents()

  show: (params) =>
    # 화면 진입마다 데이터 초기화 및 Ajax 호출
    @sessionId = params.session_id
    @isActive = true
    @internalView = 'kakao_chat_session'  # 내부 상태만 관리
    @session = null
    @messages = []
    @agents = []
    @loadingMessages = false
    @sendingMessage = false
    @loadingSession = false
    @selectedFiles = []  # 선택된 파일들을 별도로 관리
    
    # 전역 activeView를 세션 상세로 설정 (읽음 처리를 위해)
    @setNavigationHighlight('kakao_chat_session')
    
    # 네비게이션 하이라이트 설정
    @title __('카카오톡 상담 세션'), true
    @navupdate '#kakao_chat'
    
    # activeView 유지를 위한 주기적 확인 제거 (불필요한 중복 호출 방지)
    # @startActiveViewMonitor()
    
    # 순차적으로 데이터 로드
    @loadSession().then =>
      @loadMessages()  # 세션 로드 완료 후 메시지 로드
    @loadAgents()
    # WebSocket 이벤트 바인딩은 constructor에서만 하므로 여기서는 제거

  # 안전한 사운드 재생
  playNotificationSound: =>
    try
      console.log 'Playing KakaoTalk notification sound in session view'
      App.Audio.play('assets/sounds/chat_new.mp3', 0.3)
    catch error
      console.log 'Error in playNotificationSound in session view:', error

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
              # 실시간 업데이트에서는 읽음 처리를 하지 않음 (세션 상세 화면에서만)
              globalActiveView = KakaoChatSession.getActiveView()
              if not isRealTimeUpdate and @internalView is 'kakao_chat_session' and globalActiveView isnt 'kakao_chat_list'
                @markMessagesAsRead()
            else
              console.log 'No new messages found'
            return
          
          # 처음 로드이거나 전체 재렌더링
          console.log 'Full message reload'
          @messages = newMessages
          if not skipRender
            @render()
            # 세션 상세 화면에서만 읽음 처리 - 전역 activeView도 확인
            globalActiveView = KakaoChatSession.getActiveView()
            if @internalView is 'kakao_chat_session' and globalActiveView isnt 'kakao_chat_list'
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
    
    # 파일 첨부 렌더링
    fileContent = if message.has_attachments and message.files?.length > 0
      @renderMessageFiles(message.files)
    else
      ''
    
    """
    <div class="message message-#{senderClass} #{alignmentClass}" style="margin: 1px 0; padding: 1px 2px;">
      <div class="message-bubble" style="padding: 2px 4px; border-radius: 3px;">
        <div class="message-header" style="font-size: 11px; opacity: 0.7; margin: 0; padding: 0; display: flex; justify-content: space-between; align-items: center; height: 12px;">
          <span class="sender">#{message.sender_name || message.sender_type}</span>
          <span class="time">#{timeStr}</span>
        </div>
        <div class="message-content" style="margin: 0; padding: 0; line-height: 1.2; font-size: 12px; word-wrap: break-word; overflow-wrap: break-word;">
          #{if message.content and message.content.trim() then App.Utils.htmlEscape(message.content) else ''}
          #{fileContent}
        </div>
      </div>
    </div>
    """

  # 메시지 파일 렌더링
  renderMessageFiles: (files) =>
    return '' unless files?.length > 0
    
    filesHtml = files.map((file) =>
      @renderSingleFile(file)
    ).join('')
    
    """
    <div class="message-files" style="margin-top: 4px;">
      #{filesHtml}
    </div>
    """

  # 단일 파일 렌더링
  renderSingleFile: (file) =>
    fileIcon = @getFileIcon(file.file_category, file.content_type)
    
    if file.file_category is 'image'
      # 이미지 파일은 썸네일 표시
      """
      <img src="#{file.thumbnail_url}" alt="#{file.filename}" 
        style="max-width: 150px; max-height: 150px; border: 1px solid #ddd; cursor: pointer; border-radius: 2px;" 
        class="js-image-preview" data-file-id="#{file.id}" data-download-url="#{file.download_url}">
      """
    else if file.file_category is 'video'
      # 동영상 파일
      """
      <div class="file-item video-file" style="margin: 2px 0; padding: 4px; border: 1px solid #ddd; border-radius: 3px;">
        <div class="file-header" style="display: flex; align-items: center;">
          <span class="file-icon" style="font-size: 16px; margin-right: 4px;">#{fileIcon}</span>
          <div class="file-details" style="flex: 1;">
            <div class="file-name" style="font-size: 11px; font-weight: bold;">#{App.Utils.htmlEscape(file.filename)}</div>
            <div class="file-meta" style="font-size: 10px; color: #666;">
              동영상 • #{file.file_size_human}
              #{if file.metadata?.resolution then ' • ' + file.metadata.resolution else ''}
            </div>
          </div>
        </div>
        <div class="file-actions" style="margin-top: 4px; text-align: center;">
          <a href="#{file.download_url}" class="btn btn--secondary btn--small" target="_blank">다운로드</a>
        </div>
      </div>
      """
    else
      # 기타 파일 (문서, 아카이브 등)
      """
      <div class="file-item document-file" style="margin: 2px 0; padding: 4px; border: 1px solid #ddd; border-radius: 3px;">
        <div class="file-header" style="display: flex; align-items: center;">
          <span class="file-icon" style="font-size: 16px; margin-right: 4px;">#{fileIcon}</span>
          <div class="file-details" style="flex: 1;">
            <div class="file-name" style="font-size: 11px; font-weight: bold;">#{App.Utils.htmlEscape(file.filename)}</div>
            <div class="file-meta" style="font-size: 10px; color: #666;">#{@getFileTypeLabel(file.file_category)} • #{file.file_size_human}</div>
          </div>
        </div>
        <div class="file-actions" style="margin-top: 4px; text-align: center;">
          <a href="#{file.download_url}" class="btn btn--secondary btn--small" target="_blank">다운로드</a>
        </div>
      </div>
      """

  # 파일 아이콘 반환
  getFileIcon: (category, contentType) =>
    switch category
      when 'image' then '🖼️'
      when 'video' then '🎥'
      when 'audio' then '🎵'
      when 'document'
        if contentType.includes('pdf') then '📄'
        else if contentType.includes('word') then '📝'
        else if contentType.includes('excel') or contentType.includes('sheet') then '📊'
        else if contentType.includes('powerpoint') or contentType.includes('presentation') then '📊'
        else '📄'
      when 'archive' then '📦'
      else '📎'

  # 파일 타입 레이블 반환
  getFileTypeLabel: (category) =>
    switch category
      when 'image' then '이미지'
      when 'video' then '동영상'
      when 'audio' then '오디오'
      when 'document' then '문서'
      when 'archive' then '압축파일'
      else '파일'

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
    
    # 세션 상세 화면에서만 읽음 처리 - 전역 activeView도 확인
    globalActiveView = KakaoChatSession.getActiveView()
    if @internalView is 'kakao_chat_session' and globalActiveView isnt 'kakao_chat_list'
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
        <div class="input-area">
          <textarea class="js-message-input" placeholder="#{placeholder}" rows="3"></textarea>
          <div class="file-upload-area">
            <input type="file" class="js-file-input" multiple accept="image/*,video/*,audio/*,.pdf,.txt,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.zip,.rar,.7z,.gz" style="display: none;">
            <div class="file-preview js-file-preview" style="display: none;"></div>
          </div>
        </div>
        <div class="form-actions">
          <button class="btn btn--secondary js-attach-file" title="파일 첨부">📎 파일</button>
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
    @el.off('change.kakao-session')
    @el.off('paste.kakao-session')
    @el.off('dragover.kakao-session')
    @el.off('drop.kakao-session')
    
    # 목록으로 돌아가기
    @el.on('click.kakao-session', '.js-back', (e) =>
      e.preventDefault()
      console.log 'Navigating back to chat list, releasing session view'
      # 명시적으로 상세화면 정리
      @isActive = false
      @internalView = null
      @setNavigationHighlight('kakao_chat_list')  # 목록으로 돌아갈 때 전역 activeView 변경
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
    
    # 파일 첨부 버튼
    @el.on('click.kakao-session', '.js-attach-file', (e) =>
      e.preventDefault()
      @el.find('.js-file-input').click()
    )
    
    # 파일 선택
    @el.on('change.kakao-session', '.js-file-input', (e) =>
      @handleFileSelection(e.target.files)
    )
    
    # 클립보드 붙여넣기 (이미지)
    @el.on('paste.kakao-session', '.js-message-input', (e) =>
      @handlePaste(e.originalEvent)
    )
    
    # 드래그 앤 드롭
    @el.on('dragover.kakao-session', '.message-input-form', (e) =>
      e.preventDefault()
      e.stopPropagation()
      $(e.currentTarget).addClass('drag-over')
    )
    
    @el.on('dragleave.kakao-session', '.message-input-form', (e) =>
      e.preventDefault()
      e.stopPropagation()
      $(e.currentTarget).removeClass('drag-over')
    )
    
    @el.on('drop.kakao-session', '.message-input-form', (e) =>
      e.preventDefault()
      e.stopPropagation()
      $(e.currentTarget).removeClass('drag-over')
      
      files = e.originalEvent.dataTransfer.files
      if files.length > 0
        @handleFileSelection(files)
    )
    
    # 이미지 미리보기 클릭
    @el.on('click.kakao-session', '.js-image-preview', (e) =>
      e.preventDefault()
      @showImageModal($(e.currentTarget))
    )
    
    # 파일 미리보기 제거
    @el.on('click.kakao-session', '.js-remove-file', (e) =>
      e.preventDefault()
      @removeFilePreview($(e.currentTarget))
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

  # 기존 scrollToBottom 메서드 (즉시 스크롤)
  scrollToBottom: =>
    @delay(=>
      messagesList = @el.find('.messages-list')
      if messagesList.length > 0
        messagesList.scrollTop(messagesList[0].scrollHeight)
        console.log 'Scrolled to bottom of messages'
    , 100, 'scroll_to_bottom')

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

  # 파일 선택 처리
  handleFileSelection: (files) =>
    return unless files?.length > 0
    
    # 선택된 파일들을 배열로 변환
    fileArray = Array.from(files)
    
    # 파일 개수 제한 (최대 5개)
    if fileArray.length > 5
      alert('한 번에 최대 5개의 파일만 업로드할 수 있습니다.')
      return
    
    # 각 파일 검증 및 미리보기 생성
    validFiles = []
    for file in fileArray
      validation = @validateFile(file)
      if validation.valid
        validFiles.push(file)
      else
        alert("파일 '#{file.name}': #{validation.error}")
    
    if validFiles.length > 0
      @selectedFiles = validFiles  # 선택된 파일들을 인스턴스 변수에 저장
      @showFilePreview(validFiles)

  # 클립보드 붙여넣기 처리
  handlePaste: (event) =>
    return unless event.clipboardData?.items
    
    files = []
    for item in event.clipboardData.items
      if item.type.indexOf('image') is 0
        file = item.getAsFile()
        if file
          # 클립보드 이미지에 파일명이 없는 경우 자동 생성
          if not file.name or file.name is 'image.png'
            timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
            extension = switch item.type
              when 'image/png' then 'png'
              when 'image/jpeg' then 'jpg'
              when 'image/gif' then 'gif'
              when 'image/webp' then 'webp'
              else 'png'
            
            # File 객체를 새로 생성하여 파일명 설정
            newFile = new File([file], "clipboard-image-#{timestamp}.#{extension}", {
              type: file.type
              lastModified: file.lastModified
            })
            files.push(newFile)
          else
            files.push(file)
    
    if files.length > 0
      console.log 'Pasted images:', files.map((f) -> f.name)
      @handleFileSelection(files)

  # 파일 검증
  validateFile: (file) =>
    # 파일 크기 검증 (10MB)
    maxSize = 10 * 1024 * 1024  # 10MB
    if file.size > maxSize
      return { valid: false, error: '파일 크기가 10MB를 초과합니다.' }
    
    # 파일 확장자 검증
    allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg',
                        'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv',
                        'mp3', 'wav', 'aac', 'ogg', 'm4a', 'wma',
                        'pdf', 'txt', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
                        'zip', 'rar', '7z', 'gz']
    
    extension = file.name.split('.').pop()?.toLowerCase()
    unless extension in allowedExtensions
      return { valid: false, error: '지원하지 않는 파일 형식입니다.' }
    
    { valid: true }

  # 파일 미리보기 표시
  showFilePreview: (files) =>
    previewArea = @el.find('.js-file-preview')
    previewArea.show()
    
    # 기존 미리보기 초기화
    previewArea.empty()
    
    for file, index in files
      previewItem = @createFilePreviewItem(file, index)
      previewArea.append(previewItem)
    
    # 전송 버튼 텍스트 변경
    @el.find('.js-send-message').text("파일 전송 (#{files.length}개)")

  # 파일 미리보기 아이템 생성
  createFilePreviewItem: (file, index) =>
    fileType = @getFileTypeFromName(file.name)
    fileIcon = @getFileIcon(fileType, file.type)
    
    # 이미지 파일인 경우 썸네일 생성
    if file.type.startsWith('image/')
      reader = new FileReader()
      reader.onload = (e) =>
        @el.find(".file-preview-item[data-index='#{index}'] .file-thumbnail img").attr('src', e.target.result)
      reader.readAsDataURL(file)
      
      thumbnailHtml = '<img style="max-width: 80px; max-height: 80px; object-fit: cover;">'
    else
      thumbnailHtml = "<span style='font-size: 24px;'>#{fileIcon}</span>"
    
    """
    <div class="file-preview-item" data-index="#{index}" style="display: inline-block; margin: 4px; padding: 6px; border: 1px solid #ddd; border-radius: 4px; background: #f9f9f9; position: relative;">
      <button class="js-remove-file" data-index="#{index}" style="position: absolute; top: -5px; right: -5px; background: #ff4444; color: white; border: none; border-radius: 50%; width: 18px; height: 18px; font-size: 12px; cursor: pointer;">×</button>
      <div class="file-thumbnail" style="text-align: center; margin-bottom: 4px;">
        #{thumbnailHtml}
      </div>
      <div class="file-name" style="font-size: 10px; max-width: 80px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="#{file.name}">
        #{file.name}
      </div>
      <div class="file-size" style="font-size: 9px; color: #666; text-align: center;">
        #{@formatFileSize(file.size)}
      </div>
    </div>
    """

  # 파일 미리보기 제거
  removeFilePreview: (button) =>
    index = button.data('index')
    button.closest('.file-preview-item').remove()
    
    # selectedFiles에서도 해당 파일 제거
    if @selectedFiles and index >= 0 and index < @selectedFiles.length
      @selectedFiles.splice(index, 1)
    
    # 남은 파일 개수 확인
    remaining = @el.find('.file-preview-item').length
    if remaining is 0
      @el.find('.js-file-preview').hide()
      @el.find('.js-send-message').text('전송')
      @el.find('.js-file-input').val('')  # 파일 입력 초기화
      @selectedFiles = []  # 선택된 파일 목록 초기화
    else
      @el.find('.js-send-message').text("파일 전송 (#{remaining}개)")

  # 파일 타입 추출
  getFileTypeFromName: (filename) =>
    extension = filename.split('.').pop()?.toLowerCase()
    
    imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg']
    videoExts = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv']
    audioExts = ['mp3', 'wav', 'aac', 'ogg', 'm4a', 'wma']
    docExts = ['pdf', 'txt', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']
    archiveExts = ['zip', 'rar', '7z', 'gz']
    
    if extension in imageExts then 'image'
    else if extension in videoExts then 'video'
    else if extension in audioExts then 'audio'
    else if extension in docExts then 'document'
    else if extension in archiveExts then 'archive'
    else 'other'

  # 파일 크기 포맷팅
  formatFileSize: (bytes) =>
    if bytes is 0 then return '0 Bytes'
    
    k = 1024
    sizes = ['Bytes', 'KB', 'MB', 'GB']
    i = Math.floor(Math.log(bytes) / Math.log(k))
    
    parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i]

  # 이미지 모달 표시
  showImageModal: (imageElement) =>
    fileId = imageElement.data('file-id')
    downloadUrl = imageElement.data('download-url')
    
    # 모달 HTML 생성
    modalHtml = """
    <div class="image-modal-backdrop" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); z-index: 9999; display: flex; align-items: center; justify-content: center;">
      <div class="image-modal-content" style="position: relative; max-width: 90%; max-height: 90%; background: white; border-radius: 4px; padding: 20px;">
        <button class="modal-close" style="position: absolute; top: 10px; right: 10px; background: none; border: none; font-size: 24px; cursor: pointer; color: #666;">×</button>
        <img src="#{downloadUrl}" style="max-width: 100%; max-height: 70vh; object-fit: contain;">
        <div class="modal-actions" style="text-align: center; margin-top: 15px;">
          <a href="#{downloadUrl}" class="btn btn--primary" download>다운로드</a>
        </div>
      </div>
    </div>
    """
    
    # 모달을 body에 추가
    $('body').append(modalHtml)
    
    # 모달 닫기 이벤트
    $('.image-modal-backdrop').on('click', (e) =>
      if e.target is e.currentTarget or $(e.target).hasClass('modal-close')
        $('.image-modal-backdrop').remove()
    )

  # 메시지 전송 (수정: 파일 첨부 지원)
  sendMessage: =>
    content = @el.find('.js-message-input').val()?.trim()
    files = @getSelectedFiles()
    
    # 텍스트와 파일 둘 다 없으면 전송하지 않음
    return if not content and files.length is 0
    
    # 이미 전송 중이면 중단
    if @sendingMessage
      console.log 'Message already being sent, skipping'
      return
    
    @sendingMessage = true
    console.log 'Sending message with files:', content, files
    
    # 파일이 있으면 파일 업로드, 없으면 텍스트 메시지 전송
    if files.length > 0
      @uploadFiles(files, content)
    else
      @sendTextMessage(content)

  # 선택된 파일들 가져오기
  getSelectedFiles: =>
    # 먼저 인스턴스 변수에 저장된 파일들 확인 (클립보드, 드래그앤드롭)
    if @selectedFiles?.length > 0
      return @selectedFiles
    
    # 파일 input에서 선택된 파일들 확인
    fileInput = @el.find('.js-file-input')[0]
    if fileInput?.files?.length > 0
      return Array.from(fileInput.files)
    
    return []

  # 텍스트 메시지 전송
  sendTextMessage: (content) =>
    # 대기중 세션에서 첫 메시지인지 확인
    isFirstMessageInWaitingSession = @session?.status is 'waiting'
    
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
        
        # 대기중 세션에서 첫 메시지 전송 시 세션 정보 업데이트
        if isFirstMessageInWaitingSession
          console.log 'First message sent in waiting session, updating session info...'
          @loadSession().then =>
            console.log 'Session info updated after first message'
            @render()  # 상태 변경을 반영하여 화면 재렌더링
        
        # 메시지 전송 완료 - WebSocket 이벤트가 추가 업데이트를 자동으로 처리함
      error: (xhr, status, error) =>
        @sendingMessage = false
        console.error 'Failed to send message:', error
        alert('메시지 전송에 실패했습니다.')
    )

  # 파일 업로드
  uploadFiles: (files, content = '') =>
    formData = new FormData()
    
    # 파일들 추가
    for file in files
      formData.append('file', file)
    
    # 메시지 내용 추가 (선택사항)
    if content
      formData.append('content', content)
    
    $.ajax(
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{@sessionId}/upload"
      type: 'POST'
      data: formData
      processData: false
      contentType: false
      headers:
        'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')
      success: (data) =>
        @sendingMessage = false
        console.log 'Files uploaded successfully:', data
        
        # 입력 필드 초기화
        @el.find('.js-message-input').val('')
        @el.find('.js-file-input').val('')
        @el.find('.js-file-preview').hide().empty()
        @el.find('.js-send-message').text('전송')
        
        # 선택된 파일 목록 초기화
        @selectedFiles = []
        
        # WebSocket 이벤트가 새 메시지를 자동으로 추가함
      error: (xhr, status, error) =>
        @sendingMessage = false
        console.error 'Failed to upload files:', error
        
        try
          response = JSON.parse(xhr.responseText)
          alert("파일 업로드 실패: #{response.error}")
        catch
          alert('파일 업로드에 실패했습니다.')
    )

  # WebSocket 이벤트 바인딩
  bindWebSocketEvents: =>
    # 새 메시지 수신 시 자동 새로고침
    @controllerBind('kakao_message_received', (data) =>
      console.log 'KakaoChatSession received kakao_message_received:', data
      console.log 'Current session ID:', @sessionId
      console.log 'Current active view:', KakaoChatSession.getActiveView()
      console.log 'Session isActive:', @isActive
      console.log 'Internal view:', @internalView
      console.log 'Event session ID (data.session_id):', data.session_id
      console.log 'Event session ID (data.data?.session_id):', data.data?.session_id
      
      # 이 컨트롤러가 활성화되어 있고, 내부적으로 세션 상세 화면이며, 해당 세션의 메시지일 때만 처리
      if not @isActive or @internalView isnt 'kakao_chat_session'
        console.log 'Ignoring message event - session controller not active or not in session detail view'
        return
      
      # 두 가지 방식으로 세션 ID 확인 (데이터 구조가 다를 수 있음)
      eventSessionId = data.session_id || data.data?.session_id
      console.log 'Final event session ID:', eventSessionId
      
      if eventSessionId is @sessionId
        console.log 'Session ID matches! Loading new messages...'
        
        # 새 메시지 수신 시 사운드 재생 (자신이 보낸 메시지가 아닌 경우)
        if not data.self_written
          @playNotificationSound()
        
        # 세션 정보도 함께 업데이트 (메시지에 포함된 세션 데이터 사용)
        if data.session
          console.log 'Updating session info from WebSocket data'
          @session = data.session
        
        # 새 메시지만 추가하는 방식으로 로드
        @loadMessages(false, true)
        
        # 현재 세션 상세 화면에서만 자동으로 읽음 처리 - 전역 activeView도 확인
        globalActiveView = KakaoChatSession.getActiveView()
        if @isActive and @internalView is 'kakao_chat_session' and @sessionId is eventSessionId and globalActiveView isnt 'kakao_chat_list'
          console.log 'Auto-marking messages as read (user viewing session detail)'
          console.log 'Before markMessagesAsRead - isActive:', @isActive, 'internalView:', @internalView, 'sessionId:', @sessionId, 'globalActiveView:', globalActiveView
          @markMessagesAsRead()
        else
          console.log 'Skipping auto-read marking - not in session detail view or not active'
          console.log 'Conditions: isActive=', @isActive, 'internalView=', @internalView, 'sessionMatch=', (@sessionId is eventSessionId), 'globalActiveView=', globalActiveView
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
      
      # 이 컨트롤러가 활성화되어 있고, 해당 세션의 이벤트일 때만 처리 - 전역 activeView도 확인
      globalActiveView = KakaoChatSession.getActiveView()
      if @isActive and eventSessionId is @sessionId and globalActiveView isnt 'kakao_chat_list'
        console.log 'Processing messages read event in session detail view'
        console.log 'Messages marked as read by:', data.read_by_agent || data.data?.read_by_agent
        # 필요시 UI 업데이트 (예: 읽음 표시)
        @updateReadStatus(data.data || data)
      else
        console.log 'Ignoring messages read event - not in session detail view or different session'
        console.log 'Conditions: isActive=', @isActive, 'sessionMatch=', (eventSessionId is @sessionId), 'globalActiveView=', globalActiveView
    )
    
    # 상담원 할당 알림
    @controllerBind('kakao_agent_assigned', (data) =>
      console.log 'KakaoChatSession received kakao_agent_assigned:', data
      console.log 'Current active view:', KakaoChatSession.getActiveView()
      console.log 'Session isActive:', @isActive
      
      # 이 컨트롤러가 활성화되어 있고, 해당 세션의 이벤트일 때만 처리 - 전역 activeView도 확인
      globalActiveView = KakaoChatSession.getActiveView()
      if @isActive and data.data?.session_id is @sessionId and globalActiveView isnt 'kakao_chat_list'
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
    @internalView = null
    @setNavigationHighlight('kakao_chat_list')  # 목록으로 되돌리기
    
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
    
    console.log 'KakaoChatSession released, isActive:', @isActive, 'internalView:', @internalView
    super if super

  # 네비게이션 하이라이트 설정 (네비게이션 바에서만 사용)
  setNavigationHighlight: (viewName) =>
    if window.App
      oldView = window.App.activeKakaoView
      window.App.activeKakaoView = viewName
      console.log "KakaoChatSession setNavigationHighlight: #{oldView} -> #{viewName}"
    else
      console.log 'KakaoChatSession setNavigationHighlight: window.App not available'
    
  # 현재 활성화된 뷰 확인
  @getActiveView: =>
    window.App?.activeKakaoView || null

  # 메시지 읽음 처리 (디바운스) - 전역 activeView도 확인
  markMessagesAsRead: =>
    console.log 'markMessagesAsRead called - sessionId:', @sessionId, 'isActive:', @isActive, 'internalView:', @internalView
    
    if not @sessionId
      console.log 'markMessagesAsRead skipped - no sessionId'
      return
      
    if not @isActive
      console.log 'markMessagesAsRead skipped - not active'
      return
      
    if @internalView isnt 'kakao_chat_session'
      console.log 'markMessagesAsRead skipped - not in session detail view, current internalView:', @internalView
      return
      
    # 전역 activeView가 목록 화면이면 읽음 처리하지 않음
    globalActiveView = KakaoChatSession.getActiveView()
    if globalActiveView is 'kakao_chat_list'
      console.log 'markMessagesAsRead skipped - global activeView is chat list:', globalActiveView
      return
    
    console.log 'markMessagesAsRead proceeding for session:', @sessionId
    
    # 디바운스: 500ms 내에 여러 호출이 있으면 마지막 것만 실행
    @delay(=>
      # 실행 시점에 다시 한번 확인 - internalView와 전역 activeView 모두 확인
      globalActiveView = KakaoChatSession.getActiveView()
      if not @isActive or @internalView isnt 'kakao_chat_session' or globalActiveView is 'kakao_chat_list'
        console.log 'Canceling mark as read - view changed during delay or not in session detail'
        console.log 'Current state: isActive=', @isActive, 'internalView=', @internalView, 'globalActiveView=', globalActiveView
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