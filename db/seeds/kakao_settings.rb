# KakaoTalk consultation settings and menu configuration

# KakaoTalk navigation menu configuration
# KakaoTalk menu settings

# Enable KakaoTalk navigation menu
Setting.create_if_not_exists(
  title: 'KakaoTalk Navigation',
  name: 'ui_navbar_kakao',
  area: 'UI::Base',
  description: 'Show KakaoTalk navigation item with unread count.',
  options: {
    form: [
      {
        display: '',
        null: true,
        name: 'ui_navbar_kakao',
        tag: 'boolean',
        options: {
          true  => 'yes',
          false => 'no',
        },
      },
    ]
  },
  state: true,
  preferences: {
    render: true,
    prio: 1600,
    placeholder: true,
    permission: ['admin.ui']
  },
  frontend: true
)

# KakaoTalk menu item configuration
App::Config.set(
  'KakaoTalk',
  {
    prio: 1600,
    name: '카카오톡 상담',
    target: '#kakao_chat',
    key: 'KakaoTalk',
    permission: ['chat.agent'],
    class: 'kakao-chat',
    role: ['Agent'],
    counter: -> {
      # This will be handled by frontend JavaScript
      return 0
    }
  },
  'NavBar'
)

puts 'KakaoTalk navigation settings created.'

# KakaoTalk menu item configuration
Setting.create_if_not_exists(
  title: __('KakaoTalk consultation enabled for agents without chat permission'),
  name: 'ui_navbar_kakao_show_always',
  area: 'UI::Navbar',
  description: __('Defines if KakaoTalk consultation button is enabled for users without chat.agent permission.'),
  options: {},
  state: false,
  frontend: true
)