# app/models/kakao_consultation_message.rb
class KakaoConsultationMessage < ApplicationModel
  belongs_to :kakao_consultation_session

  validates :content, presence: true
  validates :sender_type, inclusion: { in: %w[customer agent system] }
  validates :message_type, inclusion: { in: %w[text image file system] }

  scope :by_sender_type, ->(type) { where(sender_type: type) }
  scope :recent, -> { order(:sent_at, :created_at) }
  scope :unread, -> { where(is_read: false) }

  store :preferences

  before_create :set_sent_at
  after_create :broadcast_new_message, if: -> { sender_type == 'customer' }

  def self.unread_by_agent
    where(sender_type: 'customer', read_by_agent: false)
  end

  def self.recent
    order(:sent_at)
  end

  def mark_as_read!
    update!(read_by_agent: true, read_at: Time.zone.now) if sender_type == 'customer'
  end

  def sender_name
    case sender_type
    when 'customer'
      kakao_consultation.customer.fullname
    when 'agent'
      sender_user&.fullname || 'Agent'
    when 'system'
      'System'
    end
  end

  def message_type
    preferences['message_type'] || 'text'
  end

  def message_type=(value)
    preferences['message_type'] = value
  end

  private

  def broadcast_new_message
    Sessions.broadcast(
      {
        event: 'new_kakao_message',
        data: {
          consultation_id: kakao_consultation.id,
          message: {
            id: id,
            content: content,
            sender_type: sender_type,
            sender_name: sender_name,
            sent_at: sent_at,
            message_type: message_type
          }
        }
      }
    )
  end
end