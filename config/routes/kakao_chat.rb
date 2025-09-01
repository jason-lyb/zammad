# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # 카카오톡 상담 채팅 관련 라우트
  scope api_path do
    get    '/kakao_chat/sessions',                    to: 'kakao_chat#sessions'
    get    '/kakao_chat/sessions/:id',                to: 'kakao_chat#show'
    get    '/kakao_chat/sessions/:id/messages',       to: 'kakao_chat#messages'
    post   '/kakao_chat/sessions/:id/messages',       to: 'kakao_chat#send_message'
    post   '/kakao_chat/sessions/:id/end',           to: 'kakao_chat#end_session'
    
    # 카카오톡에서 메시지 수신 (Webhook)
    post   '/kakao_chat/message',                     to: 'kakao_chat#receive_message'
  end
end
