# app/models/kakao_internal_api_service.rb
class KakaoInternalApiService

  def self.base_url
    Setting.get('kakao_internal_api_endpoint')
  end

  def self.api_token
    Setting.get('kakao_internal_api_token')
  end

  def self.enabled?
    Setting.get('kakao_integration') && base_url.present? && api_token.present?
  end

  # 메시지 전송
  def self.send_message(kakao_user_id, message, consultation_id)
    return { success: false, error: 'KakaoTalk integration disabled' } unless enabled?

    begin
      uri = URI("#{base_url}/api/kakao/send-to-dealer")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{api_token}"
      request['User-Agent'] = "Zammad-KakaoIntegration/#{Version.get}"
      request['X-Request-ID'] = SecureRandom.uuid

      request.body = {
        kakao_user_id: kakao_user_id,
        message: sanitize_message(message),
        consultation_id: consultation_id,
        timestamp: Time.zone.now.iso8601,
        source: 'zammad'
      }.to_json

      response = http.request(request)
      handle_response(response)

    rescue Net::TimeoutError, Net::OpenTimeout
      Rails.logger.error "KakaoTalk API timeout for user: #{kakao_user_id}"
      { success: false, error: 'Request timeout' }
    rescue => e
      Rails.logger.error "KakaoTalk API error: #{e.message}"
      { success: false, error: e.message }
    end
  end

  # 시스템 메시지 전송
  def self.send_system_message(kakao_user_id, message)
    return unless enabled?

    send_message(kakao_user_id, "[시스템] #{message}", nil)
  end

  # API 연결 상태 확인
  def self.health_check
    return false unless enabled?

    begin
      uri = URI("#{base_url}/api/kakao/health")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{api_token}"

      response = http.request(request)
      response.code.to_i == 200

    rescue
      false
    end
  end

  private

  def self.handle_response(response)
    case response.code.to_i
    when 200..299
      begin
        parsed = JSON.parse(response.body)
        {
          success: true,
          delivery_id: parsed['delivery_id'],
          data: parsed
        }
      rescue JSON::ParserError
        { success: false, error: 'Invalid JSON response' }
      end
    when 401
      Rails.logger.error "KakaoTalk API authentication failed"
      { success: false, error: 'Authentication failed' }
    when 429
      Rails.logger.warn "KakaoTalk API rate limit exceeded"
      { success: false, error: 'Rate limit exceeded' }
    else
      Rails.logger.error "KakaoTalk API error: HTTP #{response.code}"
      { success: false, error: "HTTP #{response.code}: #{response.message}" }
    end
  end

  def self.sanitize_message(message)
    # XSS 방지 및 메시지 정리
    message.to_s.strip.gsub(/[[:cntrl:]]/, '')
  end
end