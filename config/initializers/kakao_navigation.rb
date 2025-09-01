# KakaoTalk navigation configuration

Rails.application.config.after_initialize do
  # Add KakaoTalk navigation item
  if Setting.get('ui_navbar_kakao')
    Rails.application.config.menu_items ||= []
    Rails.application.config.menu_items << {
      name: '카카오톡 상담',
      url: '#kakao_chat',
      icon: 'kakao-chat',
      permission: 'chat.agent',
      position: 1600,
      counter: 'kakao_unread'
    }
  end
end
