# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class KakaoChatController < ApplicationController
  prepend_before_action :authenticate_and_authorize!
  before_action :check_kakao_integration_enabled

  # GET /api/v1/kakao_chat/sessions
  # 활성 상담 세션 목록 조회
  def sessions
    begin
      # 내부 데이터베이스에서 활성 세션 목록 조회
      sessions = KakaoConsultationSession.active
                                        .includes(:agent, :kakao_consultation_messages)
                                        .recent
                                        .limit(50)

      # JSON 형태로 변환
      sessions_data = sessions.map do |session|
        {
          id: session.id,
          session_id: session.session_id,
          customer_id: session.customer_id,
          customer_name: session.customer_name,
          customer_avatar: session.customer_avatar,
          agent_id: session.agent_id,
          agent_name: session.agent&.fullname,
          status: session.status,
          last_message: session.last_message_content,
          last_message_at: session.last_message_at,
          unread_count: session.unread_count,
          created_at: session.created_at,
          updated_at: session.updated_at
        }
      end
      
      render json: { 
        sessions: sessions_data,
        total: sessions.count
      }

    rescue => e
      Rails.logger.error "카카오톡 상담 세션 목록 조회 실패: #{e.message}"
      render json: { error: '상담 목록을 불러올 수 없습니다.' }, status: :internal_server_error
    end
  end

  # GET /api/v1/kakao_chat/sessions/:id/messages
  # 특정 상담 세션의 메시지 목록 조회
  def messages
    begin
      session = KakaoConsultationSession.find(params[:id])
      
      # 메시지 목록 조회 (최근 100개)
      messages = session.kakao_consultation_messages
                       .recent
                       .limit(100)

      # 읽음 처리
      session.mark_messages_as_read!

      # JSON 형태로 변환
      messages_data = messages.map do |message|
        {
          id: message.id,
          message_id: message.message_id,
          content: message.content,
          sender_type: message.sender_type,
          sender_id: message.sender_id,
          sender_name: message.sender_display_name,
          message_type: message.message_type,
          attachments: message.attachments_data,
          sent_at: message.sent_at,
          created_at: message.created_at
        }
      end
      
      render json: { 
        messages: messages_data,
        session_id: session.id,
        total: messages.count
      }

    rescue ActiveRecord::RecordNotFound
      render json: { error: '상담 세션을 찾을 수 없습니다.' }, status: :not_found
    rescue => e
      Rails.logger.error "카카오톡 상담 메시지 조회 실패: #{e.message}"
      render json: { error: '메시지를 불러올 수 없습니다.' }, status: :internal_server_error
    end
  end

  # POST /api/v1/kakao_chat/sessions/:id/messages
  # 메시지 전송
  def send_message
    begin
      session = KakaoConsultationSession.find(params[:id])
      message_content = params[:message]
      
      if message_content.blank?
        render json: { error: '메시지 내용이 필요합니다.' }, status: :bad_request
        return
      end

      # 세션이 활성 상태가 아니면 활성화
      if session.status == 'waiting'
        session.start_consultation!(current_user)
      end

      # 내부 데이터베이스에 메시지 저장
      message = session.add_message(
        content: message_content,
        sender_type: 'agent',
        sender_id: current_user.id,
        sender_name: current_user.fullname
      )

      # 상담톡 API 서버로 메시지 전송
      api_result = send_message_to_api_server(session, message_content, current_user)
      
      if api_result[:success]
        # API 메시지 ID 업데이트
        message.update(message_id: api_result[:message_id]) if api_result[:message_id]
        
        render json: { 
          success: true,
          message: '메시지가 전송되었습니다.',
          message_id: message.id
        }
      else
        # API 전송 실패 시 메시지 삭제 또는 실패 상태로 마킹
        message.destroy
        render json: { error: api_result[:error] || '메시지 전송에 실패했습니다.' }, status: :bad_request
      end

    rescue ActiveRecord::RecordNotFound
      render json: { error: '상담 세션을 찾을 수 없습니다.' }, status: :not_found
    rescue => e
      Rails.logger.error "카카오톡 메시지 전송 실패: #{e.message}"
      render json: { error: '메시지 전송에 실패했습니다.' }, status: :internal_server_error
    end
  end

  # POST /api/v1/kakao_chat/sessions/:id/end
  # 상담 세션 종료
  def end_session
    begin
      session = KakaoConsultationSession.find(params[:id])
      
      # 이미 종료된 세션인지 확인
      if session.status == 'ended'
        render json: { error: '이미 종료된 상담입니다.' }, status: :bad_request
        return
      end

      # 상담톡 API 서버에 종료 요청
      api_result = end_session_on_api_server(session)
      
      if api_result[:success]
        # 내부 세션 상태 업데이트
        session.end_consultation!(current_user)
        
        # 자동 티켓 생성 설정이 활성화되어 있으면 티켓 생성
        if Setting.get('kakao_auto_create_ticket')
          create_ticket_from_session(session)
        end
        
        render json: { 
          success: true,
          message: '상담이 종료되었습니다.',
          session_id: session.id,
          ended_at: session.ended_at
        }
      else
        render json: { error: api_result[:error] || '상담 종료에 실패했습니다.' }, status: :bad_request
      end

    rescue ActiveRecord::RecordNotFound
      render json: { error: '상담 세션을 찾을 수 없습니다.' }, status: :not_found
    rescue => e
      Rails.logger.error "카카오톡 상담 세션 종료 실패: #{e.message}"
      render json: { error: '상담 종료에 실패했습니다.' }, status: :internal_server_error
    end
  end

  private

  def check_kakao_integration_enabled
    unless Setting.get('kakao_integration')
      render json: { error: '카카오톡 상담톡 연동이 비활성화되어 있습니다.' }, status: :forbidden
    end
  end

  # 상담톡 API 서버로 메시지 전송
  def send_message_to_api_server(session, message_content, user)
    api_endpoint = Setting.get('kakao_api_endpoint')
    api_token = Setting.get('kakao_api_token')
    
    uri = URI.join(api_endpoint, "/api/v1/sessions/#{session.session_id}/messages")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_token}"
    request['Content-Type'] = 'application/json'
    request.body = {
      content: message_content,
      sender_type: 'agent',
      sender_id: user.id,
      sender_name: user.fullname
    }.to_json
    
    response = http.request(request)
    
    if response.code == '200' || response.code == '201'
      result = JSON.parse(response.body)
      { success: true, message_id: result['message_id'] }
    else
      Rails.logger.error "상담톡 API 메시지 전송 실패: #{response.code} - #{response.body}"
      { success: false, error: "메시지 전송 실패 (#{response.code})" }
    end
  rescue => e
    Rails.logger.error "상담톡 API 연결 실패: #{e.message}"
    { success: false, error: "API 연결 실패: #{e.message}" }
  end

  # 상담톡 API 서버에 세션 종료 요청
  def end_session_on_api_server(session)
    api_endpoint = Setting.get('kakao_api_endpoint')
    api_token = Setting.get('kakao_api_token')
    
    uri = URI.join(api_endpoint, "/api/v1/sessions/#{session.session_id}/end")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_token}"
    request['Content-Type'] = 'application/json'
    request.body = {
      ended_by: session.agent_id,
      ended_by_name: session.agent.fullname
    }.to_json
    
    response = http.request(request)
    
    if response.code == '200'
      { success: true }
    else
      Rails.logger.error "상담톡 API 세션 종료 실패: #{response.code} - #{response.body}"
      { success: false, error: "세션 종료 실패 (#{response.code})" }
    end
  rescue => e
    Rails.logger.error "상담톡 API 연결 실패: #{e.message}"
    { success: false, error: "API 연결 실패: #{e.message}" }
  end

  # 세션에서 티켓 생성
  def create_ticket_from_session(session)
    return unless session.is_a?(KakaoConsultationSession)
    
    # 메시지들을 하나의 텍스트로 합치기
    message_content = session.messages.order(:created_at).map do |msg|
      "[#{msg.created_at.strftime('%H:%M:%S')}] #{msg.sender_name}: #{msg.content}"
    end.join("\n")

    # 티켓 생성
    ticket = Ticket.create!(
      title: "카카오톡 상담 - #{session.customer_name || session.customer_id}",
      customer_id: session.customer_id,
      group_id: Group.find_by(name: 'Users')&.id || Group.first.id,
      priority_id: Ticket::Priority.find_by(name: '2 normal')&.id || Ticket::Priority.first.id,
      state_id: Ticket::State.find_by(name: 'closed')&.id || Ticket::State.first.id,
      owner_id: session.agent_id
    )

    # 첫 번째 아티클로 대화 내용 추가
    Ticket::Article.create!(
      ticket_id: ticket.id,
      type_id: Ticket::Article::Type.find_by(name: 'note')&.id || Ticket::Article::Type.first.id,
      sender_id: Ticket::Article::Sender.find_by(name: 'Agent')&.id || Ticket::Article::Sender.first.id,
      from: session.agent.fullname,
      to: session.customer_name || session.customer_id,
      subject: "카카오톡 상담 내용",
      body: message_content,
      internal: false,
      created_by_id: session.agent_id
    )

    Rails.logger.info "카카오톡 상담 세션 #{session.id}에서 티켓 #{ticket.id} 생성됨"
    ticket
  rescue => e
    Rails.logger.error "티켓 생성 실패: #{e.message}"
    nil
  end

end
