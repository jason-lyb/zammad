# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Controllers::KakaoChatControllerPolicy < Controllers::ApplicationControllerPolicy

  def sessions?
    user.permissions?(['admin.integration', 'admin.channel_chat', 'chat'])
  end

  def messages?
    user.permissions?(['admin.integration', 'admin.channel_chat', 'chat'])
  end

  def send_message?
    user.permissions?(['admin.integration', 'admin.channel_chat', 'chat'])
  end

  def end_session?
    user.permissions?(['admin.integration', 'admin.channel_chat', 'chat'])
  end

end
