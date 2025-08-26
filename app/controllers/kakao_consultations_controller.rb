# /opt/zammad/app/controllers/kakao_consultations_controller.rb
class KakaoConsultationsController < ApplicationController
  # Zammad 기본 인증 사용
  before_action :authentication_check, except: [:receive_message, :customer_end_consultation]
  
  # 웹훅 토큰 인증 (외부 API 요청용)
  before_action :verify_webhook_token, only: [:receive_message, :customer_end_consultation]

  def receive_message
    kakao_user_id = params[:kakao_user_id]
    message_content = params[:message]
    
    return render_error('Invalid parameters') unless kakao_user_id.present? && message_content.present?

    begin
      consultation = KakaoConsultation.find_or_create_for_kakao_user(kakao_user_id)
      message = consultation.add_message(message_content, 'customer')

      render json: {
        status: 'success',
        consultation_id: consultation.id,
        message_id: message.id
      }
    rescue => e
      Rails.logger.error "KakaoTalk message error: #{e.message}"
      render_error('Internal server error')
    end
  end

  def send_message
    consultation_id = params[:consultation_id]
    message_content = params[:message]
    
    return render_error('Invalid parameters') unless consultation_id.present? && message_content.present?

    begin
      consultation = KakaoConsultation.find(consultation_id)
      message = consultation.add_message(message_content, 'agent', current_user)

      # 내부 API로 전송
      result = KakaoInternalApiService.send_message(
        consultation.kakao_user_id,
        message_content,
        consultation.id
      )

      if result[:success]
        render json: { status: 'success', message_id: message.id }
      else
        render_error('Message delivery failed')
      end
    rescue => e
      Rails.logger.error "KakaoTalk send error: #{e.message}"
      render_error('Internal server error')
    end
  end

  def customer_end_consultation
    kakao_user_id = params[:kakao_user_id]
    
    return render_error('Invalid kakao_user_id') unless kakao_user_id.present?

    begin
      consultation = KakaoConsultation.active_consultations.find_by(kakao_user_id: kakao_user_id)
      
      if consultation
        consultation.end_by_customer!
        render json: { status: 'success', consultation_id: consultation.id }
      else
        render_error('No active consultation found', 404)
      end
    rescue => e
      Rails.logger.error "KakaoTalk end consultation error: #{e.message}"
      render_error('Internal server error')
    end
  end

  private

  def verify_webhook_token
    token = request.headers['Authorization']&.gsub('Bearer ', '')
    expected_token = Setting.get('kakao_webhook_token')
    
    unless token.present? && expected_token.present? && 
           ActiveSupport::SecurityUtils.secure_compare(token, expected_token)
      render json: { error: 'Unauthorized' }, status: 401
    end
  end

  def check_kakao_integration_enabled
    unless Setting.get('kakao_integration')
      render json: { error: 'KakaoTalk integration is disabled' }, status: 403
    end
  end

  def render_error(message, status = 500)
    render json: { status: 'error', message: message }, status: status
  end
end