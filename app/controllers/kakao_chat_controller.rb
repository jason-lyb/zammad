class KakaoChatController < ApplicationController
  prepend_before_action -> { authentication_check && authorize! }, except: [:receive_message, :send_message_api, :end_session_api, :upload_file_api, :download_file, :file_thumbnail]
  skip_before_action :verify_csrf_token, only: [:receive_message, :send_message_api, :end_session_api, :upload_file_api]

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

    # waiting 상태와 active 상태 세션의 unread_count 합계
    total_count = KakaoConsultationSession.where(status: ['waiting', 'active']).sum(:unread_count)

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

    # 읽음 처리는 프론트엔드에서 명시적으로 호출할 때만 수행
    # mark_messages_as_read_by_user(session, current_user) # 제거됨

    messages_data = messages.map do |message|
      # 첨부 파일 정보 조회
      attached_files = []
      if message.message_type == 'file' && message.has_attachments
        attached_files = KakaoChatFile.where(message: message).map do |file|
          file_response_data(file)
        end
      end

      {
        id: message.id,
        content: message.content,
        sender_type: message.sender_type,
        sender_name: message.sender_name,
        message_type: message.message_type,
        sent_at: message.sent_at,
        read_by_agent: message.read_by_agent,
        preferences: message.preferences,
        has_attachments: message.has_attachments || false,
        attachment_count: message.attachment_count || 0,
        files: attached_files
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
    return render json: { error: 'Session is ended' }, status: :bad_request if session.status == 'ended'

    content = params[:content]&.strip
    return render json: { error: 'Message content is required' }, status: :bad_request if content.blank?

    begin
      # waiting 상태인 경우 active로 변경 (상담원이 첫 메시지를 보낼 때)
      if session.status == 'waiting'
        session.start_consultation!(current_user)
        Rails.logger.info "Session #{session.session_id} started by agent #{current_user.login}"
      end
      
      # 메시지 생성
      message = session.kakao_consultation_messages.create!(
        content: content,
        sender_type: 'agent',
        sender_id: current_user.id,
        sender_name: current_user.fullname,
        sent_at: Time.current,
        preferences: {
          message_type: params[:message_type] || 'text',
          attachments: params[:attachments] || []
        }
      )

      # 세션의 마지막 메시지 정보 업데이트
      session.update!(
        last_message_at: message.sent_at,
        last_message_content: message.content,
        last_message_sender: message.sender_type
      )

      # 통계 업데이트
      update_session_stats(session, message)
      
      # 실시간 알림 전송 (receive_message와 동일하게 적용)
      notify_agents(session, message)

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
        preferences: {
          message_type: 'system'
        }
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
        preferences: {
          message_type: 'system'
        }
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

  # 담당자 변경
  def assign_agent
    session = find_session
    return unless session

    return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)

    agent_id = params[:agent_id]
    return render json: { error: 'Agent ID is required' }, status: :bad_request if agent_id.blank?

    # 상담원 존재 확인
    agent = User.find_by(id: agent_id)
    return render json: { error: 'Agent not found' }, status: :not_found unless agent
    return render json: { error: 'User is not an agent' }, status: :bad_request unless agent.permissions?(['chat.agent'])

    begin
      old_agent = session.agent
      session.update!(agent_id: agent_id)
      
      # 시스템 메시지 추가
      if old_agent
        message_content = "담당자가 #{old_agent.fullname}에서 #{agent.fullname}로 변경되었습니다."
      else
        message_content = "#{agent.fullname} 상담원이 담당자로 배정되었습니다."
      end
      
      session.kakao_consultation_messages.create!(
        content: message_content,
        sender_type: 'system',
        sent_at: Time.current,
        preferences: {
          message_type: 'system'
        }
      )
      
      # 상담원 할당 알림 브로드캐스트
      broadcast_agent_assignment(session, agent)
      
      render json: {
        session: {
          id: session.id,
          session_id: session.session_id,
          agent_id: session.agent_id,
          agent_name: session.agent.fullname,
          status: session.status
        }
      }
    rescue StandardError => e
      Rails.logger.error "Failed to assign agent: #{e.message}"
      render json: { error: 'Failed to assign agent' }, status: :internal_server_error
    end
  end

  # 메시지 읽음 처리
  def mark_messages_as_read
    session = find_session
    return unless session

    return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)

    begin
      # 현재 사용자가 읽음 처리할 수 있는 메시지들을 찾음
      unread_messages = session.kakao_consultation_messages
                              .where(sender_type: 'customer', is_read: false)
      
      if unread_messages.any?
        # 메시지들을 읽음으로 표시
        unread_messages.update_all(is_read: true, read_by_agent: true, read_at: Time.current)
        
        # 세션의 unread_count 직접 업데이트
        new_unread_count = session.kakao_consultation_messages.where(sender_type: 'customer', is_read: false).count
        session.update!(unread_count: new_unread_count)
        
        Rails.logger.info "Marked #{unread_messages.count} messages as read for session #{session.session_id} by #{current_user.login}"
        Rails.logger.info "Updated session unread_count from #{session.unread_count} to #{new_unread_count}"
        
        # 읽음 처리 브로드캐스트
        broadcast_messages_read(session, current_user, new_unread_count)
        
        render json: {
          status: 'success',
          read_count: unread_messages.count,
          unread_count: new_unread_count
        }
      else
        render json: {
          status: 'success',
          read_count: 0,
          unread_count: 0
        }
      end
    rescue StandardError => e
      Rails.logger.error "Failed to mark messages as read: #{e.message}"
      render json: { error: 'Failed to mark messages as read' }, status: :internal_server_error
    end
  end

  # 사용 가능한 상담원 목록
  def available_agents
    return render json: { error: 'KakaoTalk integration not enabled' }, status: :forbidden unless kakao_integration_enabled?
    return render json: { error: 'Access denied' }, status: :forbidden unless current_user.permissions?(['chat.agent'])

    begin
      # chat.agent 권한을 가진 활성 사용자들 조회
      # Zammad에서 권한은 Role.with_permissions를 통해 확인
      agent_role_ids = Role.with_permissions('chat.agent').pluck(:id)
      
      agents = User.joins(:roles)
                   .where(active: true)
                   .where('roles_users.role_id' => agent_role_ids)
                   .distinct
                   .order(:firstname, :lastname)

      agents_data = agents.map do |agent|
        {
          id: agent.id,
          name: agent.fullname,
          login: agent.login,
          email: agent.email
        }
      end

      render json: { agents: agents_data }
    rescue StandardError => e
      Rails.logger.error "Failed to get available agents: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      render json: { error: 'Failed to get available agents' }, status: :internal_server_error
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

  # 범용 메시지 전송 API
  def send_message_api
    # Zammad 기본 API 토큰 인증 사용 (receive_message와 동일)
    return render json: { error: 'API token authentication required' }, status: :unauthorized unless verify_zammad_api_token
    
    # 필수 파라미터 확인
    session_id = params[:session_id]
    content = params[:content]&.strip
    sender_type = params[:sender_type] || 'agent'
    sender_id = params[:sender_id] || params[:agent_id] # agent_id도 지원
    sender_name = params[:sender_name]
    message_type = params[:message_type] || 'text'
    
    return render json: { error: 'session_id is required' }, status: :bad_request if session_id.blank?
    return render json: { error: 'content is required' }, status: :bad_request if content.blank?
    return render json: { error: 'sender_type must be customer, agent, or system' }, status: :bad_request unless %w[customer agent system].include?(sender_type)
    
    # 상담원 메시지인 경우 sender_id 또는 current_user 확인
    if sender_type == 'agent'
      if sender_id.present?
        sender_user = User.find_by(id: sender_id)
        return render json: { error: 'Agent not found' }, status: :not_found unless sender_user
        return render json: { error: 'User is not an agent' }, status: :bad_request unless sender_user.permissions?(['chat.agent'])
        # sender_name이 없으면 실제 agent의 이름 사용
        sender_name = sender_user.fullname if sender_name.blank?
      else
        sender_user = current_user
        sender_id = current_user.id
        sender_name = current_user.fullname if sender_name.blank?
      end
    end
    
    begin
      # 세션 찾기
      session = KakaoConsultationSession.find_by(session_id: session_id)
      return render json: { error: 'Session not found' }, status: :not_found unless session
      
      # 접근 권한 확인 (API 토큰 인증 시에는 스킵)
      # return render json: { error: 'Access denied' }, status: :forbidden unless can_access_session?(session)
      return render json: { error: 'Session is ended' }, status: :bad_request if session.status == 'ended'
      
      # waiting 상태인 경우 active로 변경 (상담원이 첫 메시지를 보낼 때)
      if session.status == 'waiting' && sender_type == 'agent'
        session.start_consultation!(sender_user || current_user)
        Rails.logger.info "Session #{session.session_id} started by agent #{(sender_user || current_user).login}"
      end
      
      # 메시지 생성
      message = session.kakao_consultation_messages.create!(
        content: content,
        sender_type: sender_type,
        sender_id: sender_id,
        sender_name: sender_name || (sender_type == 'system' ? 'System' : '알 수 없음'),
        sent_at: Time.current,
        preferences: {
          message_type: message_type,
          attachments: params[:attachments] || []
        }
      )
      
      # 세션의 마지막 메시지 정보 업데이트
      session.update!(
        last_message_at: message.sent_at,
        last_message_content: message.content,
        last_message_sender: message.sender_type
      )
      
      # 고객 메시지인 경우 unread_count 증가
      if sender_type == 'customer'
        session.increment!(:unread_count)
      end
      
      # 통계 업데이트
      update_session_stats(session, message)
      
      # 실시간 알림 전송
      notify_agents(session, message)
      
      render json: {
        status: 'success',
        message: {
          id: message.id,
          content: message.content,
          sender_type: message.sender_type,
          sender_name: message.sender_name,
          sent_at: message.sent_at,
          message_type: message.message_type
        },
        session: {
          id: session.id,
          session_id: session.session_id,
          status: session.status,
          unread_count: session.unread_count
        }
      }
      
    rescue StandardError => e
      Rails.logger.error "Failed to send message via API: #{e.message}"
      render json: { error: 'Failed to send message' }, status: :internal_server_error
    end
  end

  # 범용 상담 종료 API
  def end_session_api
    # Zammad 기본 API 토큰 인증 사용
    return render json: { error: 'API token authentication required' }, status: :unauthorized unless verify_zammad_api_token
    
    # 필수 파라미터 확인
    session_id = params[:session_id]
    reason = params[:reason] || '상담 완료'
    ended_by = params[:ended_by] || 'agent'
    agent_id = params[:agent_id]
    
    return render json: { error: 'session_id is required' }, status: :bad_request if session_id.blank?
    return render json: { error: 'ended_by must be agent or customer' }, status: :bad_request unless %w[agent customer].include?(ended_by)
    
    begin
      # 세션 조회
      session = KakaoConsultationSession.find_by(session_id: session_id)
      return render json: { error: 'Session not found' }, status: :not_found unless session
      
      # 이미 종료된 세션인지 확인
      return render json: { error: 'Session already ended' }, status: :bad_request if session.status == 'ended'
      
      # 상담원이 종료하는 경우 agent_id 확인
      ending_agent = nil
      if ended_by == 'agent'
        if agent_id.present?
          ending_agent = User.find_by(id: agent_id)
          return render json: { error: 'Agent not found' }, status: :not_found unless ending_agent
          return render json: { error: 'User is not an agent' }, status: :bad_request unless ending_agent.permissions?(['chat.agent'])
        else
          ending_agent = current_user if current_user&.permissions?(['chat.agent'])
        end
      end
      
      # 세션 종료 처리
      update_params = {
        status: 'ended',
        ended_at: Time.current
      }
      
      # end_reason 필드가 존재하는 경우에만 추가
      if session.respond_to?(:end_reason=)
        update_params[:end_reason] = reason
      end
      
      session.update!(update_params)
      
      # 종료 메시지 추가
      end_message_content = if ended_by == 'agent'
        "상담이 종료되었습니다. (종료 사유: #{reason})"
      else
        "고객이 상담을 종료했습니다."
      end
      
      message = session.kakao_consultation_messages.create!(
        content: end_message_content,
        sender_type: 'system',
        sender_name: 'System',
        sent_at: Time.current,
        preferences: {
          message_type: 'system',
          end_reason: reason,
          ended_by: ended_by
        }
      )
      
      # 세션의 마지막 메시지 정보 업데이트
      session.update!(
        last_message_at: message.sent_at,
        last_message_content: message.content,
        last_message_sender: message.sender_type
      )
      
      # 통계 업데이트
      update_session_stats(session, message)
      
      # 실시간 알림 전송
      notify_agents(session, message)
      
      # 카카오톡 API에 종료 알림
      notify_session_end_to_kakao(session)
      
      render json: {
        status: 'success',
        message: 'Session ended successfully',
        session: {
          id: session.id,
          session_id: session.session_id,
          status: session.status,
          ended_at: session.ended_at,
          end_reason: session.respond_to?(:end_reason) ? session.end_reason : reason,
          duration: session.duration_formatted
        },
        end_message: {
          id: message.id,
          content: message.content,
          sender_type: message.sender_type,
          sent_at: message.sent_at
        }
      }
      
    rescue StandardError => e
      Rails.logger.error "Failed to end session via API: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      render json: { 
        error: 'Failed to end session', 
        details: e.message,
        class: e.class.name 
      }, status: :internal_server_error
    end
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
    current_view = params[:current_view] # 현재 활성화된 화면 정보

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
        notify_agents(session, message, current_view)
        
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

  # 파일 업로드 (세션별)
  def upload_file
    return render json: { error: 'KakaoTalk integration not enabled' }, status: :forbidden unless kakao_integration_enabled?
    return render json: { error: 'Access denied' }, status: :forbidden unless current_user.permissions?(['chat.agent'])

    session = KakaoConsultationSession.find_by(session_id: params[:id])
    unless session
      return render json: { error: 'Session not found' }, status: :not_found
    end
    
    unless params[:file].present?
      return render json: { error: 'No file provided' }, status: :bad_request
    end

    begin
      uploaded_file = params[:file]
      
      # 파일 검증
      validation_result = validate_uploaded_file(uploaded_file)
      unless validation_result[:valid]
        return render json: { error: validation_result[:error] }, status: :bad_request
      end

      # 파일 저장
      chat_file = save_uploaded_file(uploaded_file, session, current_user)
      
      # 메시지 생성 (파일 첨부 메시지)
      message = session.kakao_consultation_messages.create!(
        content: "",
        sender_type: 'agent',
        sender_name: current_user.fullname,
        has_attachments: true,
        attachment_count: 1,
        preferences: {
          message_type: 'file',
          attachments: []
        }
      )

      # 파일과 메시지 연결
      chat_file.update!(message: message)

      # 세션 테이블 업데이트 (기존 컬럼 사용)
      session.update!(
        last_message_at: Time.current,
        last_message_content: message.content.present? ? message.content : "[파일]",
        last_message_sender: message.sender_type
      )

      # WebSocket으로 실시간 알림
      broadcast_new_message(session, message, [chat_file])

      render json: {
        success: true,
        file: file_response_data(chat_file),
        message: message_response_data(message, [chat_file])
      }

    rescue => e
      Rails.logger.error "File upload error: #{e.message}"
      render json: { error: 'File upload failed' }, status: :internal_server_error
    end
  end  

  # 파일 업로드 API (토큰 인증)
  def upload_file_api
    return render json: { error: 'API token authentication required' }, status: :unauthorized unless verify_zammad_api_token

    # 디버깅을 위한 파라미터 로그
    Rails.logger.info "Upload file API - All params: #{params.inspect}"
    Rails.logger.info "Upload file API - File param: #{params[:file].inspect}"
    Rails.logger.info "Upload file API - File params keys: #{params.keys.select { |k| params[k].is_a?(ActionDispatch::Http::UploadedFile) }}"

    unless params[:session_id].present?
      return render json: { error: 'session_id is required' }, status: :bad_request
    end

    session = KakaoConsultationSession.find_by(session_id: params[:session_id])
    unless session
      return render json: { error: 'Session not found' }, status: :not_found
    end

    # 파일 파라미터 찾기 (file 파라미터가 없으면 UploadedFile 타입인 다른 파라미터 찾기)
    uploaded_file = params[:file]
    if uploaded_file.blank?
      # file 파라미터가 없으면 UploadedFile 타입인 첫 번째 파라미터 사용
      file_param_key = params.keys.find { |k| params[k].is_a?(ActionDispatch::Http::UploadedFile) }
      uploaded_file = params[file_param_key] if file_param_key
      Rails.logger.info "Upload file API - Using file from parameter: #{file_param_key}" if file_param_key
    end

    unless uploaded_file.present?
      return render json: { error: 'No file provided', debug_info: { available_params: params.keys, file_params: params.keys.select { |k| params[k].is_a?(ActionDispatch::Http::UploadedFile) } } }, status: :bad_request
    end

    begin
      # 파일 검증
      validation_result = validate_uploaded_file(uploaded_file)
      unless validation_result[:valid]
        return render json: { error: validation_result[:error] }, status: :bad_request
      end

      # 발송자 타입 및 사용자 설정
      sender_type = params[:sender_type] || 'system'  # customer, agent, system 중 하나
      
      # 발송자에 따른 사용자 및 이름 설정
      case sender_type
      when 'customer'
        sender_user = nil  # 고객은 시스템 사용자 없음
        sender_name = params[:sender_name] || session.customer_name || '고객'
      when 'agent'
        # 상담원의 경우 현재 로그인한 사용자 또는 지정된 사용자
        sender_user = params[:agent_id].present? ? User.find_by(id: params[:agent_id]) : (current_user || User.find_by(login: 'system'))
        sender_name = params[:sender_name] || sender_user&.fullname || '상담원'
      else  # system
        sender_user = User.find_by(login: 'system') || User.first
        sender_name = params[:sender_name] || 'System'
      end
      
      # 파일 저장
      save_user = sender_user || User.find_by(login: 'system') || User.first
      chat_file = save_uploaded_file(uploaded_file, session, save_user)
      
      # 메시지 생성
      message = session.kakao_consultation_messages.create!(
        content: params[:content] || "",
        sender_type: sender_type,
        sender_name: sender_name,
        sender_id: sender_user&.id,
        has_attachments: true,
        attachment_count: 1,
        preferences: {
          message_type: 'file',
          attachments: []
        }
      )

      # 파일과 메시지 연결
      chat_file.update!(message: message)

      # 세션 테이블 업데이트 (기존 컬럼 사용)
      session.update!(
        last_message_at: Time.current,
        last_message_content: message.content.present? ? message.content : "[파일]",
        last_message_sender: message.sender_type
      )

      # 고객 메시지인 경우 읽지 않은 메시지 수 증가
      if sender_type == 'customer'
        session.increment!(:unread_count)
      end

      # WebSocket으로 실시간 알림
      broadcast_new_message(session, message, [chat_file])

      render json: {
        success: true,
        file: file_response_data(chat_file),
        message: message_response_data(message, [chat_file])
      }

    rescue => e
      Rails.logger.error "File upload API error: #{e.message}"
      render json: { error: 'File upload failed' }, status: :internal_server_error
    end
  end

  # 파일 다운로드
  def download_file
    chat_file = KakaoChatFile.find(params[:file_id])
    
    unless chat_file.exists?
      return render json: { error: 'File not found' }, status: :not_found
    end

    # 권한 확인 (세션에 접근 권한이 있는지)
    unless can_access_file?(chat_file)
      return render json: { error: 'Access denied' }, status: :forbidden
    end

    send_file chat_file.full_storage_path,
              filename: chat_file.original_filename,
              type: chat_file.content_type,
              disposition: 'attachment'
  end

  # 파일 미리보기 (이미지 파일 등을 브라우저에서 직접 보기)
  def preview_file
    chat_file = KakaoChatFile.find(params[:file_id])
    
    unless chat_file.exists?
      return render json: { error: 'File not found' }, status: :not_found
    end

    # 권한 확인
    unless can_access_file?(chat_file)
      return render json: { error: 'Access denied' }, status: :forbidden
    end

    # 이미지 파일인 경우 inline으로 표시, 그 외는 다운로드
    disposition = chat_file.image? ? 'inline' : 'attachment'
    
    send_file chat_file.full_storage_path,
              filename: chat_file.original_filename,
              type: chat_file.content_type,
              disposition: disposition
  end

  # 파일 썸네일
  def file_thumbnail
    chat_file = KakaoChatFile.find(params[:file_id])
    
    unless chat_file.image?
      return render json: { error: 'Thumbnail not available' }, status: :bad_request
    end

    # 권한 확인
    unless can_access_file?(chat_file)
      return render json: { error: 'Access denied' }, status: :forbidden
    end

    thumbnail_data = chat_file.generate_thumbnail
    
    if thumbnail_data
      send_data thumbnail_data,
                type: 'image/jpeg',
                disposition: 'inline'
    else
      render json: { error: 'Thumbnail generation failed' }, status: :internal_server_error
    end
  end  

  private

  def verify_api_authentication
    token = request.headers['Authorization']&.split(' ')&.last || params[:token]
    
    Rails.logger.info "API Authentication - Received token: #{token}"
    Rails.logger.info "API Authentication - Token from headers: #{request.headers['Authorization']}"
    Rails.logger.info "API Authentication - Token from params: #{params[:token]}"
    
    unless token
      Rails.logger.warn "API Authentication - No token provided"
      render json: { error: '인증 토큰이 필요합니다.' }, status: :unauthorized
      return false
    end
    
    # 임시 토큰 또는 Setting에서 가져오기
    valid_token = Setting.get('kakao_chat_api_token') || 'kakao_chat_api_token_123'
    Rails.logger.info "API Authentication - Valid token: #{valid_token}"
    Rails.logger.info "API Authentication - Token comparison: '#{token}' == '#{valid_token}' => #{token == valid_token}"
    
    unless token == valid_token
      Rails.logger.warn "API Authentication - Token mismatch: received='#{token}', expected='#{valid_token}'"
      render json: { error: '유효하지 않은 인증 토큰입니다.' }, status: :unauthorized
      return false
    end
    
    Rails.logger.info "API Authentication - Success"
    true
  end

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
    session = KakaoConsultationSession.find_by(session_id: params[:id])

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
  def notify_agents(session, message, current_view = nil)
    # 고객 메시지인 경우 읽음 처리는 프론트엔드에서만 명시적으로 수행
    # 백엔드에서 자동 읽음 처리 비활성화 - 혼란을 방지하기 위해
    if message.sender_type == 'customer'
      Rails.logger.info "Customer message received for session #{session.session_id} - read processing will be handled by frontend"
    end

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
    
    # 상담원 권한이 있으면 모든 세션에 접근 가능 (팀 공유 모델)
    return true if current_user.permissions?(['chat.agent'])
    
    # 배정된 상담원만 접근 가능 (제한적 모델)
    # session.agent_id == current_user.id
    
    false
  end

  # 다중 상담원을 위한 읽음 처리 로직
  def mark_messages_as_read_by_user(session, user)
    # 1. 담당 상담원이 있고 현재 사용자가 담당자인 경우 -> 전체 읽음 처리
    if session.agent_id.present? && session.agent_id == user.id
      unread_messages = session.kakao_consultation_messages
                              .where(sender_type: 'customer', read_by_agent: false)
      if unread_messages.any?
        unread_messages.update_all(read_by_agent: true, read_at: Time.current)
        session.update!(unread_count: 0)
        Rails.logger.info "Agent #{user.login} read all messages for assigned session #{session.session_id}"
        
        # 다른 상담원들에게 읽음 상태 업데이트 알림
        broadcast_read_status_update(session, user)
      end
      
    # 2. 담당 상담원이 없는 경우 -> 첫 번째 읽는 상담원이 담당자가 되고 전체 읽음 처리
    elsif session.agent_id.blank?
      unread_messages = session.kakao_consultation_messages
                              .where(sender_type: 'customer', read_by_agent: false)
      if unread_messages.any?
        # 담당자 할당
        session.update!(agent_id: user.id)
        
        # 읽음 처리
        unread_messages.update_all(read_by_agent: true, read_at: Time.current)
        session.update!(unread_count: 0)
        
        Rails.logger.info "Agent #{user.login} claimed session #{session.session_id} and read all messages"
        
        # 상담원 할당 및 읽음 상태 업데이트 알림
        broadcast_agent_assignment(session, user)
        broadcast_read_status_update(session, user)
      end
      
    # 3. 다른 상담원이 담당 중인 경우 -> 개별 읽음 기록만 (전체 카운트에는 영향 없음)
    else
      # 개별 읽음 기록을 위한 로직 (선택사항)
      # 이 경우 세션의 unread_count는 변경하지 않음
      Rails.logger.info "Agent #{user.login} viewed session #{session.session_id} (assigned to agent_id: #{session.agent_id})"
    end
  end

  # 읽음 상태 변경 알림
  def broadcast_read_status_update(session, user)
    notification_data = {
      event: 'kakao_messages_read',
      data: {
        session_id: session.session_id,
        read_by_agent: user.login,
        unread_count: session.unread_count
      }
    }
    Sessions.broadcast(notification_data)
  end

  # 상담원 할당 알림
  def broadcast_agent_assignment(session, user)
    notification_data = {
      event: 'kakao_agent_assigned',
      data: {
        session_id: session.session_id,
        agent_name: user.fullname,
        agent_id: user.id
      }
    }
    Sessions.broadcast(notification_data)
  end

  # 메시지 읽음 처리 알림
  def broadcast_messages_read(session, user, unread_count)
    notification_data = {
      event: 'kakao_messages_read',
      data: {
        session_id: session.session_id,
        read_by_agent: user.fullname,
        read_by_agent_id: user.id,
        unread_count: unread_count
      }
    }
    Sessions.broadcast(notification_data)
    Rails.logger.info "Broadcasted kakao_messages_read event for session #{session.session_id}"
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
    KakaoConsultationSession.where(status: ['waiting', 'active']).sum(:unread_count)
  end

  def validate_uploaded_file(uploaded_file)
    # 파일 크기 검증
    if uploaded_file.size > KakaoChatFile::MAX_FILE_SIZE
      return { valid: false, error: "File size too large. Maximum: #{ActionController::Base.helpers.number_to_human_size(KakaoChatFile::MAX_FILE_SIZE)}" }
    end

    # 파일 확장자 검증
    extension = File.extname(uploaded_file.original_filename).downcase.delete('.')
    unless KakaoChatFile::ALLOWED_EXTENSIONS.include?(extension)
      return { valid: false, error: "File type not allowed. Allowed: #{KakaoChatFile::ALLOWED_EXTENSIONS.join(', ')}" }
    end

    # MIME 타입 검증
    detected_type = Marcel::MimeType.for(uploaded_file.tempfile)
    allowed_types = KakaoChatFile::CONTENT_TYPE_CATEGORIES.values.flatten
    
    unless allowed_types.include?(detected_type)
      return { valid: false, error: "Invalid file type detected: #{detected_type}" }
    end

    { valid: true }
  end

  def save_uploaded_file(uploaded_file, session, user)
    # 파일 해시 생성
    file_hash = Digest::SHA256.hexdigest(uploaded_file.read)
    uploaded_file.rewind

    # 저장 경로 생성
    timestamp = Time.current.strftime('%Y%m%d')
    filename = sanitize_filename(uploaded_file.original_filename)
    storage_path = File.join(timestamp, session.session_id, "#{SecureRandom.hex(8)}_#{filename}")
    
    # 실제 파일 저장
    full_path = Rails.root.join('storage', 'kakao_chat', storage_path)
    FileUtils.mkdir_p(File.dirname(full_path))
    
    File.open(full_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    # 메타데이터 추출
    metadata = extract_file_metadata(full_path, uploaded_file.content_type)

    # 데이터베이스에 저장
    KakaoChatFile.create!(
      filename: filename,
      original_filename: uploaded_file.original_filename,
      content_type: uploaded_file.content_type,
      file_size: uploaded_file.size,
      storage_path: storage_path,
      file_hash: file_hash,
      session: session,
      uploaded_by: user,
      metadata: metadata
    )
  end

  def extract_file_metadata(file_path, content_type)
    metadata = {}
    
    begin
      if content_type.start_with?('image/')
        # MiniMagick이 설치되어 있는 경우에만 이미지 메타데이터 추출
        begin
          require 'mini_magick'
          image = MiniMagick::Image.open(file_path)
          metadata[:width] = image.width
          metadata[:height] = image.height
          metadata[:format] = image.type
        rescue LoadError
          Rails.logger.warn "MiniMagick not available - skipping image metadata extraction"
        rescue => e
          Rails.logger.warn "Failed to extract image metadata: #{e.message}"
        end
      elsif content_type.start_with?('video/')
        # 동영상 메타데이터는 ffmpeg가 필요 (선택사항)
        # require 'streamio-ffmpeg'
        # movie = FFMPEG::Movie.new(file_path)
        # metadata[:duration] = movie.duration
        # metadata[:bitrate] = movie.bitrate
        # metadata[:resolution] = "#{movie.width}x#{movie.height}"
      end
    rescue => e
      Rails.logger.warn "Failed to extract metadata for file: #{e.message}"
    end
    
    metadata
  end

  def sanitize_filename(filename)
    # 파일명에서 위험한 문자 제거
    filename.gsub(/[^0-9A-Za-z.\-_\u{AC00}-\u{D7A3}]/, '_')
  end

  def can_access_session?(session)
    # 토큰 인증인 경우 허용
    return true if @_token_auth

    # 로그인한 상담원인 경우 허용
    return false unless current_user
    return false unless current_user.permissions?(['chat.agent'])
    
    true
  end

  def can_access_file?(chat_file)
    # 토큰 인증인 경우 허용
    return true if @_token_auth

    # 로그인한 상담원인 경우 세션 접근 권한 확인
    return false unless current_user
    return false unless current_user.permissions?(['chat.agent'])
    
    # 파일의 세션에 접근 권한이 있는지 확인
    can_access_session?(chat_file.session)
  end

  def file_response_data(chat_file)
    {
      id: chat_file.id,
      filename: chat_file.filename,
      original_filename: chat_file.original_filename,
      content_type: chat_file.content_type,
      file_size: chat_file.file_size,
      file_size_human: chat_file.file_size_human,
      file_category: chat_file.file_category,
      is_image: chat_file.image?,
      download_url: chat_file.download_url,
      preview_url: chat_file.preview_url,
      thumbnail_url: chat_file.thumbnail_url,
      metadata: chat_file.metadata,
      created_at: chat_file.created_at
    }
  end

  def message_response_data(message, files = [])
    {
      id: message.id,
      content: message.content,
      sender_type: message.sender_type,
      sender_name: message.sender_name,
      message_type: message.message_type,
      has_attachments: message.has_attachments,
      attachment_count: message.attachment_count,
      files: files.map { |file| file_response_data(file) },
      sent_at: message.created_at
    }
  end

  def broadcast_new_message(session, message, files = [])
    # 메시지 브로드캐스트 데이터
    message_data = message_response_data(message, files)
    
    # WebSocket 이벤트 발송
    notification_data = {
      event: 'kakao_message_received',
      data: {
        session_id: session.session_id,
        message: message_data,
        session: {
          id: session.id,
          session_id: session.session_id,
          status: session.status,
          unread_count: session.unread_count
        }
      }
    }

    Sessions.broadcast(notification_data)
    Rails.logger.info "Broadcasted file message for session #{session.session_id}"
  end
end