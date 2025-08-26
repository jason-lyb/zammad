# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class SetupKakaoChat < ActiveRecord::Migration[7.2]
  def change
    # return if it's a new setup
    return if !Setting.exists?(name: 'system_init_done')

    # 카카오톡 상담 테이블 생성
    create_table :kakao_consultations do |t|
      t.string :consultation_id, null: false
      t.string :kakao_user_id, null: false
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :assigned_agent, null: true, foreign_key: { to_table: :users }
      t.references :ticket, null: true, foreign_key: true
      
      t.string :status, null: false, default: 'active'
      t.datetime :started_at, null: false
      t.datetime :ended_at, null: true
      t.datetime :last_agent_away_at, null: true
      t.string :end_reason, null: true
      
      t.text :notes
      t.text :preferences

      t.timestamps null: false
    end

    # 카카오톡 상담 메시지 테이블 생성
    create_table :kakao_consultation_messages do |t|
      t.references :kakao_consultation, null: false, foreign_key: true
      t.references :sender_user, null: true, foreign_key: { to_table: :users }
      
      t.text :content, null: false
      t.string :sender_type, null: false
      t.datetime :sent_at, null: false
      
      t.boolean :read_by_agent, default: false
      t.datetime :read_at, null: true
      
      t.text :preferences

      t.timestamps null: false
    end

    # 인덱스 추가
    add_index :kakao_consultations, :consultation_id, unique: true
    add_index :kakao_consultations, [:kakao_user_id, :status]
    add_index :kakao_consultations, :status
    add_index :kakao_consultations, :started_at

    add_index :kakao_consultation_messages, [:kakao_consultation_id, :sent_at], 
              name: 'idx_kakao_messages_consultation_sent'
    add_index :kakao_consultation_messages, [:sender_type, :read_by_agent]

    # 설정 추가
    setup_kakao_settings

    # 권한 추가  
    setup_kakao_permissions
  end

  private

  def setup_kakao_settings
    Setting.create_if_not_exists(
      title: '카카오톡 상담 연동',
      name: 'kakao_integration',
      area: 'Integration::Kakao',
      description: '카카오톡 상담 채팅 연동을 활성화합니다.',
      options: {
        form: [
          {
            display: '카카오톡 연동 사용',
            null: true,
            name: 'kakao_integration',
            tag: 'boolean',
            options: { true => 'yes', false => 'no' },
          },
        ],
      },
      preferences: { permission: ['admin.channel_kakao'] },
      state: false,
      frontend: false
    )

    Setting.create_if_not_exists(
      title: '내부 API 서버 URL',
      name: 'kakao_internal_api_endpoint',
      area: 'Integration::Kakao',
      description: '카카오톡 메시지 전송을 위한 내부 API 서버 엔드포인트',
      options: {
        form: [
          {
            display: 'API 엔드포인트 URL',
            null: false,
            name: 'kakao_internal_api_endpoint',
            tag: 'input',
            placeholder: 'https://internal-api.company.com',
          },
        ],
      },
      preferences: { permission: ['admin.channel_kakao'] },
      state: 'http://localhost:3001',
      frontend: false
    )

    Setting.create_if_not_exists(
      title: '내부 API 인증 토큰',
      name: 'kakao_internal_api_token',
      area: 'Integration::Kakao',
      description: '내부 API 서버 인증을 위한 보안 토큰',
      options: {
        form: [
          {
            display: 'API 토큰',
            null: false,
            name: 'kakao_internal_api_token',
            tag: 'input',
            type: 'password',
          },
        ],
      },
      preferences: { permission: ['admin.channel_kakao'] },
      state: 'test_token_123',
      frontend: false
    )

    Setting.create_if_not_exists(
      title: '카카오톡 Webhook 토큰',
      name: 'kakao_webhook_token',
      area: 'Integration::Kakao',
      description: '내부 API 서버에서 Zammad로 요청 시 인증 토큰',
      options: {
        form: [
          {
            display: 'Webhook 토큰',
            null: false,
            name: 'kakao_webhook_token',
            tag: 'input',
            type: 'password',
          },
        ],
      },
      preferences: { permission: ['admin.channel_kakao'] },
      state: SecureRandom.hex(32),
      frontend: false
    )
  end

  def setup_kakao_permissions
    Permission.create_if_not_exists(
      name: 'admin.channel_kakao',
      label: 'KakaoTalk 채널 관리',
      description: 'Manage KakaoTalk channels and settings',
      preferences: {},
      active: true,
      allow_signup: false
    )

    Permission.create_if_not_exists(
      name: 'ticket.agent_kakao',
      label: 'KakaoTalk 상담 처리',
      description: 'Handle KakaoTalk consultations and messages',
      preferences: {},
      active: true,
      allow_signup: false
    )
  end
end