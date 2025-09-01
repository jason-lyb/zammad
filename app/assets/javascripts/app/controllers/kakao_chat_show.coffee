class KakaoChatShow extends App.ControllerSubContent
  header: __('카카오톡 상담 상세')
  
  constructor: (params) ->
    super
    # console.log 'KakaoChatShow constructor called with params:', params
    @params = params || {}
    @session = null
    @messages = []
    @loadSessionData()

  loadSessionData: =>
    chat_id = @params.chat_id
    return @renderError('세션 ID가 없습니다.') if !chat_id
    
    # 세션 정보 로드
    App.Ajax.request(
      id: 'kakao_chat_session_detail'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{chat_id}"
      success: (data) =>
        @session = data.session
        @loadMessages()
      error: (xhr, status, error) =>
        console.error 'Failed to load session:', error
        @renderError('세션을 불러올 수 없습니다.')
    )
  
  loadMessages: =>
    chat_id = @params.chat_id
    
    # 메시지 목록 로드
    App.Ajax.request(
      id: 'kakao_chat_messages'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{chat_id}/messages"
      success: (data) =>
        @messages = data.messages || []
        @render()
      error: (xhr, status, error) =>
        console.error 'Failed to load messages:', error
        @messages = []
        @render()
    )

  render: =>
    chat_id = @params.chat_id || 'Unknown'
    
    if !@session
      @renderLoading()
      return
    
    # 세션 정보 표시
    sessionInfo = @renderSessionInfo()
    
    # 메시지 목록 표시
    messagesList = @renderMessages()
    
    # 메시지 입력 폼
    messageForm = @renderMessageForm()
    
    @html """
      <div class="page-header">
        <div class="page-header-title">
          <h1>카카오톡 상담 - #{@session.customer_name || chat_id}</h1>
        </div>
        <div class="page-header-meta">
          <a href="#kakao_chat" class="btn btn--text">← 목록으로</a>
        </div>
      </div>
      
      <div class="page-content">
        #{sessionInfo}
        #{messagesList}
        #{messageForm}
      </div>
    """
    
    @bindEvents()

  renderLoading: =>
    @html """
      <div class="page-content">
        <div class="loading icon"></div>
        <div class="center">세션 정보를 불러오는 중...</div>
      </div>
    """

  renderError: (message) =>
    @html """
      <div class="page-content">
        <div class="alert alert-danger">
          <h4>오류</h4>
          <p>#{message}</p>
          <a href="#kakao_chat" class="btn btn-primary">목록으로 돌아가기</a>
        </div>
      </div>
    """

  renderSessionInfo: =>
    return '' if !@session
    
    statusClass = switch @session.status
      when 'active' then 'success'
      when 'waiting' then 'warning'
      when 'ended' then 'neutral'
      when 'transferred' then 'info'
      else 'neutral'
    
    statusText = @getStatusText(@session.status)
    
    agentInfo = if @session.agent_name
      @session.agent_name
    else
      "미배정"
    
    """
    <div class="box">
      <h3>상담 정보</h3>
      <div class="row">
        <div class="col-md-6">
          <dl class="dl-horizontal">
            <dt>고객명:</dt>
            <dd>#{@session.customer_name || '알 수 없음'}</dd>
            <dt>세션 ID:</dt>
            <dd>#{@session.session_id}</dd>
            <dt>상태:</dt>
            <dd><span class="label label-#{statusClass}">#{statusText}</span></dd>
          </dl>
        </div>
        <div class="col-md-6">
          <dl class="dl-horizontal">
            <dt>담당자:</dt>
            <dd>#{agentInfo}</dd>
            <dt>시작 시간:</dt>
            <dd>#{@humanTime(@session.created_at)}</dd>
            <dt>마지막 활동:</dt>
            <dd>#{@humanTime(@session.updated_at)}</dd>
          </dl>
        </div>
      </div>
    </div>
    """

  renderMessages: =>
    if !@messages || @messages.length == 0
      return """
        <div class="box">
          <h3>메시지</h3>
          <div class="center">
            <p>메시지가 없습니다.</p>
          </div>
        </div>
      """
    
    messagesList = @messages.map((message) =>
      senderClass = if message.sender_type == 'customer' then 'customer' else 'agent'
      senderName = if message.sender_type == 'customer' 
        @session.customer_name || '고객'
      else if message.sender_name
        message.sender_name
      else
        '상담원'
      
      """
      <div class="message-item #{senderClass}">
        <div class="message-header">
          <strong>#{senderName}</strong>
          <small class="text-muted">#{@humanTime(message.created_at)}</small>
        </div>
        <div class="message-content">
          #{App.Utils.textCleanup(message.content)}
        </div>
      </div>
      """
    ).join('')
    
    """
    <div class="box">
      <h3>메시지 (#{@messages.length}개)</h3>
      <div class="messages-container" style="max-height: 400px; overflow-y: auto; border: 1px solid #ddd; padding: 10px;">
        #{messagesList}
      </div>
    </div>
    """

  renderMessageForm: =>
    return '' if @session?.status != 'active'
    
    """
    <div class="box">
      <h3>메시지 보내기</h3>
      <form class="message-form">
        <div class="form-group">
          <textarea class="form-control js-message-content" rows="3" placeholder="메시지를 입력하세요..."></textarea>
        </div>
        <div class="form-group">
          <button type="submit" class="btn btn-primary js-send-message">보내기</button>
        </div>
      </form>
    </div>
    """

  bindEvents: =>
    # 메시지 전송
    @el.on('submit', '.message-form', (e) =>
      e.preventDefault()
      @sendMessage()
    )
    
    # 새로고침 (5초마다 자동)
    @refreshInterval = setInterval(=>
      @loadMessages() if @session
    , 5000)

  sendMessage: =>
    content = @el.find('.js-message-content').val().trim()
    return if !content
    
    chat_id = @params.chat_id
    
    App.Ajax.request(
      id: 'kakao_chat_send_message'
      type: 'POST'
      url: "#{App.Config.get('api_path')}/kakao_chat/sessions/#{chat_id}/messages"
      data:
        content: content
      success: (data) =>
        # 메시지 전송 성공
        @el.find('.js-message-content').val('')
        @loadMessages()  # 메시지 목록 새로고침
      error: (xhr, status, error) =>
        console.error 'Failed to send message:', error
        alert('메시지 전송에 실패했습니다.')
    )

  # 상태 텍스트 변환
  getStatusText: (status) ->
    switch status
      when 'active' then '진행중'
      when 'waiting' then '대기중'
      when 'ended' then '완료'
      when 'transferred' then '이관됨'
      else '알 수 없음'

  # 시간 표시 메서드
  humanTime: (timeString) ->
    return '-' if !timeString
    
    try
      date = new Date(timeString)
      if isNaN(date.getTime())
        return timeString
      
      now = new Date()
      diffMs = now.getTime() - date.getTime()
      diffMinutes = Math.floor(diffMs / (1000 * 60))
      diffHours = Math.floor(diffMinutes / 60)
      diffDays = Math.floor(diffHours / 24)
      
      if diffMinutes < 1
        return '방금 전'
      else if diffMinutes < 60
        return "#{diffMinutes}분 전"
      else if diffHours < 24
        return "#{diffHours}시간 전"
      else if diffDays < 7
        return "#{diffDays}일 전"
      else
        month = date.getMonth() + 1
        day = date.getDate()
        hours = date.getHours()
        minutes = date.getMinutes()
        minutesStr = if minutes < 10 then "0#{minutes}" else "#{minutes}"
        return "#{month}/#{day} #{hours}:#{minutesStr}"
    catch error
      return timeString || '-'

  # 컴포넌트 정리
  release: =>
    clearInterval(@refreshInterval) if @refreshInterval
    super

# 상세 보기용 Router 클래스
class KakaoChatShowRouter extends App.ControllerPermanent
  constructor: (params) ->
    super
    # console.log 'KakaoChatShowRouter constructor called with params:', params

    # 인증 확인
    @authenticateCheckRedirect()

    # TaskManager로 실행
    App.TaskManager.execute(
      key:        "KakaoChatShow-#{params.chat_id}"
      controller: 'KakaoChatShow'
      params:     params
      show:       true
      persistent: true
    )

# App 네임스페이스에 등록
App.KakaoChatShow = KakaoChatShow

# Router 등록
App.Config.set('kakao_chat/:chat_id', KakaoChatShowRouter, 'Routes')

# console.log 'KakaoChatShow controller loaded successfully'
