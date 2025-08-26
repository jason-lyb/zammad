# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Controllers::Integration::KakaoControllerPolicy < Controllers::ApplicationControllerPolicy

  def index?
    user.permissions?(['admin.integration'])
  end

  def update?
    user.permissions?(['admin.integration'])
  end

  def test_connection?
    user.permissions?(['admin.integration'])
  end

end
