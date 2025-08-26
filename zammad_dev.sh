#!/bin/bash
# dev_scripts/zammad_dev.sh - Docker 환경용

# Docker Compose 프로젝트 디렉토리 설정
ZAMMAD_DOCKER_DIR="/root/zammad-docker"
cd $ZAMMAD_DOCKER_DIR

# 1. Assets 컴파일 및 서버 재시작 (Docker 환경)
restart_zammad() {
    echo "🔄 Restarting Zammad (Docker)..."
    
    # Assets 컴파일
    echo "📦 Compiling assets..."
    docker-compose exec --user zammad zammad-railsserver bash -c "cd /opt/zammad && RAILS_ENV=production bundle exec rake assets:precompile"
    
    if [ $? -eq 0 ]; then
        echo "✅ Assets compiled successfully"
        
        # Docker 컨테이너 재시작
        echo "🔄 Restarting Docker containers..."
        docker-compose restart zammad-railsserver zammad-websocket
        
        # 웹서버도 재시작 (nginx가 있는 경우)
        docker-compose restart zammad-nginx 2>/dev/null || true
        
        # 컨테이너가 완전히 시작될 때까지 대기
        echo "⏳ Waiting for containers to start..."
        sleep 10
        
        # 헬스체크
        echo "🏥 Checking container health..."
        docker-compose ps
        
        echo "✅ Zammad restarted successfully"
    else
        echo "❌ Assets compilation failed"
        return 1
    fi
}

# 2. 빠른 CoffeeScript 문법 체크 (Docker 환경)
check_coffee() {
    echo "☕ Checking CoffeeScript syntax..."
    
    # Docker 컨테이너 내에서 CoffeeScript 문법 체크
    docker-compose exec --user zammad zammad-railsserver bash -c "
        cd /opt/zammad
        find app/assets/javascripts -name '*.coffee' -type f | head -20 | while read file; do
            echo \"Checking: \$file\"
            coffee -c \"\$file\" 2>&1 | grep -E '(Error|SyntaxError)' && echo \"❌ Error in \$file\" || true
        done
    "
    
    # 특별히 kakao 관련 파일 체크
    docker-compose exec --user zammad zammad-railsserver bash -c "
        cd /opt/zammad
        find app/assets/javascripts -name '*kakao*.coffee' -type f | while read file; do
            echo \"Checking Kakao file: \$file\"
            coffee -c \"\$file\" 2>&1
        done
    " 2>&1 | grep -E "(Error|SyntaxError)"
    
    if [ $? -eq 0 ]; then
        echo "❌ CoffeeScript syntax errors found"
        return 1
    else
        echo "✅ CoffeeScript syntax OK"
        return 0
    fi
}

# 3. 로그 실시간 모니터링 (Docker 환경)
watch_logs() {
    echo "📋 Watching Zammad logs (Docker)..."
    
    # Docker 로그 실시간 모니터링
    docker-compose logs -f zammad-railsserver | grep -E "(ERROR|WARN|Kakao|Integration|Started|Completed)"
}

# 4. 개발용 데이터 리셋 (Docker 환경)
reset_dev_data() {
    echo "🗑️ Resetting development data (Docker)..."
    
    # Docker 환경에서는 조심스럽게 진행
    read -p "⚠️  This will reset ALL Zammad data. Are you sure? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        docker-compose exec --user zammad zammad-railsserver bash -c "
            cd /opt/zammad
            RAILS_ENV=production bundle exec rake db:drop db:create db:migrate db:seed
        "
        echo "✅ Development data reset complete"
    else
        echo "❌ Reset cancelled"
    fi
}

# 5. Docker 컨테이너 상태 확인
check_containers() {
    echo "🐳 Checking Docker container status..."
    
    echo "=== Container Status ==="
    docker-compose ps
    
    echo ""
    echo "=== Container Health ==="
    docker-compose exec zammad-railsserver bash -c "curl -s http://localhost:3000/api/v1/monitoring/health_check" 2>/dev/null || echo "Health check failed"
    
    echo ""
    echo "=== Resource Usage ==="
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" $(docker-compose ps -q)
}

