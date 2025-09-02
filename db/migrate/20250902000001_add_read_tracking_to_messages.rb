class AddReadTrackingToMessages < ActiveRecord::Migration[6.1]
  def change
    # 개별 상담원별 읽음 상태 추적을 위한 테이블
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
    
    # 기존 read_by_agent 컬럼은 팀 전체 읽음 상태로 활용
    # (누구든 한 명이라도 읽으면 true)
    add_column :kakao_consultation_messages, :team_read_at, :datetime
    add_column :kakao_consultation_messages, :team_read_by, :integer
    add_foreign_key :kakao_consultation_messages, :users, column: :team_read_by
  end
end
