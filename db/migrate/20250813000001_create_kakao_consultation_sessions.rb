class CreateKakaoConsultationSessions < ActiveRecord::Migration[6.1]
  def up
    create_table :kakao_consultation_sessions do |t|
      t.string :session_id, null: false, unique: true, comment: '상담톡 API에서 제공하는 세션 ID( user_key + event_key )'
      t.string :user_key, null: false, comment: '카카오톡 사용자 키 (user_key)'
      t.string :service_key, comment: '카카오톡 서비스 키'
      t.string :event_key, comment: '카카오톡 이벤트 키'
      t.string :customer_name, comment: '고객 이름'
      t.string :customer_avatar, comment: '고객 아바타 URL'
      t.string :customer_phone, comment: '고객 전화번호'
      t.text :customer_info, comment: '고객 추가 정보 (JSON)'
      t.integer :linked_customer_id, comment: '연동된 Zammad 고객 ID'
      
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
      t.index :service_key
      t.index :event_key
      t.index :linked_customer_id
      t.index :agent_id
      t.index :status
      t.index :started_at
      t.index :last_message_at
    end

    unless table_exists?(:kakao_consultation_messages)
      create_table :kakao_consultation_messages do |t|
        t.references :kakao_consultation_session, null: false, foreign_key: true, index: { name: 'idx_kakao_messages_session_id' }
        t.string :message_id, comment: '상담톡 API 메시지 ID'
        t.string :serialNumber, comment: '카카오톡 메시지 시리얼 번호'
        t.string :sender_type, null: false, comment: 'customer, agent, system, chatbot'
        t.integer :sender_id, comment: '발신자 ID (agent, chatbot인 경우 User ID)'
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
        t.index :serialNumber
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

    # 개별 상담원별 읽음 상태 추적 테이블
    unless table_exists?(:kakao_message_reads)
      create_table :kakao_message_reads do |t|
        t.references :kakao_consultation_message, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.datetime :read_at, null: false
        t.timestamps
      end

      # 복합 인덱스로 중복 방지 및 성능 향상
      add_index :kakao_message_reads, [:kakao_consultation_message_id, :user_id], 
                unique: true, name: 'index_message_reads_unique'
      
      # 빠른 조회를 위한 인덱스
      add_index :kakao_message_reads, [:user_id, :read_at]
    end

    # 카카오 채팅 파일 테이블
    unless table_exists?(:kakao_chat_files)
      create_table :kakao_chat_files do |t|
        t.string :filename, null: false, limit: 255
        t.string :original_filename, limit: 255
        t.string :content_type, null: false, limit: 100
        t.bigint :file_size, null: false
        t.string :storage_path, null: false, limit: 500
        t.string :file_hash, limit: 64  # SHA256 해시
        
        # 연관관계
        t.references :session, null: false, foreign_key: { to_table: :kakao_consultation_sessions }
        t.references :message, null: true, foreign_key: { to_table: :kakao_consultation_messages }
        t.references :uploaded_by, null: true, foreign_key: { to_table: :users }
        
        # 메타데이터
        t.json :metadata, default: {}  # 이미지 크기, 동영상 길이 등
        
        # 상태
        t.string :status, default: 'uploaded', limit: 20  # uploaded, processing, ready, error
        
        t.timestamps null: false
        
        t.index [:session_id, :created_at]
        t.index [:content_type]
        t.index [:file_hash]
        t.index [:status]
      end
    end

    # 메시지 테이블에 추가 컬럼들
    if table_exists?(:kakao_consultation_messages)
      # serialNumber 컬럼 추가
      add_column :kakao_consultation_messages, :serialNumber, :string unless column_exists?(:kakao_consultation_messages, :serialNumber)
      add_index :kakao_consultation_messages, [:serialNumber] unless index_exists?(:kakao_consultation_messages, [:serialNumber])
      
      # 기존 read_by_agent 컬럼은 팀 전체 읽음 상태로 활용
      # (누구든 한 명이라도 읽으면 true)
      add_column :kakao_consultation_messages, :team_read_at, :datetime unless column_exists?(:kakao_consultation_messages, :team_read_at)
      add_column :kakao_consultation_messages, :team_read_by, :integer unless column_exists?(:kakao_consultation_messages, :team_read_by)
      add_foreign_key :kakao_consultation_messages, :users, column: :team_read_by unless foreign_key_exists?(:kakao_consultation_messages, :users, column: :team_read_by)
      
      # 파일 관련 컬럼 추가
      add_column :kakao_consultation_messages, :has_attachments, :boolean, default: false unless column_exists?(:kakao_consultation_messages, :has_attachments)
      add_column :kakao_consultation_messages, :attachment_count, :integer, default: 0 unless column_exists?(:kakao_consultation_messages, :attachment_count)
      
      add_index :kakao_consultation_messages, [:has_attachments] unless index_exists?(:kakao_consultation_messages, [:has_attachments])
    end

    # 설정 추가
    setup_kakao_settings

    # 권한 추가  
    setup_kakao_permissions
  end

  def down
    drop_table :kakao_chat_files if table_exists?(:kakao_chat_files)
    drop_table :kakao_message_reads if table_exists?(:kakao_message_reads)
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
