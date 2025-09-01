# KakaoTalk navigation extension for unread count display
class App.NavigationKakao extends App.Controller
  constructor: ->
    super
    
    # Poll for unread count if user has chat agent permission
    if @permissionCheck('chat.agent')
      @startUnreadCountPolling()

    # Bind navigation update events
    @controllerBind('navupdate', @updateUnreadCount)
    @controllerBind('chat:message', @updateUnreadCount)

  startUnreadCountPolling: =>
    @updateUnreadCount()
    @interval(@updateUnreadCount, 30000, 'kakao-unread-polling')

  updateUnreadCount: =>
    return unless @permissionCheck('chat.agent')
    
    App.Ajax.request(
      id: 'kakao_unread_count'
      type: 'GET'
      url: "#{App.Config.get('api_path')}/kakao_chat/unread_count"
      processData: true
      success: (data) =>
        @showUnreadBadge(data.total_unread)
      error: (xhr, status, error) =>
        console.log('KakaoTalk unread count error:', error)
        @hideUnreadBadge()
    )

  showUnreadBadge: (count) =>
    # Find or create KakaoTalk menu item
    menuItem = $('.js-menu .menu-item[href="#kakao_chat"], .js-menu a[href="#kakao_chat"]').parent()
    
    if menuItem.length is 0
      @createKakaoMenuItem()
      menuItem = $('.js-menu .menu-item[href="#kakao_chat"], .js-menu a[href="#kakao_chat"]').parent()

    badge = menuItem.find('.js-kakao-unread-count')
    
    if badge.length is 0
      menuItem.find('a').append('<span class="counter badge js-kakao-unread-count hide">0</span>')
      badge = menuItem.find('.js-kakao-unread-count')

    if count > 0
      badge.text(count).removeClass('hide').addClass('badge-important')
      
      # Add pulse animation for new messages
      badge.addClass('badge-pulse')
      setTimeout(=>
        badge.removeClass('badge-pulse')
      , 1500)
    else
      badge.addClass('hide').removeClass('badge-important')

  hideUnreadBadge: =>
    $('.js-kakao-unread-count').addClass('hide').removeClass('badge-important')

  createKakaoMenuItem: =>
    return unless @permissionCheck('chat.agent')
    
    menuHtml = """
      <div class="menu js-menu-item" data-key="KakaoTalk">
        <a href="#kakao_chat" class="menu-item">
          <span class="name">카카오톡 상담</span>
        </a>
      </div>
    """
    
    # Add after existing menu items
    $('.js-menu .menu').last().after(menuHtml)

# Initialize KakaoTalk navigation component
App.Config.set('NavigationKakao', App.NavigationKakao, 'Navigation')
