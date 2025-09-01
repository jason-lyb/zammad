class CreateKakaoConsultationSessions < ActiveRecord::Migration[6.1]
  def up
    create_table :kakao_consultation_sessions do |t|
      t.string :session_id, null: false, unique: true, comment: '상담톡 API에서 제공하는 세션 ID'
      t.string :user_key, null: false, comment: '카카오톡 사용자 키 (user_key)'
      t.string :customer_name, comment: '고객 이름'
      t.string :customer_avatar, comment: '고객 아바타 URL'
      t.string :customer_phone, comment: '고객 전화번호'
      t.text :customer_info, comment: '고객 추가 정보 (JSON)'
      
      t.integer :agent_id, comment: '담당 상담원 ID'
      t.string :status, default: 'waiting', comment: '상담 상태: waiting, active, ended, transferred'
      
      t.datetime :started_at, comment: '상담 시작 시간'
      t.datetime :ended_at, comment: '상담 종료 시간'
      t.datetime :last_message_at, comment: '마지막 메시지 시간'
      
      t.text :last_message_content, comment: '마지막 메시지 내용'
      t.string :last_message_sender, comment: '마지막 메시지 발신자'
      t.integer :unread_count, default: 0, comment: '읽지 않은 메시지 수'
      
      t.text :tags, comment: '태그 (JSON 배열)'
      t.text :notes, comment: '상담 메모'
      t.integer :priority, default: 1, comment: '우선순위 (1: 낮음, 2: 보통, 3: 높음)'
      
      t.timestamps
      
      t.index :session_id, unique: true
      t.index :user_key
      t.index :agent_id
      t.index :status
      t.index :started_at
      t.index :last_message_at
    end

    unless table_exists?(:kakao_consultation_messages)
      create_table :kakao_consultation_messages do |t|
        t.references :kakao_consultation_session, null: false, foreign_key: true, index: { name: 'idx_kakao_messages_session_id' }
        t.string :message_id, comment: '상담톡 API 메시지 ID'
        t.string :sender_type, null: false, comment: 'customer, agent, system'
        t.integer :sender_id, comment: '발신자 ID (agent인 경우 User ID)'
        t.string :sender_name, comment: '발신자 이름'
        t.text :content, null: false, comment: '메시지 내용'
        t.string :message_type, default: 'text', comment: 'text, image, file, system'
        t.text :kakao_attachments, comment: '카카오톡 첨부파일 정보 (JSON)'
        t.datetime :sent_at, comment: '발송 시간'
        t.boolean :is_read, default: false, comment: '읽음 여부'
        t.boolean :read_by_agent, default: false, comment: '상담원이 읽었는지 여부'
        t.datetime :read_at, comment: '읽은 시간'
        t.text :preferences, comment: '추가 설정 정보 (JSON)'
        
        t.timestamps
        
        t.index :message_id
        t.index :sender_type
        t.index :sender_id
        t.index :sent_at
        t.index :is_read
        t.index :read_by_agent
      end
    end

    # 세션 통계 테이블
    unless table_exists?(:kakao_consultation_stats)
      create_table :kakao_consultation_stats do |t|
        t.references :kakao_consultation_session, null: false, foreign_key: true, index: { name: 'idx_kakao_stats_session_id' }
        t.integer :total_messages, default: 0
        t.integer :customer_messages, default: 0
        t.integer :agent_messages, default: 0
        t.integer :response_time_avg, comment: '평균 응답 시간 (초)'
        t.integer :session_duration, comment: '상담 시간 (초)'
        t.float :satisfaction_score, comment: '만족도 점수'
        
        t.timestamps
      end
    end

    # 설정 추가
    setup_kakao_settings

    # 권한 추가  
    setup_kakao_permissions
  end

  def down
    drop_table :kakao_consultation_stats if table_exists?(:kakao_consultation_stats)
    drop_table :kakao_consultation_messages if table_exists?(:kakao_consultation_messages)
    drop_table :kakao_consultation_sessions if table_exists?(:kakao_consultation_sessions)
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
