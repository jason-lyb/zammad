class KakaoChatController < ApplicationController
  prepend_before_action -> { authentication_check && authorize! }

  # 카카오톡 상담 세션 목록
  def sessions
    return render json: { error: 'KakaoTalk integration not enabled' }, status: :forbidden unless kakao_integration_enabled?

    # 현재 사용자가 상담원인지 확인
    return render json: { error: 'Access denied' }, status: :forbidden unless current_user.permissions?(['chat.agent'])

    # 세션 목록 조회 (최근 순으로 정렬)
    sessions = KakaoConsultationSession.includes(:agent, :kakao_consultation_messages)
                                      .active
                                      .recent
                                      .limit(50)

    # JSON 응답 데이터 구성
    sessions_data = sessions.map do |session|

      {
        id: session.id,
        session_id: session.session_id,
        customer_name: session.customer_info_data['name'] || '알 수 없음',
        customer_id: session.customer_id,
        status: session.status,
        agent_name: session.agent&.fullname,
        agent_id: session.agent_id,
        last_message_content: session.last_message_content,
        last_message_at: session.last_message_at,
        last_message_sender: session.last_message_sender,
        unread_count: session.unread_count,
        duration: session.duration_formatted,
        created_at: session.created_at,
        tags: session.tags_array
      }
    end

    render json: {
      sessions: sessions_data,
      total: sessions_data.length
    }
  end

  # 특정 카카오톡 상담 세션의 메시지 목록
  def messages
    session = find_session
    return unless session

    # 세션 접근 권한 확인
    return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)

    # 메시지 목록 조회
    messages = session.kakao_consultation_messages
                     .recent
                     .includes(:kakao_consultation_session)

    # 고객이 보낸 메시지들을 읽음 처리 (현재 사용자가 담당 상담원인 경우)
    if session.agent == current_user
      unread_messages = messages.where(sender_type: 'customer', read_by_agent: false)
      unread_messages.update_all(read_by_agent: true, read_at: Time.current)
    end

    messages_data = messages.map do |message|
      {
        id: message.id,
        content: message.content,
        sender_type: message.sender_type,
        sender_name: message.sender_name,
        message_type: message.message_type,
        sent_at: message.sent_at,
        read_by_agent: message.read_by_agent,
        preferences: message.preferences
      }
    end

    render json: {
      session: {
        id: session.id,
        session_id: session.session_id,
        customer_name: session.customer_info_data['name'] || '알 수 없음',
        customer_info: session.customer_info_data,
        status: session.status,
        agent_name: session.agent&.fullname,
        started_at: session.started_at,
        duration: session.duration_formatted
      },
      messages: messages_data,
      total: messages_data.length
    }
  end

  # 메시지 전송
  def send_message
    session = find_session
    return unless session

    return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)
    return render json: { error: 'Session is not active' }, status: :bad_request unless session.status == 'active'

    content = params[:content]&.strip
    return render json: { error: 'Message content is required' }, status: :bad_request if content.blank?

    begin
      # 메시지 생성
      message = session.kakao_consultation_messages.create!(
        content: content,
        sender_type: 'agent',
        sender_user: current_user,
        sent_at: Time.current,
        message_type: params[:message_type] || 'text',
        preferences: {
          message_type: params[:message_type] || 'text',
          attachments: params[:attachments] || []
        }
      )

      # 세션의 마지막 메시지 시간 업데이트
      session.update!(last_message_at: message.sent_at)

      # 실제 카카오톡 API로 메시지 전송
      if send_to_kakao_api(session, content)
        render json: {
          message: {
            id: message.id,
            content: message.content,
            sender_type: message.sender_type,
            sender_name: message.sender_name,
            sent_at: message.sent_at,
            message_type: message.message_type
          }
        }
      else
        # API 전송 실패 시 메시지 삭제
        message.destroy
        render json: { error: 'Failed to send message to KakaoTalk' }, status: :internal_server_error
      end

    rescue StandardError => e
      Rails.logger.error "Failed to send message: #{e.message}"
      render json: { error: 'Failed to send message' }, status: :internal_server_error
    end
  end

  # 상담 시작 (상담원 배정)
  def start_consultation
    session = find_session
    return unless session

    return render json: { error: 'Session already has an agent' }, status: :bad_request if session.agent_id.present?

    begin
      session.start_consultation!(current_user)
      
      # 시스템 메시지 추가
      session.kakao_consultation_messages.create!(
        content: "#{current_user.fullname} 상담원이 상담을 시작했습니다.",
        sender_type: 'system',
        sent_at: Time.current,
        message_type: 'system'
      )
      
      render json: {
        session: {
          id: session.id,
          session_id: session.session_id,
          status: session.status,
          agent_name: session.agent.fullname,
          started_at: session.started_at
        }
      }
    rescue StandardError => e
      Rails.logger.error "Failed to start consultation: #{e.message}"
      render json: { error: 'Failed to start consultation' }, status: :internal_server_error
    end
  end

  # 상담 종료
  def end_session
    session = find_session
    return unless session

    return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)

    begin
      session.end_consultation!
      
      # 시스템 메시지 추가
      session.kakao_consultation_messages.create!(
        content: "상담이 종료되었습니다.",
        sender_type: 'system',
        sent_at: Time.current,
        message_type: 'system'
      )
      
      # 카카오톡 API에 세션 종료 알림
      notify_session_end_to_kakao(session)
      
      render json: {
        session: {
          id: session.id,
          session_id: session.session_id,
          status: session.status,
          ended_at: session.ended_at,
          duration: session.duration_formatted
        }
      }
    rescue StandardError => e
      Rails.logger.error "Failed to end session: #{e.message}"
      render json: { error: 'Failed to end session' }, status: :internal_server_error
    end
  end

  # 상담 세션 상세 정보
  def show
    session = find_session
    return unless session

    return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)

    # 읽지 않은 메시지 수
    unread_count = session.kakao_consultation_messages
                         .where(sender_type: 'customer', read_by_agent: false)
                         .count

    render json: {
      session: {
        id: session.id,
        session_id: session.session_id,
        customer_name: session.customer_info_data['name'] || '알 수 없음',
        customer_info: session.customer_info_data,
        status: session.status,
        agent_name: session.agent&.fullname,
        agent_id: session.agent_id,
        started_at: session.started_at,
        ended_at: session.ended_at,
        duration: session.duration_formatted,
        unread_count: unread_count,
        tags: session.tags_array,
        created_at: session.created_at
      }
    }
  end

  private

  def find_session
    session = if params[:id].to_s.start_with?('kakao_')
                KakaoConsultationSession.find_by(session_id: params[:id])
              else
                KakaoConsultationSession.find_by(id: params[:id])
              end

    unless session
      render json: { error: 'Session not found' }, status: :not_found
      return nil
    end

    session
  end

  def can_access_session?(session)
    # 관리자는 모든 세션에 접근 가능
    return true if current_user.permissions?(['admin'])
    
    # 배정되지 않은 세션은 모든 상담원이 접근 가능
    return true if session.agent_id.blank?
    
    # 배정된 상담원만 접근 가능
    session.agent_id == current_user.id
  end

  def kakao_integration_enabled?
    Setting.get('kakao_integration')
  end

  def send_to_kakao_api(session, content)
    # 실제 카카오톡 상담톡 API 호출
    # TODO: 카카오톡 API 연동 구현
    begin
      # KakaoConsultationApiService.send_message(session.session_id, content)
      true  # 임시로 성공 반환
    rescue StandardError => e
      Rails.logger.error "KakaoTalk API error: #{e.message}"
      false
    end
  end

  def notify_session_end_to_kakao(session)
    # 카카오톡 API에 세션 종료 알림
    # TODO: 카카오톡 API 연동 구현
    begin
      # KakaoConsultationApiService.end_session(session.session_id)
      true
    rescue StandardError => e
      Rails.logger.error "Failed to notify session end to KakaoTalk: #{e.message}"
      false
    end
  end
end