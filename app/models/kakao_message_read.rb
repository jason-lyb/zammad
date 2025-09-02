# 개별 상담원별 메시지 읽음 상태 추적 모델
class KakaoMessageRead < ActiveRecord::Base
  belongs_to :kakao_consultation_message
  belongs_to :user

  validates :kakao_consultation_message_id, uniqueness: { scope: :user_id }
  validates :read_at, presence: true

  scope :by_user, ->(user) { where(user: user) }
  scope :recent, -> { order(read_at: :desc) }
end
