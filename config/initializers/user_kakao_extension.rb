# config/initializers/user_kakao_extension.rb
Rails.application.config.after_initialize do
  
  User.class_eval do
    def self.find_or_create_kakao_customer(kakao_user_id)
      # 기존 고객 찾기 (phone 필드에 카카오톡 ID 저장)
      customer = find_by(phone: kakao_user_id)
      return customer if customer

      # 새 고객 생성
      create!(
        login: kakao_user_id,
        firstname: "카카오톡",
        lastname: "사용자 #{kakao_user_id[-4..-1]}",
        email: "#{kakao_user_id}@kakao.local",
        phone: kakao_user_id,
        role_ids: [Role.find_by(name: 'Customer').id],
        source: 'KakaoTalk',
        preferences: {
          channel: 'kakao',
          kakao_user_id: kakao_user_id
        }
      )
    end

    def kakao_customer?
      source == 'KakaoTalk' || preferences['channel'] == 'kakao'
    end

    def kakao_user_id
      return phone if kakao_customer?
      nil
    end
  end

end