class KakaoChatController < ApplicationController
  prepend_before_action -> { authentication_check && authorize! }, except: [:receive_message]
  skip_before_action :verify_csrf_token, only: [:receive_message]

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
        user_key: session.user_key,
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

  # 읽지 않은 메시지 총 개수 조회
  def unread_count
    return render json: { error: 'KakaoTalk integration not enabled' }, status: :forbidden unless kakao_integration_enabled?
    return render json: { error: 'Access denied' }, status: :forbidden unless current_user.permissions?(['chat.agent'])

    # waiting 상태 세션 수 + active 상태 세션의 unread_count 합계
    waiting_count = KakaoConsultationSession.where(status: 'waiting').count
    unread_count = KakaoConsultationSession.where(status: 'active').sum(:unread_count)
    total_count = waiting_count + unread_count

    render json: { count: total_count }
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
      if unread_messages.any?
        unread_messages.update_all(read_by_agent: true, read_at: Time.current)
        
        # 세션의 unread_count를 0으로 리셋
        session.update!(unread_count: 0)
        Rails.logger.info "Reset unread_count for session #{session.session_id} to 0"
      end
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

  # 카카오톡에서 메시지 수신 (Webhook)
  def receive_message
    # Zammad 기본 API 토큰 인증 사용
    return render json: { error: 'API token authentication required' }, status: :unauthorized unless verify_zammad_api_token
    
    # 카카오톡 상담톡 API에서 메시지 수신 시 호출되는 엔드포인트
    user_key = params[:user_key]
    session_id = params[:session_id]
    time = params[:time]
    serial_number = params[:serial_number]
    content = params[:content]
    contents = params[:contents] # 복합 컨텐츠 (이미지, 파일 등)
    message_type = params[:type]
    sender_type = params[:sender_type] || 'customer' # 기본값은 customer
    agent_id = params[:agent_id] # 상담원 ID (상담원 메시지인 경우)

    return render json: { error: 'user_key is required' }, status: :bad_request if user_key.blank?
    return render json: { error: 'session_id is required' }, status: :bad_request if session_id.blank?
    return render json: { error: 'content or contents is required' }, status: :bad_request if content.blank? && contents.blank?
    return render json: { error: 'sender_type must be customer or agent' }, status: :bad_request unless %w[customer agent].include?(sender_type)
    
    # 상담원 메시지인 경우 agent_id 필수 체크
    if sender_type == 'agent' && agent_id.blank?
      return render json: { error: 'agent_id is required for agent messages' }, status: :bad_request
    end

    begin
      ActiveRecord::Base.transaction do
        # 1. 세션 찾기 또는 생성
        session = find_or_create_session_by_kakao_data(session_id, user_key)
        
        # 2. 메시지 생성
        message = create_message_from_kakao(session, {
          content: content,
          contents: contents,
          type: message_type,
          sender_type: sender_type,
          agent_id: agent_id,
          time: time,
          serial_number: serial_number,
          user_key: user_key
        })
        
        # 3. 세션 정보 업데이트
        update_session_info(session, message)
        
        # 4. 통계 정보 업데이트
        update_session_stats(session, message)
        
        # 5. 실시간 알림 전송 (WebSocket 등)
        notify_agents(session, message)
        
        render json: {
          status: 'success',
          session_id: session.session_id,
          message_id: message.id,
          serial_number: serial_number
        }
      end
    rescue StandardError => e
      Rails.logger.error "Failed to receive kakao message: #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { 
        status: 'error', 
        message: 'Failed to process kakao message',
        error: e.message 
      }, status: :internal_server_error
    end
  end

  private

  # Zammad 기본 API 토큰 인증 사용
  def verify_zammad_api_token
    # API 토큰 접근이 비활성화된 경우 체크
    if Setting.get('api_token_access') == false
      Rails.logger.warn "API token access is disabled in settings"
      return false
    end
    
    # HTTP Authorization 헤더에서 토큰 추출
    token_string = nil
    authenticate_with_http_token do |token, _options|
      token_string = token
    end
    
    # 헤더에 토큰이 없으면 파라미터에서 확인
    token_string ||= params[:token] || params[:api_token]
    
    return false if token_string.blank?
    
    # Zammad Token 모델을 사용하여 토큰 검증
    user = Token.check(
      action: 'api',
      token: token_string,
      inactive_user: true
    )
    
    if user
      # 토큰 사용 시간 업데이트
      token = Token.find_by(token: token_string)
      if token
        token.last_used_at = Time.zone.now
        token.save!
        
        # 토큰 만료 확인
        if token.expired?
          Rails.logger.warn "API token expired: #{token_string[0..8]}..."
          return false
        end
        
        @_token = token # Pundit 인증을 위해 저장
        @_token_auth = token_string
        
        Rails.logger.info "KakaoTalk webhook authenticated with API token for user: #{user.login}"
        return true
      end
    end
    
    Rails.logger.warn "Invalid API token for KakaoTalk webhook: #{token_string[0..8] if token_string}..."
    false
  end

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

  # 세션 찾기 또는 생성 (카카오톡 데이터 기반)
  def find_or_create_session_by_kakao_data(session_id, user_key)
    session = KakaoConsultationSession.find_by(session_id: session_id)
    
    unless session
      # 새 세션 생성
      customer_info = {
        'user_key' => user_key,
        'name' => "고객_#{user_key[-6..-1]}", # user_key 뒷자리로 임시 이름 생성
        'created_from' => 'kakao_webhook'
      }
      
      session = KakaoConsultationSession.create!(
        session_id: session_id,
        user_key: user_key,
        customer_name: customer_info['name'],
        customer_info: customer_info.to_json,
        status: 'waiting',
        last_message_at: Time.current,
        priority: 1
      )
      
      # 통계 테이블 초기화
      KakaoConsultationStats.create!(
        kakao_consultation_session: session,
        total_messages: 0,
        customer_messages: 0,
        agent_messages: 0
      )
      
      Rails.logger.info "Created new KakaoTalk session: #{session_id} for user_key: #{user_key}"
    end
    
    session
  end

  # 카카오톡 메시지 생성
  def create_message_from_kakao(session, kakao_data)
    content = kakao_data[:content]
    contents = kakao_data[:contents]
    message_type = kakao_data[:type] || 'text'
    sender_type = kakao_data[:sender_type] || 'customer'
    agent_id = kakao_data[:agent_id]
    time_str = kakao_data[:time]
    serial_number = kakao_data[:serial_number]
    user_key = kakao_data[:user_key]
    
    # 중복 메시지 확인 (serial_number 기준)
    if serial_number.present?
      existing_message = session.kakao_consultation_messages
                               .where("preferences LIKE ?", "%\"serial_number\":\"#{serial_number}\"%")
                               .first
      if existing_message
        Rails.logger.info "Duplicate message ignored: serial_number=#{serial_number}"
        return existing_message
      end
    end
    
    # 시간 파싱 (카카오톡 시간 포맷에 맞춰 조정)
    sent_at = if time_str.present?
                begin
                  # 카카오톡 시간 포맷이 ISO 8601이 아닐 수 있으므로 여러 형식 시도
                  Time.parse(time_str)
                rescue ArgumentError
                  # 파싱 실패 시 현재 시간 사용
                  Time.current
                end
              else
                Time.current
              end
    
    # 메시지 내용 처리
    final_content = if content.present?
                      content
                    elsif contents.present?
                      # contents가 JSON이나 특별한 형태일 경우 처리
                      case message_type
                      when 'image'
                        "[이미지]"
                      when 'file'
                        "[파일]"
                      when 'location'
                        "[위치 정보]"
                      else
                        contents.is_a?(String) ? contents : contents.to_s
                      end
                    else
                      "[알 수 없는 메시지]"
                    end
    
    # 첨부파일/컨텐츠 정보 처리
    attachments_data = if contents.present? && contents != content
                         [
                           {
                             type: message_type,
                             content: contents,
                             serial_number: serial_number
                           }
                         ]
                       else
                         []
                       end
    
    # 발신자 정보 설정
    sender_name = case sender_type
                  when 'customer'
                    session.customer_name
                  when 'agent'
                    if agent_id.present?
                      # agent_id로 실제 상담원 찾기
                      agent = User.find_by(id: agent_id)
                      if agent
                        agent.fullname
                      else
                        Rails.logger.warn "Agent not found for agent_id: #{agent_id}"
                        kakao_data[:agent_name] || '상담원'
                      end
                    else
                      # agent_id가 없으면 전달받은 이름 또는 기본값 사용
                      kakao_data[:agent_name] || '상담원'
                    end
                  else
                    '알 수 없음'
                  end
    
    # 상담원 메시지인 경우 세션에 상담원 할당 및 상태 변경
    if sender_type == 'agent' && agent_id.present?
      agent = User.find_by(id: agent_id)
      if agent
        update_data = {}
        
        # 상담원이 할당되지 않은 경우 할당
        if session.agent_id.blank?
          update_data[:agent_id] = agent_id
          Rails.logger.info "Assigned agent #{agent.fullname} to session #{session.session_id}"
        end
        
        # 세션 상태가 'waiting'인 경우 'active'로 변경
        if session.status == 'waiting'
          update_data[:status] = 'active'
          Rails.logger.info "Changed session #{session.session_id} status from waiting to active"
        end
        
        # 업데이트할 데이터가 있으면 적용
        session.update!(update_data) if update_data.any?
      end
    end
    
    message = session.kakao_consultation_messages.create!(
      message_id: serial_number, # 카카오톡의 serial_number를 message_id로 사용
      sender_type: sender_type,
      sender_id: (sender_type == 'agent' && agent_id.present?) ? agent_id : nil,
      sender_name: sender_name,
      content: final_content,
      sent_at: sent_at,
      is_read: false,
      preferences: {
        message_type: message_type,
        sender_type: sender_type,
        agent_id: agent_id,
        kakao_data: kakao_data,
        user_key: user_key,
        serial_number: serial_number
      }
    )
    
    # Set attachments data using the setter method
    message.attachments_data = attachments_data
    message.save!
    
    Rails.logger.info "Created kakao message for session #{session.session_id}: type=#{message_type}, content=#{final_content[0..50]}..."
    message
  end

  # 세션 정보 업데이트
  def update_session_info(session, message)
    # 세션 정보 업데이트
    update_data = {
      last_message_content: message.content,
      last_message_sender: message.sender_type,
      last_message_at: message.sent_at
    }
    
    # 고객 메시지인 경우 unread_count 증가
    if message.sender_type == 'customer'
      session.increment!(:unread_count)
      Rails.logger.info "Incremented unread_count for session #{session.session_id}: #{session.unread_count}"
    end
    
    # 첫 메시지인 경우 started_at 설정
    if session.started_at.nil?
      update_data[:started_at] = message.sent_at
    end
    
    session.update!(update_data)
    
    Rails.logger.info "Updated session #{session.session_id}"
  end

  # 통계 정보 업데이트
  def update_session_stats(session, message)
    stats = session.kakao_consultation_stats || session.create_kakao_consultation_stats!(
      total_messages: 0,
      customer_messages: 0,
      agent_messages: 0
    )
    
    # 메시지 카운트 업데이트
    stats.increment!(:total_messages)
    stats.increment!(:customer_messages) if message.sender_type == 'customer'
    stats.increment!(:agent_messages) if message.sender_type == 'agent'
    
    # 세션 시간 계산
    if session.started_at && session.ended_at
      duration = (session.ended_at - session.started_at).to_i
      stats.update!(session_duration: duration)
    end
    
    # 평균 응답 시간 계산 (마지막 고객 메시지 이후 첫 상담원 응답까지의 시간)
    if message.sender_type == 'agent'
      last_customer_message = session.kakao_consultation_messages
                                    .where(sender_type: 'customer')
                                    .where('sent_at < ?', message.sent_at)
                                    .order(sent_at: :desc)
                                    .first
      
      if last_customer_message
        response_time = (message.sent_at - last_customer_message.sent_at).to_i
        
        # 평균 응답 시간 계산 (기존 평균과 새 응답 시간의 가중 평균)
        agent_message_count = stats.agent_messages
        if agent_message_count > 1 && stats.response_time_avg
          new_avg = ((stats.response_time_avg * (agent_message_count - 1)) + response_time) / agent_message_count
          stats.update!(response_time_avg: new_avg.to_i)
        else
          stats.update!(response_time_avg: response_time)
        end
      end
    end
    
    Rails.logger.info "Updated stats for session #{session.session_id}: total=#{stats.total_messages}, customer=#{stats.customer_messages}, agent=#{stats.agent_messages}"
  end

  # 상담원들에게 실시간 알림
  def notify_agents(session, message)
    # WebSocket을 통한 실시간 알림 (CTI 패턴 따라 구현)
    begin
      # CTI의 cti_list_push 패턴을 따라 구현
      notification_data = {
        event: 'kakao_message_received',
        data: {
          session_id: session.session_id,
          session: {
            id: session.id,
            customer_name: session.customer_name,
            status: session.status,
            unread_count: session.unread_count
          },
          message: {
            id: message.id,
            content: message.content,
            sender_type: message.sender_type,
            sent_at: message.sent_at
          }
        }
      }
      
      # CTI 방식: Sessions.broadcast로 모든 클라이언트에 전송
      Sessions.broadcast(notification_data)
      Rails.logger.info "Broadcasted kakao_message_received event for session #{session.session_id}"
      
    rescue StandardError => e
      Rails.logger.error "Failed to send real-time notification: #{e.message}"
    end
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

  def calculate_total_unread_count
    KakaoConsultationSession.active.sum(:unread_count) + 
    KakaoConsultationSession.where(status: 'waiting').count
  end
end