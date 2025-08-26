# == Schema Information
#
# Table name: kakao_consultation_stats
#
class KakaoConsultationStats < ActiveRecord::Base
  belongs_to :kakao_consultation_session

  validates :total_messages, :customer_messages, :agent_messages, numericality: { greater_than_or_equal_to: 0 }
  validates :response_time_avg, :session_duration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :satisfaction_score, numericality: { in: 0.0..5.0 }, allow_nil: true

  # 응답 시간을 포맷팅
  def response_time_formatted
    return '0초' unless response_time_avg&.positive?
    
    if response_time_avg < 60
      "#{response_time_avg}초"
    elsif response_time_avg < 3600
      minutes = response_time_avg / 60
      seconds = response_time_avg % 60
      "#{minutes}분 #{seconds}초"
    else
      hours = response_time_avg / 3600
      minutes = (response_time_avg % 3600) / 60
      "#{hours}시간 #{minutes}분"
    end
  end

  # 세션 시간을 포맷팅
  def session_duration_formatted
    return '0분' unless session_duration&.positive?
    
    if session_duration < 60
      "#{session_duration}초"
    elsif session_duration < 3600
      minutes = session_duration / 60
      seconds = session_duration % 60
      seconds > 0 ? "#{minutes}분 #{seconds}초" : "#{minutes}분"
    else
      hours = session_duration / 3600
      minutes = (session_duration % 3600) / 60
      if minutes > 0
        "#{hours}시간 #{minutes}분"
      else
        "#{hours}시간"
      end
    end
  end

  # 응답률 계산 (고객 메시지 대비 상담원 응답)
  def response_rate
    return 0.0 if customer_messages == 0
    (agent_messages.to_f / customer_messages * 100).round(1)
  end

  # 클래스 메서드들 - 전체 통계
  def self.today_count
    KakaoConsultationSession.where(
      created_at: Date.current.beginning_of_day..Date.current.end_of_day
    ).count
  end

  def self.active_count
    KakaoConsultationSession.active.count
  end

  def self.average_duration_today
    sessions = KakaoConsultationSession.where(
      ended_at: Date.current.beginning_of_day..Date.current.end_of_day
    ).where.not(ended_at: nil)

    return 0 if sessions.empty?

    total_duration = sessions.sum(&:duration_in_seconds)
    (total_duration / sessions.count).round(2)
  end

  def self.completion_rate_today
    total = today_count
    return 0 if total.zero?

    completed = KakaoConsultationSession.where(
      created_at: Date.current.beginning_of_day..Date.current.end_of_day,
      status: 'ended'
    ).count

    ((completed.to_f / total) * 100).round(2)
  end

  def self.summary
    {
      today_count: today_count,
      active_count: active_count,
      average_duration: average_duration_today,
      completion_rate: completion_rate_today
    }
  end
end