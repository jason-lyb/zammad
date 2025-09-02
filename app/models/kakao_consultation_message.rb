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
  after_create :update_navigation_counter, if: -> { sender_type == 'customer' }
  after_update :update_navigation_counter, if: :saved_change_to_is_read?

  def self.unread_by_agent
    where(sender_type: 'customer', is_read: false)
  end

  def self.recent
    order(:sent_at)
  end

  def mark_as_read!
    update!(is_read: true) if sender_type == 'customer'
  end

  def sender_name
    case sender_type
    when 'customer'
      kakao_consultation_session.customer_name || '고객'
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

  def attachments_data
    return [] if kakao_attachments.blank? || kakao_attachments == '[]'
    
    parsed = JSON.parse(kakao_attachments)
    return [] if parsed.blank?
    
    parsed
  rescue JSON::ParserError
    []
  end

  def attachments_data=(data)
    if data.nil? || data.empty?
      self.kakao_attachments = '[]'
    else
      self.kakao_attachments = data.to_json
    end
  end

  private

  def set_sent_at
    self.sent_at ||= Time.zone.now
  end

  def broadcast_new_message
    Sessions.broadcast(
      {
        event: 'new_kakao_message',
        data: {
          consultation_id: kakao_consultation_session.id,
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

  # Navigation counter update is now handled via WebSocket in KakaoChatController#notify_agents
  def update_navigation_counter
    # Counter updates are handled via WebSocket notifications
    # See KakaoChatController#notify_agents method
    Rails.logger.debug "Navigation counter update skipped - handled via WebSocket"
  end
end