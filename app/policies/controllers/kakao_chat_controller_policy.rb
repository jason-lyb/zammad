# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Controllers::KakaoChatControllerPolicy < Controllers::ApplicationControllerPolicy

  def sessions?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def show?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def messages?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def send_message?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def end_session?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def assign_agent?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def mark_messages_as_read?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def available_agents?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def unread_count?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def receive_message?
    # Webhook은 외부에서 호출되므로 인증 없이 허용 (API 키 등으로 별도 검증)
    true
  end

end
