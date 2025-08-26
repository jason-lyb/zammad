# app/models/kakao_consultation.rb
class KakaoConsultation < ApplicationModel

  belongs_to :customer, class_name: 'User'
  belongs_to :assigned_agent, class_name: 'User', optional: true
  has_one :ticket, dependent: :nullify
  has_many :messages, class_name: 'KakaoConsultationMessage', dependent: :destroy

  validates :kakao_user_id, presence: true
  validates :consultation_id, presence: true, uniqueness: true

  store :preferences

  before_create :generate_consultation_id
  after_update :handle_status_change

  def self.active_consultations
    where(status: ['active', 'agent_away'])
  end

  def self.recent_ended
    where(status: 'customer_ended').where('ended_at > ?', 24.hours.ago)
  end

  def self.find_or_create_for_kakao_user(kakao_user_id)
    # 기존 활성 상담 찾기
    existing = active_consultations.find_by(kakao_user_id: kakao_user_id)
    return existing if existing

    # 고객 찾기 또는 생성
    customer = User.find_or_create_kakao_customer(kakao_user_id)

    # 새 상담 생성
    create!(
      kakao_user_id: kakao_user_id,
      customer: customer,
      status: 'active',
      started_at: Time.zone.now
    )
  end

  def add_message(content, sender_type, sender_user = nil)
    messages.create!(
      content: content,
      sender_type: sender_type,
      sender_user: sender_user,
      sent_at: Time.zone.now
    )
  end

  def end_by_customer!(reason = 'customer_request')
    transaction do
      update!(
        status: 'customer_ended',
        ended_at: Time.zone.now,
        end_reason: reason
      )

      # 자동 티켓 생성
      create_ticket_if_needed
    end
  end

  def agent_away!
    update!(status: 'agent_away', last_agent_away_at: Time.zone.now)
  end

  def agent_return!
    update!(status: 'active') if status == 'agent_away'
  end

  def customer_ended?
    status == 'customer_ended'
  end

  def agent_away?
    status == 'agent_away'
  end

  def unread_messages_count
    messages.where(sender_type: 'customer', read_by_agent: false).count
  end

  def duration
    return nil unless ended_at
    ended_at - started_at
  end

  private

  def generate_consultation_id
    self.consultation_id = "kakao_#{kakao_user_id}_#{Time.zone.now.to_i}"
  end

  def handle_status_change
    return unless saved_change_to_status?

    case status
    when 'customer_ended'
      handle_consultation_ended
    when 'agent_away'
      handle_agent_away
    when 'active'
      handle_agent_return if saved_change_to_status_from == 'agent_away'
    end
  end

  def handle_consultation_ended
    Rails.logger.info "KakaoTalk consultation ended: #{consultation_id}"
    
    # 즉시 WebSocket 알림
    notify_agents_consultation_ended
    
    # 백그라운드에서 통계 업데이트
    KakaoConsultationJob.perform_later('update_statistics', id)
  end

  def handle_agent_away
    Rails.logger.info "Agent away for consultation: #{consultation_id}"
    
    # 백그라운드에서 알림 전송
    if Setting.get('kakao_integration')
      KakaoConsultationJob.perform_later(
        'send_notification', 
        id, 
        { 'message' => "상담원이 잠시 자리를 비웠습니다. 메시지를 남겨주시면 확인 후 답변드리겠습니다." }
      )
    end
  end

  def handle_agent_return
    Rails.logger.info "Agent returned for consultation: #{consultation_id}"
    
    # 백그라운드에서 알림 전송
    if Setting.get('kakao_integration')
      KakaoConsultationJob.perform_later(
        'send_notification', 
        id, 
        { 'message' => "상담원이 복귀했습니다. 언제든지 문의해 주세요." }
      )
    end
  end

  def create_ticket_if_needed
    return unless Setting.get('kakao_auto_create_ticket')
    return if ticket.present?

    # 기본 그룹 찾기
    group = Group.find_by(name: 'Users') || Group.first

    new_ticket = Ticket.create!(
      title: "카카오톡 상담 - #{customer.fullname}",
      customer: customer,
      group: group,
      state: Ticket::State.find_by(name: 'new'),
      priority: Ticket::Priority.find_by(name: '2 normal'),
      preferences: {
        channel: 'kakao',
        kakao_consultation_id: id,
        kakao_user_id: kakao_user_id
      }
    )

    # 상담 메시지들을 티켓 아티클로 변환
    create_articles_from_messages(new_ticket)

    update!(ticket: new_ticket)
  end

  def create_articles_from_messages(ticket)
    messages.order(:sent_at).each do |message|
      Article.create!(
        ticket: ticket,
        from: message.sender_type == 'customer' ? customer.fullname : message.sender_user&.fullname || 'Agent',
        to: message.sender_type == 'customer' ? 'Support' : customer.fullname,
        subject: ticket.title,
        body: message.content,
        content_type: 'text/plain',
        type: Ticket::Article::Type.find_by(name: 'note'),
        sender: Ticket::Article::Sender.find_by(name: message.sender_type.capitalize),
        internal: false,
        created_at: message.sent_at,
        preferences: {
          channel: 'kakao',
          kakao_message_id: message.id
        }
      )
    end
  end

  def notify_agents_consultation_ended
    Sessions.broadcast(
      {
        event: 'kakao_consultation_ended',
        data: {
          consultation_id: id,
          kakao_user_id: kakao_user_id,
          customer_name: customer.fullname,
          ended_at: ended_at,
          duration: duration
        }
      }
    )
  end

  def send_agent_away_notification
    KakaoInternalApiService.send_system_message(
      kakao_user_id,
      "상담원이 잠시 자리를 비웠습니다. 메시지를 남겨주시면 확인 후 답변드리겠습니다."
    )
  end

  def send_agent_return_notification
    KakaoInternalApiService.send_system_message(
      kakao_user_id,
      "상담원이 복귀했습니다. 언제든지 문의해 주세요."
    )
  end

  def update_consultation_statistics
    # 상담 통계 업데이트 로직
    # 캐시나 별도 통계 테이블에 데이터 저장
    Rails.cache.increment('kakao_consultations_completed_today')
    
    # 평균 상담 시간 업데이트
    if duration
      avg_key = 'kakao_average_consultation_duration'
      current_avg = Rails.cache.read(avg_key) || 0
      new_avg = (current_avg + duration.to_f) / 2
      Rails.cache.write(avg_key, new_avg, expires_in: 1.day)
    end
  end
end