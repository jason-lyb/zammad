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
    @html App.view('kakao_chat/index')(
      activeChatId: @activeChatId
    )
    
    @loadChatList()

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
    )

  updateChatList: (sessions) =>
    @chats = {}
    for session in sessions
      @chats[session.id] = session

    @chatList.html App.view('kakao_chat/list')(
      sessions: sessions
      activeChatId: @activeChatId
    )

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
    )

  updateChatContent: (messages, chatId) =>
    chat = @chats[chatId]
    return unless chat

    @chatContent.html App.view('kakao_chat/content')(
      chat: chat
      messages: messages
    )
    
    # 스크롤을 맨 아래로
    @chatContent.find('.js-messagesList').scrollTop(99999)

  sendMessage: (e) =>
    e.preventDefault()
    return unless @activeChatId
    
    message = @messageInput.val().trim()
    return unless message
    
    @sendMessageToAPI(message)

  handleKeyPress: (e) =>
    if e.which is 13 && !e.shiftKey  # Enter key without Shift
      e.preventDefault()
      @sendMessage(e)

  sendMessageToAPI: (message) =>
    @sendButton.prop('disabled', true)
    
    @ajax(
      id: "kakao_send_message_#{@activeChatId}"
      type: 'POST'
      url: "#{@apiPath}/kakao_chat/sessions/#{@activeChatId}/messages"
      data: JSON.stringify(
        message: message
        sender_type: 'agent'
        sender_id: App.Session.get('id')
      )
      success: (data) =>
        @messageInput.val('')
        @loadChatMessages(@activeChatId)  # 메시지 목록 새로고침
      error: =>
        @notify(
          type: 'error'
          msg: __('메시지 전송에 실패했습니다.')
        )
      complete: =>
        @sendButton.prop('disabled', false)
    )

  endChat: (e) =>
    e.preventDefault()
    return unless @activeChatId
    
    new App.ControllerConfirm(
      message: __('정말로 이 상담을 종료하시겠습니까?')
      buttonClass: 'btn--danger'
      buttonCancel: __('취소')
      buttonSubmit: __('종료')
      callback: =>
        @endChatSession(@activeChatId)
      container: @el.closest('.content')
    )

  endChatSession: (chatId) =>
    @ajax(
      id: "kakao_end_chat_#{chatId}"
      type: 'POST'
      url: "#{@apiPath}/kakao_chat/sessions/#{chatId}/end"
      success: (data) =>
        @notify(
          type: 'success'
          msg: __('상담이 종료되었습니다.')
        )
        
        # 종료된 채팅이 현재 선택된 채팅이면 선택 해제
        if @activeChatId is chatId
          @activeChatId = null
          @chatContent.html('<div class="text-center text-muted">상담을 선택해주세요.</div>')
        
        @loadChatList()  # 목록 새로고침
      error: =>
        @notify(
          type: 'error'
          msg: __('상담 종료에 실패했습니다.')
        )
    )

  refreshChatList: (e) =>
    e.preventDefault()
    @loadChatList()

  startPolling: =>
    return if @polling
    
    # 30초마다 채팅 목록과 메시지 자동 새로고침
    @polling = setInterval =>
      @loadChatList()
      if @activeChatId
        @loadChatMessages(@activeChatId)
    , 30000

  stopPolling: =>
    if @polling
      clearInterval(@polling)
      @polling = null

  release: =>
    @stopPolling()
    super

  show: (params) =>
    @title __('카카오톡 상담'), true
    @navupdate '#kakao_chat'

  hide: =>
    @stopPolling()

class KakaoChatRouter extends App.ControllerPermanent
  requiredPermission: 'admin'
  
  constructor: (params) ->
    console.log 'KakaoChatRouter constructor called with params:', params
    super

    # 인증 체크
    unless @authenticateCheck()
      console.log 'Authentication failed for KakaoChat'
      return

    console.log 'Starting KakaoChat TaskManager execution'
    App.TaskManager.execute(
      key:        'KakaoChat'
      controller: 'KakaoChat'
      params:     params
      show:       true
      persistent: true
    )

App.Config.set 'kakao_chat', KakaoChatRouter, 'Routes'
App.Config.set 'KakaoChat', 
  controller: 'KakaoChat'
  permission: ['admin']
, 'permanentTask'

# 네비게이션 바에 추가 (통합 설정 활성화 상태에 따라)
App.Config.set 'KakaoChat', 
  prio: 1250
  parent: ''
  name: __('카카오톡 상담')
  target: '#kakao_chat'
  key: 'KakaoChat'
  permission: ['admin']
  class: 'channels'
  iconClass: 'message-circle'
  shown: ->
    # 설정 상태 확인 및 에러 처리 강화
    try
      return false unless App.Setting
      integration_enabled = App.Setting.get('kakao_integration')
      console.log('카카오톡 네비게이션 표시 체크:', integration_enabled) if window.App and window.App.Debug
      return integration_enabled is true
    catch error
      console.error('카카오톡 네비게이션 표시 체크 오류:', error)
      return false
, 'NavBar'

# 설정 변경 시 네비게이션 바 즉시 업데이트
App.Event.bind 'setting:changed', (setting) ->
  if setting and setting.name is 'kakao_integration'
    console.log('카카오톡 통합 설정 변경됨:', setting.value) if window.App and window.App.Debug
    App.Event.trigger('navigation:rebuild')
    App.Event.trigger('ui:rerender')

# 네비게이션 리빌드 이벤트 처리
App.Event.bind 'navigation:rebuild', ->
  console.log('네비게이션 리빌드 트리거됨') if window.App and window.App.Debug
  App.Event.trigger('navigation:reload')

# 컨트롤러를 App 네임스페이스에 등록
App.KakaoChat = KakaoChat
App.KakaoChatRouter = KakaoChatRouter