# 6. 빠른 파일 수정 및 적용
quick_deploy() {
    local file_pattern=$1
    
    if [ -z "$file_pattern" ]; then
        echo "Usage: $0 quick <file_pattern>"
        echo "Example: $0 quick kakao"
        return 1
    fi
    
    echo "🚀 Quick deploy for files matching: $file_pattern"
    
    # 1. 문법 체크
    echo "1️⃣ Checking syntax..."
    if check_coffee; then
        
        # 2. 수정된 파일들을 컨테이너로 복사 (만약 로컬 파일이 있다면)
        echo "2️⃣ Copying files to container..."
        # docker cp local_file container:/opt/zammad/path
        
        # 3. Assets 컴파일 (빠른 버전)
        echo "3️⃣ Quick assets compile..."
        docker-compose exec --user zammad zammad-railsserver bash -c "
            cd /opt/zammad
            RAILS_ENV=production bundle exec rake assets:precompile RAILS_GROUPS=assets
        "
        
        # 4. 웹서버만 재시작 (DB는 건드리지 않음)
        echo "4️⃣ Restarting web services..."
        docker-compose restart zammad-railsserver
        
        echo "✅ Quick deploy completed!"
    else
        echo "❌ Syntax errors found. Fix them first."
        return 1
    fi
}

# 7. 통합 개발 워크플로우 (Docker 환경)
dev_workflow() {
    echo "🚀 Starting development workflow (Docker)..."
    
    # 1. 컨테이너 상태 확인
    echo "1️⃣ Checking container status..."
    check_containers
    
    # 2. 문법 체크
    echo "2️⃣ Checking syntax..."
    if check_coffee; then
        # 3. Assets 컴파일 및 재시작
        echo "3️⃣ Compiling and restarting..."
        restart_zammad
        
        if [ $? -eq 0 ]; then
            # 4. 로그 모니터링 시작 (백그라운드)
            echo "4️⃣ Starting log monitoring..."
            (sleep 5 && watch_logs) &
            
            echo "✅ Development workflow complete!"
            echo "📖 Check logs above for any errors"
            echo "🌐 Access Zammad at: http://localhost (or your configured port)"
        else
            echo "❌ Restart failed"
            return 1
        fi
    else
        echo "❌ Fix CoffeeScript errors first"
        return 1
    fi
}

# 8. 개발 환경 초기화
init_dev() {
    echo "🔧 Initializing development environment..."
    
    # Docker compose 파일 확인
    if [ ! -f "docker-compose.yml" ]; then
        echo "❌ docker-compose.yml not found in $ZAMMAD_DOCKER_DIR"
        return 1
    fi
    
    # 컨테이너 시작
    echo "🚀 Starting containers..."
    docker-compose up -d
    
    # 초기화 완료까지 대기
    echo "⏳ Waiting for initialization..."
    sleep 30
    
    # 상태 확인
    check_containers
    
    echo "✅ Development environment initialized"
}

# 메인 스크립트
case "$1" in
    restart)
        restart_zammad
        ;;
    check)
        check_coffee
        ;;
    logs)
        watch_logs
        ;;
    status)
        check_containers
        ;;
    quick)
        quick_deploy $2
        ;;
    dev)
        dev_workflow
        ;;
    init)
        init_dev
        ;;
    *)
        echo "Usage: $0 {restart|check|logs|reset|status|quick|dev|init}"
        echo ""
        echo "Commands:"
        echo "  restart  - Compile assets and restart Zammad containers"
        echo "  check    - Check CoffeeScript syntax in containers"
        echo "  logs     - Watch Zammad logs in real-time"
        echo "  status   - Check Docker container status and health"
        echo "  quick    - Quick deploy for specific files"
        echo "  dev      - Full development workflow"
        echo "  init     - Initialize development environment"
        echo ""
        echo "Examples:"
        echo "  $0 dev                 # Full development workflow"
        echo "  $0 quick kakao         # Quick deploy for kakao files"
        echo "  $0 restart             # Just restart after manual changes"
        exit 1
        ;;
esac