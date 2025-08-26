class KakaoChat extends App.ControllerSubContent
  @requiredPermission: 'admin'
  header: __('카카오톡 상담')
  
  elements:
    '.js-chatList': 'chatList'
    '.js-chatContent': 'chatContent'
    '.js-messageInput': 'messageInput'
    '.js-sendButton': 'sendButton'

  events:
    'click .js-chatItem': 'selectChat'
    'click .js-sendButton': 'sendMessage'
    'keypress .js-messageInput': 'handleKeyPress'
    'click .js-endChat': 'endChat'
    'click .js-refreshList': 'refreshChatList'

  constructor: (params) ->
    console.log 'KakaoChat constructor called with params:', params
    super
    
    @activeChatId = null
    @chats = {}
    @polling = null
    
    @render()
    @startPolling()

  render: =>
    @html @renderIndex()
    @loadChatList()

  renderIndex: =>
    '''
    <div class="page-header">
      <div class="page-header-title">
        <h1>
          <svg class="icon icon-message-circle"><use xlink:href="#icon-message-circle"></use></svg>
          카카오톡 상담
        </h1>
      </div>
      <div class="page-header-meta">
        <a class="btn btn--success btn--create js-refreshList" href="#" title="새로고침">
          <svg class="icon icon-arrow-clockwise"><use xlink:href="#icon-arrow-clockwise"></use></svg>
          새로고침
        </a>
      </div>
    </div>

    <div class="page-content">
      <div class="flex horizontal">
        <div class="sidebar sidebar--left" style="width: 300px; min-width: 280px;">
          <div class="sidebar-header">
            <h3>활성 상담 목록</h3>
          </div>
          <div class="sidebar-content js-chatList">
            <div class="text-center text-muted" style="padding: 20px;">
              상담 목록을 불러오는 중...
            </div>
          </div>
        </div>

        <div class="main-content js-chatContent">
          <div class="text-center text-muted" style="padding: 40px;">
            <svg class="icon icon-message-circle" style="width: 48px; height: 48px;"><use xlink:href="#icon-message-circle"></use></svg>
            <p>상담을 선택하여 채팅을 시작하세요</p>
          </div>
        </div>
      </div>
    </div>
    '''

  loadChatList: =>
    # 상담톡 API 서버에서 활성 상담 목록 조회
    @ajax(
      id: 'kakao_chat_list'
      type: 'GET'
      url: "#{@apiPath}/kakao_chat/sessions"
      success: (data) =>
        @updateChatList(data.sessions || [])
      error: (xhr, status, error) =>
        @notify(
          type: 'error'
          msg: __('상담 목록을 불러올 수 없습니다.')
        )
        # 데모 데이터로 대체
        @updateChatList(@getDemoSessions())
    )

  getDemoSessions: =>
    [
      {
        id: 'demo_001'
        customer_name: '고객1'
        last_message: '안녕하세요. 문의사항이 있습니다.'
        created_at: '2025-08-13 15:30'
        status: 'active'
      }
      {
        id: 'demo_002'
        customer_name: '고객2'
        last_message: '상품 문의드립니다.'
        created_at: '2025-08-13 16:15'
        status: 'active'
      }
    ]

  updateChatList: (sessions) =>
    @chats = {}
    for session in sessions
      @chats[session.id] = session

    html = @renderChatList(sessions)
    @chatList.html html

  renderChatList: (sessions) =>
    if sessions.length is 0
      return '''
        <div class="text-center text-muted" style="padding: 20px;">
          활성 상담이 없습니다
        </div>
      '''

    html = ''
    for session in sessions
      activeClass = if session.id is @activeChatId then 'is-active' else ''
      customerName = session.customer_name || '익명'
      lastMessage = session.last_message || '상담 시작'
      
      html += """
        <div class="sidebar-item js-chatItem #{activeClass}" data-chat-id="#{session.id}" style="cursor: pointer; padding: 12px; border-bottom: 1px solid #eee;">
          <div class="sidebar-item-content">
            <div class="sidebar-item-header" style="display: flex; justify-content: space-between; align-items: center;">
              <h4 style="margin: 0; font-size: 14px; font-weight: bold;">#{customerName}</h4>
              <span class="text-muted small">#{session.created_at}</span>
            </div>
            <div class="sidebar-item-text text-muted" style="margin-top: 4px; font-size: 12px; color: #666;">
              #{lastMessage}
            </div>
          </div>
        </div>
      """
    
    return html

  selectChat: (e) =>
    e.preventDefault()
    chatId = $(e.currentTarget).data('chat-id')
    return if chatId is @activeChatId
    
    @activeChatId = chatId
    @updateChatSelection()
    @loadChatMessages(chatId)

  updateChatSelection: =>
    @chatList.find('.js-chatItem').removeClass('is-active')
    @chatList.find(".js-chatItem[data-chat-id='#{@activeChatId}']").addClass('is-active')

  loadChatMessages: (chatId) =>
    return unless chatId
    
    @ajax(
      id: "kakao_chat_messages_#{chatId}"
      type: 'GET'
      url: "#{@apiPath}/kakao_chat/sessions/#{chatId}/messages"
      success: (data) =>
        @updateChatContent(data.messages || [], chatId)
      error: =>
        @notify(
          type: 'error'
          msg: __('메시지를 불러올 수 없습니다.')
        )
        # 데모 데이터로 대체
        @updateChatContent(@getDemoMessages(chatId), chatId)
    )

  getDemoMessages: (chatId) =>
    [
      {
        id: 'msg_001'
        content: '안녕하세요. 문의사항이 있습니다.'
        sender: 'customer'
        created_at: '15:30'
      }
      {
        id: 'msg_002'
        content: '안녕하세요. 어떤 문의사항인가요?'
        sender: 'agent'
        created_at: '15:31'
      }
    ]

  updateChatContent: (messages, chatId) =>
    chat = @chats[chatId]
    return unless chat

    html = @renderChatContent(chat, messages)
    @chatContent.html html
    
    # 스크롤을 맨 아래로
    @chatContent.find('.js-messagesList').scrollTop(99999)

  renderChatContent: (chat, messages) =>
    customerName = chat.customer_name || '익명'
    
    messagesHtml = ''
    if messages && messages.length > 0
      for message in messages
        senderClass = if message.sender is 'customer' then 'message--customer' else 'message--agent'
        messagesHtml += """
          <div class="message #{senderClass}" style="margin-bottom: 12px;">
            <div class="message-content">
              <div class="message-bubble" style="padding: 8px 12px; border-radius: 8px; background: #{if message.sender is 'customer' then '#f1f1f1' else '#007bff'}; color: #{if message.sender is 'customer' then '#333' else '#fff'};">
                #{message.content}
              </div>
              <div class="message-time" style="font-size: 11px; color: #999; margin-top: 4px;">
                #{message.created_at}
              </div>
            </div>
          </div>
        """
    else
      messagesHtml = '''
        <div class="text-center text-muted" style="padding: 20px;">
          메시지가 없습니다.
        </div>
      '''

    return """
      <div class="chat-header" style="padding: 16px; border-bottom: 1px solid #eee; background: #f8f9fa;">
        <div class="chat-header-info">
          <h3 style="margin: 0; font-size: 18px;">#{customerName}</h3>
          <span class="text-muted">상담 진행 중</span>
        </div>
        <div class="chat-header-actions" style="margin-top: 8px;">
          <button class="btn btn--danger btn--small js-endChat">
            상담 종료
          </button>
        </div>
      </div>

      <div class="chat-messages js-messagesList" style="flex: 1; padding: 16px; overflow-y: auto; max-height: 400px;">
        #{messagesHtml}
      </div>

      <div class="chat-input" style="padding: 16px; border-top: 1px solid #eee; background: #f8f9fa;">
        <div class="form-group" style="margin: 0;">
          <div class="input-group">
            <textarea class="form-control js-messageInput" rows="2" placeholder="메시지를 입력하세요..." style="resize: none;"></textarea>
            <div class="input-group-append" style="margin-left: 8px;">
              <button class="btn btn--primary js-sendButton" type="button">
                전송
              </button>
            </div>
          </div>
        </div>
      </div>
    """

  sendMessage: (e) =>
    e.preventDefault()
    return unless @activeChatId
    
    message = @messageInput.val().trim()
    return unless message
    
    # 메시지 전송
    @ajax(
      id: "kakao_send_message_#{@activeChatId}"
      type: 'POST'
      url: "#{@apiPath}/kakao_chat/sessions/#{@activeChatId}/messages"
      data:
        content: message
      success: (data) =>
        @messageInput.val('')
        @loadChatMessages(@activeChatId)
      error: =>
        @notify(
          type: 'error'
          msg: __('메시지 전송에 실패했습니다.')
        )
    )

  handleKeyPress: (e) =>
    if e.which is 13 and not e.shiftKey
      e.preventDefault()
      @sendMessage(e)

  endChat: (e) =>
    e.preventDefault()
    return unless @activeChatId
    
    @ajax(
      id: "kakao_end_chat_#{@activeChatId}"
      type: 'POST'
      url: "#{@apiPath}/kakao_chat/sessions/#{@activeChatId}/end"
      success: (data) =>
        @notify(
          type: 'success'
          msg: __('상담이 종료되었습니다.')
        )
        @loadChatList()
        @chatContent.html '''
          <div class="text-center text-muted" style="padding: 40px;">
            <p>상담을 선택하여 채팅을 시작하세요</p>
          </div>
        '''
        @activeChatId = null
      error: =>
        @notify(
          type: 'error'
          msg: __('상담 종료에 실패했습니다.')
        )
    )

  refreshChatList: (e) =>
    e?.preventDefault()
    @loadChatList()

  startPolling: =>
    @polling = setInterval(=>
      @loadChatList() if @activeChatId
    , 30000) # 30초마다 새로고침

  release: =>
    if @polling
      clearInterval(@polling)
      @polling = null
    super

