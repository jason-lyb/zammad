# app/jobs/kakao_consultation_job.rb
class KakaoConsultationJob < ApplicationJob
  queue_as :default

  def perform(action, consultation_id, options = {})
    consultation = KakaoConsultation.find(consultation_id)
    
    case action.to_s
    when 'send_notification'
      send_notification(consultation, options)
    when 'update_statistics'
      update_statistics(consultation)
    when 'cleanup_old_consultations'
      cleanup_old_consultations
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "KakaoConsultation not found: #{consultation_id}"
  rescue => e
    Rails.logger.error "KakaoConsultationJob failed: #{e.message}"
  end

  private

  def send_notification(consultation, options)
    message = options['message']
    return unless message

    KakaoInternalApiService.send_system_message(
      consultation.kakao_user_id,
      message
    )
  end

  def update_statistics(consultation)
    # 상세한 통계 업데이트
    date = consultation.ended_at&.to_date || Date.current
    
    # 일일 통계 업데이트 (예: Redis 또는 별도 테이블)
    Stats.increment("kakao_consultations:#{date}")
    
    if consultation.duration
      Stats.update_average("kakao_duration:#{date}", consultation.duration)
    end
  end

  def cleanup_old_consultations
    # 오래된 종료된 상담 정리 (30일 이전)
    old_consultations = KakaoConsultation.where(
      status: 'customer_ended'
    ).where('ended_at < ?', 30.days.ago)
    
    old_consultations.find_each do |consultation|
      # 메시지만 삭제하고 상담 기록은 유지
      consultation.messages.delete_all
    end
  end
end