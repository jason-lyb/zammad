# app/models/channel/driver/kakao.rb
class Channel::Driver::Kakao

  def initialize(params = {})
    @channel = params[:channel]
  end

  def send(article, notification = false)
    return if !Setting.get('kakao_integration')
    return if article.internal?
    return if article.sender.name != 'Agent'

    # 카카오톡 상담 채팅 찾기
    ticket = article.ticket
    kakao_consultation = find_kakao_consultation(ticket)
    
    return unless kakao_consultation

    # 내부 API로 메시지 전송
    result = KakaoInternalApiService.send_message(
      kakao_consultation.kakao_user_id,
      article.body,
      kakao_consultation.id
    )

    # 전송 결과를 article preferences에 저장
    article.preferences[:kakao_delivery] = {
      status: result[:success] ? 'sent' : 'failed',
      delivery_id: result[:delivery_id],
      error: result[:error],
      sent_at: Time.current
    }
    article.save!

    Rails.logger.info "KakaoTalk message #{result[:success] ? 'sent' : 'failed'}: #{article.id}"
  end

  def disconnect
    # 연결 해제 시 처리할 작업 없음
  end

  private

  def find_kakao_consultation(ticket)
    # 티켓의 첫 번째 article에서 카카오톡 정보 확인
    first_article = ticket.articles.first
    return unless first_article&.preferences&.dig('channel') == 'kakao'

    kakao_user_id = first_article.preferences['kakao_user_id']
    return unless kakao_user_id

    # 활성 상담 찾기
    KakaoConsultation.find_by(
      kakao_user_id: kakao_user_id,
      status: ['active', 'agent_away']
    )
  end
end