class CreateKakaoConsultationSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :kakao_consultation_sessions do |t|
      t.string :session_id, null: false, unique: true, comment: '상담톡 API에서 제공하는 세션 ID'
      t.string :customer_id, null: false, comment: '고객 식별 ID (카카오톡 사용자 ID 등)'
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
      t.index :customer_id
      t.index :agent_id
      t.index :status
      t.index :started_at
      t.index :last_message_at
    end

    unless table_exists?(:kakao_consultation_messages)
      create_table :kakao_consultation_messages do |t|
        t.references :kakao_consultation_session, null: false, foreign_key: true
        t.string :message_id, comment: '상담톡 API 메시지 ID'
        t.string :sender_type, null: false, comment: 'customer, agent, system'
        t.integer :sender_id, comment: '발신자 ID (agent인 경우 User ID)'
        t.string :sender_name, comment: '발신자 이름'
        t.text :content, null: false, comment: '메시지 내용'
        t.string :message_type, default: 'text', comment: 'text, image, file, system'
        t.text :attachments, comment: '첨부파일 정보 (JSON)'
        t.datetime :sent_at, comment: '발송 시간'
        t.boolean :is_read, default: false, comment: '읽음 여부'
        
        t.timestamps
        
        t.index :message_id
        t.index :sender_type
        t.index :sender_id
        t.index :sent_at
        t.index :is_read
      end
    end

    # 세션 통계 테이블
    unless table_exists?(:kakao_consultation_stats)
      create_table :kakao_consultation_stats do |t|
        t.references :kakao_consultation_session, null: false, foreign_key: true
        t.integer :total_messages, default: 0
        t.integer :customer_messages, default: 0
        t.integer :agent_messages, default: 0
        t.integer :response_time_avg, comment: '평균 응답 시간 (초)'
        t.integer :session_duration, comment: '상담 시간 (초)'
        t.float :satisfaction_score, comment: '만족도 점수'
        
        t.timestamps
      end
    end
  end
end
