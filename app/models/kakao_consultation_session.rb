# == Schema Information
#
# Table name: kakao_consultation_sessions
#
class KakaoConsultationSession < ActiveRecord::Base
  has_many :kakao_consultation_messages, foreign_key: 'kakao_consultation_session_id', dependent: :destroy
  has_one :kakao_consultation_stats, dependent: :destroy
  belongs_to :agent, class_name: 'User', foreign_key: 'agent_id', optional: true

  validates :session_id, presence: true, uniqueness: true
  validates :user_key, presence: true
  validates :status, inclusion: { in: %w[waiting active ended transferred] }

  scope :active, -> { where(status: ['waiting', 'active']) }
  scope :ended, -> { where(status: 'ended') }
  scope :by_agent, ->(agent_id) { where(agent_id: agent_id) }
  scope :recent, -> { order(last_message_at: :desc, created_at: :desc) }

  before_create :set_started_at
  after_update :update_stats, if: :saved_change_to_status?
  after_update :update_navigation_counter, if: :saved_change_to_unread_count?

  # JSON 필드 accessor
  def customer_info_data
    return {} if customer_info.blank?
    JSON.parse(customer_info)
  rescue JSON::ParserError
    {}
  end

  def customer_info_data=(data)
    self.customer_info = data.to_json
  end

  def tags_array
    return [] if tags.blank?
    JSON.parse(tags)
  rescue JSON::ParserError
    []
  end

  def tags_array=(array)
    self.tags = array.to_json
  end

  # 상태 변경 메서드들
  def start_consultation!(agent)
    update!(
      status: 'active',
      agent: agent,
      started_at: Time.current
    )
  end

  def end_consultation!
    update!(
      status: 'ended',
      ended_at: Time.current
    )
    
    # 통계 업데이트
    update_final_stats
    
    # 자동 티켓 생성
    create_ticket_if_enabled
  end

  def transfer_to_agent!(new_agent)
    update!(
      agent: new_agent,
      status: 'active'
    )
  end

  # 메시지 관련 메서드들
  def add_message(content:, sender_type:, sender_id: nil, sender_name: nil, message_type: 'text', attachments: nil)
    message = kakao_consultation_messages.create!(
      content: content,
      sender_type: sender_type,
      sender_id: sender_id,
      sender_name: sender_name,
      message_type: message_type,
      attachments: attachments&.to_json,
      sent_at: Time.current
    )

    # 세션 정보 업데이트
    update_last_message_info(message)
    update_unread_count(sender_type)
    
    message
  end

  def mark_messages_as_read!
    kakao_consultation_messages.where(is_read: false).update_all(is_read: true)
    update!(unread_count: 0)
  end

  # 상담 시간 계산
  def duration_in_seconds
    return 0 unless started_at
    end_time = ended_at || Time.current
    (end_time - started_at).to_i
  end

  def duration_formatted
    seconds = duration_in_seconds
    return '0분' if seconds < 60
    
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    
    if hours > 0
      "#{hours}시간 #{minutes}분"
    else
      "#{minutes}분"
    end
  end

  # 평균 응답 시간 계산
  def calculate_avg_response_time
    agent_messages = kakao_consultation_messages.where(sender_type: 'agent').order(:sent_at)
    customer_messages = kakao_consultation_messages.where(sender_type: 'customer').order(:sent_at)
    
    response_times = []
    
    customer_messages.each do |customer_msg|
      next_agent_msg = agent_messages.where('sent_at > ?', customer_msg.sent_at).first
      next if next_agent_msg.nil?
      
      response_times << (next_agent_msg.sent_at - customer_msg.sent_at).to_i
    end
    
    return 0 if response_times.empty?
    response_times.sum / response_times.size
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end

  def update_last_message_info(message)
    update_columns(
      last_message_at: message.sent_at,
      last_message_content: message.content.truncate(100),
      last_message_sender: message.sender_type
    )
  end

  def update_unread_count(sender_type)
    return if sender_type == 'agent'  # 상담원이 보낸 메시지는 읽음 처리
    
    increment!(:unread_count)
  end

  def update_stats
    return unless kakao_consultation_stats
    
    kakao_consultation_stats.update!(
      total_messages: kakao_consultation_messages.count,
      customer_messages: kakao_consultation_messages.where(sender_type: 'customer').count,
      agent_messages: kakao_consultation_messages.where(sender_type: 'agent').count,
      session_duration: duration_in_seconds,
      response_time_avg: calculate_avg_response_time
    )
  end

  def update_navigation_counter
    # WebSocket으로 카운터 업데이트 브로드캐스트
    begin
      notification_data = {
        event: 'kakao_counter_update',
        data: {
          total_unread: calculate_total_unread_count
        }
      }
      Sessions.broadcast(notification_data)
      Rails.logger.debug "Broadcasted kakao counter update: #{notification_data[:data][:total_unread]}"
    rescue => e
      Rails.logger.error "Failed to update KakaoConsultation navigation counter: #{e.message}"
    end
  end

  def update_final_stats
    stats = kakao_consultation_stats || create_kakao_consultation_stats!
    
    stats.update!(
      total_messages: kakao_consultation_messages.count,
      customer_messages: kakao_consultation_messages.where(sender_type: 'customer').count,
      agent_messages: kakao_consultation_messages.where(sender_type: 'agent').count,
      session_duration: duration_in_seconds,
      response_time_avg: calculate_avg_response_time
    )
  end

  def create_ticket_if_enabled
    return unless Setting.get('kakao_auto_create_ticket')
    
    # TODO: 티켓 생성 로직 구현
    # CreateTicketFromKakaoConsultationJob.perform_later(id)
  end

  def calculate_total_unread_count
    KakaoConsultationSession.where(status: ['waiting', 'active']).sum(:unread_count)
  end
end