# 네비게이션 바에 카카오 상담 메뉴 추가 (on/off에 따라)
class KakaoChatRouter extends App.ControllerPermanent
  constructor: (params) ->
    super

    # Check if integration is enabled
    if App.Setting.get('kakao_integration')
      App.Config.set('KakaoChat', {
        prio: 1400,
        name: __('카카오톡 상담'),
        target: '#kakao_chat',
        controller: KakaoChat,
        permission: ['admin'],
        icon: 'message-circle'
      }, 'NavBar')

# 설정이 변경될 때마다 네비게이션 업데이트
App.Event.bind 'setting:changed', (setting) ->
  if setting and setting.name is 'kakao_integration'
    console.log('카카오톡 통합 설정 변경됨:', setting.value)
    
    # 기존 메뉴 제거
    App.Config.delete('KakaoChat', 'NavBar')
    
    # 설정이 활성화된 경우에만 메뉴 추가
    if setting.value
      App.Config.set('KakaoChat', {
        prio: 1400,
        name: __('카카오톡 상담'),
        target: '#kakao_chat',
        controller: KakaoChat,
        permission: ['admin'],
        icon: 'message-circle'
      }, 'NavBar')
    
    # 네비게이션 바 재구성
    App.Event.trigger('navigation:rebuild')

App.KakaoChat = KakaoChat
App.KakaoChatRouter = KakaoChatRouter
