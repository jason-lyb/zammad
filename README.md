# Zammad 오픈소스 개발

- ## 설정
  - 파일 전송 디렉토리 생성
    - docker exec zammad-railsserver mkdir -p /opt/zammad/storage/kakao_chat/thumbnails
    - docker exec zammad-railsserver chown -R zammad:zammad /opt/zammad/storage
  - 썸네일 관련 mini_magick 설치
    - docker exec -it --user root zammad-railsserver gem install mini_magick
  - docker -compose.yml
    - ```yml
        zammad-railsserver:
          <<: *zammad-service
          command: ["zammad-railsserver"]
          container_name: zammad-railsserver  
          volumes: 
            # 전체 소스 마운트 
            #- ./zammad-source:/opt/zammad
            #- zammad-files:/opt/zammad/public/assets  # 개발환경에서는 주석, 운영에서는 활성화
            - zammad-storage:/opt/zammad/storage    # Docker가 데이터 보존 
            - zammad-tmp:/opt/zammad/tmp            # 컨테이너 재시작 시 유지 
            - zammad-log:/opt/zammad/log            # 안전한 데이터 관리      
            - /home/jason/zammad-dev/app:/opt/zammad/app:rw
            - /home/jason/zammad-dev/config:/opt/zammad/config:rw
            - /home/jason/zammad-dev/lib:/opt/zammad/lib:rw
            - /home/jason/zammad-dev/public:/opt/zammad/public:rw
            - /home/jason/zammad-dev/db:/opt/zammad/db:rw

- ## 개발 환경
  - Source
    - 10.1.4.210 Alpha 서버 - root 권한
      - /home/jason/zammad-dev 
    - Zammad 컴파일
      - root/zammad-docker
        - **./dev_scripts/zammad_dev.sh restart**
        ```bash
        restart_zammad() {
        echo "🔄 Restarting Zammad (Docker)..."
        
        # Assets 컴파일
        echo "📦 Compiling assets..."
        docker-compose exec --user zammad zammad-railsserver bash -c "cd /opt/zammad && RAILS_ENV=production bundle exec rake assets:precompile"
        
        if [ $? -eq 0 ]; then
            echo "✅ Assets compiled successfully"
            
            # Docker 컨테이너 재시작
            echo "🔄 Restarting Docker containers..."
            docker-compose restart zammad-railsserver zammad-nginx
            
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
    - db 마이그레이션
      - **docker exec zammad-railsserver bundle exec rails db:migrate**

- ## 운영 배포
  - 운영서버 : 10.1.4.200
  - 백업
    ```bash
    /tmp/zammad-assets-backup/ 
    sudo rm -rf /tmp/zammad-assets-backup/
    sudo docker cp zammad-railsserver:/opt/zammad/public/assets/. /tmp/zammad-assets-backup/
  - 롤백
    ```bash
    sudo docker cp /tmp/zammad-assets-backup/. zammad-railsserver:/opt/zammad/public/assets/
  - 파일 복사 및 재시작
    - zammad-railsserver assets 파일 복사
        ```bash
        sudo chown -R jason:jason /tmp/zammad-assets
        docker exec zammad-railsserver ls -l /opt/zammad/public/assets/    # 파일조회
        docker exec zammad-railsserver rm -rf /opt/zammad/public/assets/    # 파일삭제
        sudo docker cp /tmp/zammad-assets/. zammad-railsserver:/opt/zammad/public/assets/ 
        # 소유자 변경
        docker exec -u root zammad-railsserver chown -R zammad:zammad /opt/zammad/public/assets
        docker-compose restart zammad-nginx zammad-railsserver
    - zammad-nginx assets 파일 복사
        ```bash
        docker exec zammad-nginx ls -l /opt/zammad/public/assets/    # 파일조회
        docker exec zammad-nginx rm -rf /opt/zammad/public/assets/    # 파일삭제
        sudo docker cp /tmp/zammad-assets/. zammad-nginx:/opt/zammad/public/assets/ 
        # 소유자 변경
        docker exec -u root zammad-nginx chown -R zammad:zammad /opt/zammad/public/assets
        docker-compose restart zammad-nginx zammad-railsserver
    - 



- ## 카카오 상담톡 API 추가
  - **메세지 수신 : [http://10.1.4.210:8080/api/v1/kakao_chat/message](http://10.1.4.210:8080/api/v1/kakao_chat/message)** 
    - 요청 예시 (JSON):
    ```json
    {
      "user_key": "kakao_user_123456780",
      "session_id": "session_abc124",
      "time": "2025-09-01T14:30:00+09:00",
      "serial_number": "msg_serial_001",
      "content": "콜마너 가입시 업체는 어떻게 신청하나요?",
      "type": "text"
    }
    ```
  - **메세지 전송 : [http://10.1.4.210:8080/api/v1/kakao_chat/send_message](http://10.1.4.210:8080/api/v1/kakao_chat/send_message)**
    - 요청 예시 (JSON):
    ```json
    {
        "session_id": "session_abc124",
        "content": "안녕하세요. 테스트 메시지입니다111121164",
        "sender_type": "agent",
        "agent_id": 3
    }
    ```
  - **상담 종료 : [http://10.1.4.210:8080/api/v1/kakao_chat/end_session](http://10.1.4.210:8080/api/v1/kakao_chat/end_session)**
    - 요청 예시 (JSON):
    ```json
    {
        "session_id": "session_abc122",
        "reason": "상담 완료",
        "ended_by": "agent",
        "agent_id": "3"
    }
    ```    
  - **파일 전송 : [http://10.1.4.210:8080/api/v1/kakao_chat/upload_file](http://10.1.4.210:8080/api/v1/kakao_chat/upload_file)**
    - 고객 요청 예시 (JSON):
    ```json
    {
        "session_id": "session123",
        "sender_type": "customer",
        "sender_name": "홍길동",
        "content": "사진을 보내드립니다",
        "file": [파일]
    }
    ```        
    - 상담원 요청 예시 (JSON):
    ```json
    {
        "session_id": "session123",
        "sender_type": "agent",
        "agent_id": "123",
        "content": "자료를 전달합니다",
        "file": [파일]
    }

    ```        
