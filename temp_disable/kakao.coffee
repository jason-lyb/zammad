class Kakao extends App.ControllerIntegrationBase
  featureIntegration: 'kakao_integration'
  featureName: __('카카오톡 상담톡')
  featureConfig: 'kakao_config'
  description: [
    [__('카카오톡 상담톡 API 서버와 연동하여 실시간 상담 채팅을 제공합니다.')]
    [__('상담원이 Zammad 채팅창을 통해 고객과 직접 상담할 수 있습니다.')]
    [__('상담 세션은 종료될 때까지 목록에서 관리되며 언제든 재개할 수 있습니다.')]
  ]
  events:
    'click .js-test-connection': 'testConnection'

  render: =>
    super
    try
      new Form(
        el: @$('.js-form')
      )
    catch error
      console.error('Error creating Kakao form:', error)

  testConnection: (e) =>
    e.preventDefault()
    @showLoader()
    
    # Get current config values
    config = @getConfig()
    
    # Test API connection
    @ajax(
      id: 'kakao_test'
      type: 'POST'
      url: "#{@apiPath}/channels/admin/kakao/test"
      data: config
      success: (data, status, xhr) =>
        @hideLoader()
        if data.result is 'ok'
          new App.ControllerModal(
            head: __('연결 테스트 성공')
            message: __('상담톡 API 서버 연결이 성공했습니다!')
            buttonClose: __('닫기')
            container: @el.closest('.content')
          )
        else
          new App.ControllerModal(
            head: __('연결 테스트 실패')
            message: data.message || __('상담톡 API 서버에 연결할 수 없습니다.')
            buttonClose: __('닫기')
            container: @el.closest('.content')
          )
      error: =>
        @hideLoader()
        new App.ControllerModal(
          head: __('연결 테스트 실패')
          message: __('상담톡 API 서버 연결에 실패했습니다. 설정을 확인해주세요.')
          buttonClose: __('닫기')
          container: @el.closest('.content')
        )
    )

  getConfig: =>
    config = {}
    @$('.js-form').find('input, select, textarea').each( ->
      $element = $(@)
      name = $element.attr('name')
      value = $element.val()
      config[name] = value
    )
    config

class Form extends App.Controller
  events:
    'submit form': 'update'
    'change .js-switch input': 'switch'

  constructor: ->
    super
    try
      @render()
    catch error
      console.error('Error rendering Kakao form:', error)

  currentConfig: ->
    App.Setting.get('kakao_config') or {}

  setConfig: (value) ->
    App.Setting.set('kakao_config', value, notify: true)

  render: =>
    try
      @config = @currentConfig()
      
      # Get individual settings
      integration_enabled = App.Setting.get('kakao_integration')
      api_endpoint = App.Setting.get('kakao_api_endpoint') || ''
      api_token = App.Setting.get('kakao_api_token') || ''
      webhook_token = App.Setting.get('kakao_webhook_token') || ''
      session_timeout = App.Setting.get('kakao_session_timeout') || 30

      @html App.view('integration/kakao')(
        config: @config
        integration_enabled: integration_enabled
        api_endpoint: api_endpoint
        api_token: api_token
        webhook_token: webhook_token
        session_timeout: session_timeout
        callback_url: "#{App.Config.get('http_type')}://#{App.Config.get('fqdn')}/api/v1/channels/kakao/webhook"
      )
    catch error
      console.error('Error in Kakao form render:', error)
      @html '<div class="alert alert--danger">카카오톡 상담톡 설정 오류. 콘솔에서 자세한 내용을 확인하세요.</div>'

  update: (e) =>
    e.preventDefault()
    
    # Get form data
    params = @formParam(e.target)
    
    # Update individual settings
    App.Setting.set('kakao_api_endpoint', params.api_endpoint, notify: true)
    App.Setting.set('kakao_api_token', params.api_token, notify: true)
    App.Setting.set('kakao_webhook_token', params.webhook_token, notify: true)
    App.Setting.set('kakao_session_timeout', parseInt(params.session_timeout) || 30, notify: true)
    
    # Update integration toggle setting
    integration_enabled = !!params.integration
    App.Setting.set('kakao_integration', integration_enabled, notify: true)
    
    # Trigger navigation update when integration setting changes
    @triggerNavigationUpdate()
    
    # Update main config
    @setConfig(params)
    
    # Show success message
    new App.ControllerModal(
      head: __('설정 저장됨')
      message: __('카카오톡 상담톡 설정이 저장되었습니다.')
      buttonClose: __('닫기')
      container: @el.closest('.content')
    )

  switch: =>
    @$('.js-form').find('input, select, textarea').trigger('change')
    
  triggerNavigationUpdate: =>
    # 네비게이션 바 새로고침
    App.Event.trigger('navigation:rebuild')
    # UI 전체 재렌더링 트리거
    App.Event.trigger('ui:rerender')

class State
  @current: ->
    App.Setting.get('kakao_integration')

App.Config.set(
  'IntegrationKakao'
  
    name: __('카카오톡 상담톡')
    target: '#system/integration/kakao'
    description: __('카카오톡 상담톡 API 서버와 연동하여 실시간 채팅 상담을 제공합니다.')
    controller: Kakao
    state: State
    permission: ['admin.integration.kakao']
  
  'NavBarIntegrations'
)