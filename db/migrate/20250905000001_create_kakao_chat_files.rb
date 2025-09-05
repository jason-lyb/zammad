class CreateKakaoChatFiles < ActiveRecord::Migration[7.0]
  def change
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
    
    # 메시지 테이블에 파일 관련 컬럼 추가
    add_column :kakao_consultation_messages, :has_attachments, :boolean, default: false
    add_column :kakao_consultation_messages, :attachment_count, :integer, default: 0
    
    add_index :kakao_consultation_messages, [:has_attachments]
  end
end
