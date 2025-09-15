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

  def link_customer?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def unlink_customer?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def receive_message?
    # Webhook은 외부에서 호출되므로 인증 없이 허용 (API 키 등으로 별도 검증)
    true
  end

  def send_message_api?
    # API는 자체 토큰 인증을 사용하므로 Pundit에서는 허용
    true
  end

  def end_session_api?
    # API는 자체 토큰 인증을 사용하므로 Pundit에서는 허용
    true
  end

  def upload_file?
    user.permissions?(['admin.integration', 'chat.agent'])
  end

  def upload_file_api?
    # API는 자체 토큰 인증을 사용하므로 Pundit에서는 허용
    true
  end

  def download_file?
    # 파일 다운로드는 컨트롤러에서 별도 권한 확인
    true
  end

  def file_thumbnail?
    # 썸네일은 컨트롤러에서 별도 권한 확인
    true
  end

end
