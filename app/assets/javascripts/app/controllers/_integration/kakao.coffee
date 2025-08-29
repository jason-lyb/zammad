# app/assets/javascripts/app/controllers/_integration_base/kakao.coffee
# Zammad 표준 Integration 패턴을 따름

class Kakao extends App.ControllerIntegrationBase
  featureIntegration: 'kakao_integration'
  featureConfig: 'kakao_config'
  featureName: __('카카오톡 상담톡')
  featureNameShort: __('KakaoTalk')
  
  description: [
    ['카카오톡 상담톡 API 서버와 연동하여 실시간 채팅 상담을 제공합니다.']
    ['API 서버 정보를 정확히 입력해주세요.']
  ]
  
  events:
    'change .js-switch input': 'switch'
    'click .js-test-connection': 'testConnection'
    'submit .js-form form': 'update'

  constructor: ->
    super

  render: ->
    super
    # 기본 통합 템플릿이 렌더링된 후 추가 폼 렌더링
    @renderForm()

  # 스위치 변경 시 네비게이션 업데이트
  switch: (e) =>
    # console.log 'Kakao switch method called'
    
    # 이벤트 전파 중단
    if e
      e.preventDefault()
      e.stopPropagation()
      e.stopImmediatePropagation()
    
    try
      # 부모 클래스의 switch 메서드 호출
      value = @$('.js-switch input').prop('checked')
      # console.log 'Switch value:', value
      
      App.Setting.set(@featureIntegration, value)
      # console.log 'Setting saved successfully'
      
      #성공 알림과 함께 네비게이션 실시간 업데이트
      if value
        message = __('카카오톡 상담톡이 활성화되었습니다. 네비게이션 바에 메뉴가 표시됩니다.')
      else
        message = __('카카오톡 상담톡이 비활성화되었습니다. 네비게이션 바에서 메뉴가 사라집니다.')
      
      @notify(
        type: 'success'
        msg: message
        timeout: 5000
      )
      
      # 네비게이션 메뉴 실시간 업데이트
      App.Event.trigger('menu:render')
      
    catch error
      console.error 'Error in switch method:', error
      @notify(
        type: 'error'
        msg: "스위치 변경 중 오류가 발생했습니다: #{error.message}"
      )
    
    # false 반환으로 추가 이벤트 처리 방지
    return false

  renderForm: ->
    # 현재 설정값 가져오기
    config = App.Setting.get(@featureConfig) || {}
    
    @$('.js-form').html App.view('integration/kakao')({
      config: config
    })

  testConnection: (e) ->
    e.preventDefault()
    
    # 폼 데이터 수집
    params = @formParams()
    
    if !params.api_endpoint || !params.api_token
      @notify(
        type: 'error'
        msg: __('API 서버 URL과 토큰을 모두 입력해주세요.')
      )
      return
    
    # 연결 테스트 API 호출
    @ajax(
      id: 'kakao_test_connection'
      type: 'POST'
      url: "#{@apiPath}/integration/kakao/test"
      data: JSON.stringify(params)
      success: (data) =>
        @notify(
          type: 'success'
          msg: __('카카오톡 상담톡 연결이 성공했습니다.')
        )
      error: (xhr) =>
        error_msg = xhr.responseJSON?.error || __('연결 테스트에 실패했습니다.')
        @notify(
          type: 'error'
          msg: error_msg
        )
    )

  update: (e) ->
    e.preventDefault()
    
    # Get form data
    params = @getFormData()
    
    # Validate required fields
    if !params.api_endpoint || !params.api_token
      @notify(
        type: 'error'
        msg: __('모든 필수 필드를 입력해주세요.')
      )
      return
    
    # Update individual settings
    App.Setting.set('kakao_api_endpoint', params.api_endpoint, notify: true)
    App.Setting.set('kakao_api_token', params.api_token, notify: true)
    
    # Show success message
    @notify(
      type: 'success'
      msg: __('카카오톡 상담톡 설정이 저장되었습니다.')
    )

  getFormData: ->
    data = {}
    @$('.js-form').find('input, select, textarea').each( ->
      element = $(@)
      name = element.attr('name')
      if element.is('[type="checkbox"]')
        data[name] = element.is(':checked')
      else
        data[name] = element.val()
    )
    data

# State 클래스 - 통합 상태 관리
class State
  @current: ->
    try
      setting = App.Setting.get('kakao_integration')
      # console.log 'State.current - kakao_integration:', setting
      return setting
    catch error
      # console.log 'kakao_integration setting not yet loaded in State:', error
      false

# NavBarIntegrations에 등록
App.Config.set(
  'IntegrationKakao'
  {
    name: __('카카오톡 상담톡')
    target: '#system/integration/kakao'
    description: __('카카오톡 상담톡과 연동하여 실시간 채팅 상담 서비스를 제공합니다.')
    controller: Kakao
    state: State
    permission: ['admin.integration']
  }
  'NavBarIntegrations'
)

# 메인 네비게이션 바에 조건부 표시 (초기에는 숨김, 설정 로드 후 동적 업데이트)
App.Config.set('KakaoChat', {
  prio: 1250,
  parent: '',
  name: __('카카오톡 상담'),
  target: '#kakao_chat',
  key: 'KakaoChat',
  permission: ['ticket.agent'],
  shown: false,  # 초기에는 숨김
  class: 'chat'
}, 'NavBar')

# console.log 'Kakao Integration loaded (standard way)'