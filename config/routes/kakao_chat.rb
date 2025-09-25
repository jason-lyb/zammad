# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # 카카오톡 상담 채팅 관련 라우트
  scope api_path do
    get    '/kakao_chat/sessions',                    to: 'kakao_chat#sessions'
    get    '/kakao_chat/sessions/:id',                to: 'kakao_chat#show'
    get    '/kakao_chat/sessions/:id/messages',       to: 'kakao_chat#messages'
    post   '/kakao_chat/sessions/:id/messages',       to: 'kakao_chat#send_message'
    post   '/kakao_chat/sessions/:id/assign',         to: 'kakao_chat#assign_agent'
    post   '/kakao_chat/sessions/:id/end',           to: 'kakao_chat#end_session'
    post   '/kakao_chat/sessions/:id/read',          to: 'kakao_chat#mark_messages_as_read'
    post   '/kakao_chat/sessions/:id/link_customer', to: 'kakao_chat#link_customer'
    delete '/kakao_chat/sessions/:id/link_customer', to: 'kakao_chat#unlink_customer'
    get    '/kakao_chat/unread_count',               to: 'kakao_chat#unread_count'
    get    '/kakao_chat/agents',                     to: 'kakao_chat#available_agents'
    get    '/kakao_chat/download_image',             to: 'kakao_chat#download_image'
    
    # 카카오톡에서 메시지 수신 (Webhook)
    post   '/kakao_chat/message',                     to: 'kakao_chat#receive_message'
    
    # 범용 메시지 전송 API (토큰 인증)
    post   '/kakao_chat/send_message',                to: 'kakao_chat#send_message_api'
    
    # 파일 업로드 및 전송 API
    post   '/kakao_chat/sessions/:id/upload',         to: 'kakao_chat#upload_file', constraints: { id: /[^\/]+/ }
    post   '/kakao_chat/upload_file',                 to: 'kakao_chat#upload_file_api'  # 토큰 인증용
    get    '/kakao_chat/files/:file_id',              to: 'kakao_chat#download_file'
    get    '/kakao_chat/files/:file_id/preview',      to: 'kakao_chat#preview_file'
    get    '/kakao_chat/files/:file_id/thumbnail',    to: 'kakao_chat#file_thumbnail'
    
    # 범용 상담 종료 API (토큰 인증)
    post   '/kakao_chat/end_session',                 to: 'kakao_chat#end_session_api'
    
    # 상담원용 외부 API 호출 (consultalk API)
    post   '/kakao_chat/agent/send_message',          to: 'kakao_chat#agent_send_message'
    post   '/kakao_chat/agent/upload_file',           to: 'kakao_chat#agent_upload_file'
  end
end
