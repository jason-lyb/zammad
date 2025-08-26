# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class Integration::KakaoController < ApplicationController
  prepend_before_action :authenticate_and_authorize!

  def index
    render json: {
      kakao_integration: Setting.get('kakao_integration'),
      kakao_api_endpoint: Setting.get('kakao_api_endpoint'),
      kakao_api_token: Setting.get('kakao_api_token'),
      kakao_webhook_token: Setting.get('kakao_webhook_token'),
      kakao_session_timeout: Setting.get('kakao_session_timeout'),
      kakao_auto_create_ticket: Setting.get('kakao_auto_create_ticket')
    }
  end

  def update
    begin
      # Get permitted parameters
      update_params = params.permit(
        :kakao_integration,
        :kakao_api_endpoint,
        :kakao_api_token,
        :kakao_webhook_token,
        :kakao_session_timeout,
        :kakao_auto_create_ticket,
        :integration # for form compatibility
      )

      # Update settings with immediate database persistence
      update_params.each do |key, value|
        next if value.nil?
        
        # Handle form checkbox
        if key == 'integration'
          Setting.set('kakao_integration', value.to_s == 'true', { notify: true, force: true })
          Rails.logger.info "카카오 연동 설정 업데이트: kakao_integration = #{value.to_s == 'true'}"
          next
        end
        
        # Convert session timeout to integer
        if key == 'kakao_session_timeout'
          value = value.to_i
          value = 30 if value <= 0
        end
        
        # Set with force to ensure immediate database save
        Setting.set(key, value, { notify: true, force: true })
        Rails.logger.info "카카오 설정 업데이트: #{key} = #{value}"
      end

      # Force database commit
      ActiveRecord::Base.connection.commit_db_transaction if ActiveRecord::Base.connection.transaction_open?

      render json: { 
        result: 'ok', 
        message: __('설정이 저장되었습니다.'),
        settings: get_current_settings 
      }

    rescue => e
      Rails.logger.error "카카오 설정 저장 실패: #{e.message}"
      render json: { 
        result: 'failed', 
        message: __('설정 저장에 실패했습니다: %s', e.message) 
      }
    end
  end

  def test
    begin
      # Get configuration from request parameters
      config = params_for_test

      # Basic validation
      if config[:api_endpoint].blank? || config[:api_token].blank?
        render json: {
          result: 'failed',
          message: __('상담톡 API 서버 URL과 인증 토큰이 필요합니다.')
        }
        return
      end

      # Test consultation API server connection
      success = test_consultation_api_connection(config)

      if success
        render json: {
          result: 'ok',
          message: __('상담톡 API 서버 연결이 성공했습니다!')
        }
      else
        render json: {
          result: 'failed',
          message: __('상담톡 API 서버에 연결할 수 없습니다. 설정을 확인해주세요.')
        }
      end

    rescue => e
      Rails.logger.error "상담톡 API 서버 테스트 실패: #{e.message}"
      render json: {
        result: 'failed',
        message: __('연결 테스트 실패: %s', e.message)
      }
    end
  end

  private

  def params_for_test
    params.permit(:api_endpoint, :api_token, :webhook_token, :session_timeout)
  end

  def get_current_settings
    {
      kakao_integration: Setting.get('kakao_integration'),
      kakao_api_endpoint: Setting.get('kakao_api_endpoint'),
      kakao_api_token: Setting.get('kakao_api_token').present? ? '[설정됨]' : '',
      kakao_webhook_token: Setting.get('kakao_webhook_token').present? ? '[설정됨]' : '',
      kakao_session_timeout: Setting.get('kakao_session_timeout') || 30,
      kakao_auto_create_ticket: Setting.get('kakao_auto_create_ticket')
    }
  end

  def test_consultation_api_connection(config)
    # 상담톡 API 서버 연결 테스트 로직
    uri = URI.parse(config[:api_endpoint])
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    
    # 상담톡 API 서버에 ping 또는 health check 요청
    # 예: GET /health 또는 POST /test-connection
    
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = 5
      http.read_timeout = 5
      
      # 간단한 health check 요청
      request = Net::HTTP::Get.new("#{uri.path}/health".squeeze('/'))
      request['Authorization'] = "Bearer #{config[:api_token]}" if config[:api_token].present?
      request['Content-Type'] = 'application/json'
      
      response = http.request(request)
      response.code.to_i == 200
    rescue
      false
    end
  end
end
