#!/usr/bin/env ruby
# Simple test script for Kakao consultation models

puts "🔍 카카오톡 상담 시스템 모델 테스트"
puts "=" * 50

# Basic syntax check
models = [
  '/home/jason/zammad-dev/app/models/kakao_consultation_session.rb',
  '/home/jason/zammad-dev/app/models/kakao_consultation_message.rb',
  '/home/jason/zammad-dev/app/models/kakao_consultation_stats.rb'
]

models.each do |model_file|
  puts "\n📁 검사 중: #{File.basename(model_file)}"
  
  begin
    content = File.read(model_file)
    
    # Check for common issues
    if content.include?('ApplicationRecord')
      puts "❌ ApplicationRecord 발견 - ActiveRecord::Base 또는 ApplicationModel로 변경 필요"
    elsif content.include?('ActiveRecord::Base') || content.include?('ApplicationModel')
      puts "✅ 올바른 베이스 클래스 사용"
    else
      puts "⚠️  베이스 클래스를 찾을 수 없음"
    end
    
    # Check for required validations
    if content.include?('validates')
      puts "✅ 유효성 검사 규칙 있음"
    else
      puts "⚠️  유효성 검사 규칙 없음"
    end
    
    # Check for associations
    if content.include?('belongs_to') || content.include?('has_many') || content.include?('has_one')
      puts "✅ 연관관계 정의됨"
    else
      puts "⚠️  연관관계 정의 없음"
    end
    
    # Check Ruby syntax by attempting to parse (basic check)
    begin
      # This is a very basic syntax check
      eval("class TestClass; #{content.gsub('class ', 'class Test')}; end", binding, model_file)
      puts "✅ 기본 Ruby 구문 검사 통과"
    rescue SyntaxError => e
      puts "❌ Ruby 구문 오류: #{e.message}"
    rescue => e
      puts "⚠️  의존성 오류 (정상): #{e.class.name}"
    end
    
  rescue => e
    puts "❌ 파일 읽기 실패: #{e.message}"
  end
end

puts "\n" + "=" * 50
puts "📊 데이터베이스 마이그레이션 파일 확인"

migration_file = '/home/jason/zammad-dev/db/migrate/20250813000001_create_kakao_consultation_sessions.rb'
if File.exist?(migration_file)
  puts "✅ 마이그레이션 파일 존재: #{File.basename(migration_file)}"
  migration_content = File.read(migration_file)
  
  tables = ['kakao_consultation_sessions', 'kakao_consultation_messages', 'kakao_consultation_stats']
  tables.each do |table|
    if migration_content.include?("create_table :#{table}")
      puts "✅ #{table} 테이블 생성 코드 있음"
    else
      puts "❌ #{table} 테이블 생성 코드 없음"
    end
  end
else
  puts "❌ 마이그레이션 파일을 찾을 수 없음"
end

puts "\n" + "=" * 50
puts "🚀 다음 단계:"
puts "1. Zammad 서버 환경에서 'bundle exec rails db:migrate' 실행"
puts "2. 통합 > 카카오 설정에서 API 서버 정보 입력"
puts "3. '/kakao_chat' 경로로 채팅 인터페이스 테스트"
puts "4. 실제 상담톡 API 서버와 연동 테스트"
