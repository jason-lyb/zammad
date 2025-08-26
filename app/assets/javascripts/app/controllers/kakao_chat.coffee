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
    
    # console.log 'KakaoChat about to call render...'
    @render()
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

  render: =>
    # console.log 'KakaoChat render called'
    # console.log 'KakaoChat proceeding with render...'
    
    # 간단한 HTML로 테스트
    html = '''
      <div class="page-header">
        <h1>카카오톡 상담</h1>
      </div>
      
      <div class="page-content">
        <div class="box">
          <div class="empty-content">
            <div class="empty-content-icon">
              <svg class="icon icon-chat">
                <use xlink:href="assets/images/icons.svg#icon-chat"></use>
              </svg>
            </div>
            <h3>내용 없음</h3>
            <p>아직 카카오톡 상담 내용이 없습니다.</p>
          </div>
        </div>
      </div>
    '''
    
    # console.log 'KakaoChat HTML content prepared:', html.length, 'characters'
    # console.log 'KakaoChat @el element:', @el
    
    @el.html(html)
    # console.log 'HTML rendered to element. Element content:', @el.html().length, 'characters'

# App 네임스페이스에 즉시 등록
App.KakaoChat = KakaoChat

class KakaoChatShow extends App.ControllerSubContent
  header: __('카카오톡 상담 상세')
  
  constructor: ->
    super
    # console.log 'KakaoChatShow constructor called'
    @render()

  render: =>
    chat_id = @params.chat_id
    # console.log 'KakaoChatShow render called with chat_id:', chat_id
    @html """
      <div class="page-header">
        <h1>카카오톡 상담 - #{chat_id}</h1>
      </div>
      
      <div class="page-content">
        <div class="box">
          <p>채팅 ID: #{chat_id}</p>
          <p>상세 내용을 여기에 표시합니다.</p>
        </div>
      </div>
    """

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

# App 네임스페이스에 추가 등록
App.KakaoChatShow = KakaoChatShow

# TaskManager permanentTask 등록 (설정 상태는 featureActive에서 확인)
App.Config.set('KakaoChat', {
  controller: 'KakaoChat'
  permission: ['ticket.agent']
}, 'permanentTask')

# Router 방식으로 등록
App.Config.set('kakao_chat', KakaoChatRouter, 'Routes')
App.Config.set('kakao_chat/:chat_id', KakaoChatShow, 'Routes')

# console.log 'KakaoChat controllers loaded successfully'