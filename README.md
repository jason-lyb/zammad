# Zammad 오픈소스 개발

- ## 설정
  - 파일 전송 디렉토리 설정
    - docker exec zammad-railsserver mkdir -p /opt/zammad/storage/kakao_chat/thumbnails
    - docker exec zammad-railsserver chown -R zammad:zammad /opt/zammad/storage
  - 썸네일 관련 mini_magick 설치
    - docker exec -it --user root zammad-railsserver gem install mini_magick
  - docker-compose.yml
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

  - ### Zammad Docker 설치
    - 작업 디렉토리 생성
      - ``` bash
        mkdir ~/zammad-docker
        cd ~/zammad-docker
    - Dcoker Compose 파일 다운로드
      - wget https://raw.githubusercontent.com/zammad/zammad-docker-compose/master/docker-compose.yml
    - 환경변수 다운로드
      - wget https://raw.githubusercontent.com/zammad/zammad-docker-compose/master/.env.dist
    - docker-compose.yml
      - ```yml
        version: "3.8"

        x-shared:
          zammad-service: &zammad-service
            environment: &zammad-environment
              MEMCACHE_SERVERS: ${MEMCACHE_SERVERS:-zammad-memcached:11211}
              POSTGRESQL_DB: ${POSTGRES_DB:-zammad_production}
              POSTGRESQL_HOST: ${POSTGRES_HOST:-zammad-postgresql}
              POSTGRESQL_USER: ${POSTGRES_USER:-zammad}
              POSTGRESQL_PASS: ${POSTGRES_PASS:-zammad}
              POSTGRESQL_PORT: ${POSTGRES_PORT:-5432}
              POSTGRESQL_OPTIONS: ${POSTGRESQL_OPTIONS:-?pool=50}
              POSTGRESQL_DB_CREATE:
              REDIS_URL: ${REDIS_URL:-redis://zammad-redis:6379}
              S3_URL:
              # Backup settings
              BACKUP_DIR: "${BACKUP_DIR:-/var/tmp/zammad}"
              BACKUP_TIME: "${BACKUP_TIME:-03:00}"
              HOLD_DAYS: "${HOLD_DAYS:-10}"
              TZ: "${TZ:-Asia/Seoul}"
              # Allow passing in these variables via .env:
              AUTOWIZARD_JSON:
              AUTOWIZARD_RELATIVE_PATH:
              ELASTICSEARCH_ENABLED:
              ELASTICSEARCH_SCHEMA:
              ELASTICSEARCH_HOST:
              ELASTICSEARCH_PORT:
              ELASTICSEARCH_USER: ${ELASTICSEARCH_USER:-elastic}
              ELASTICSEARCH_PASS: ${ELASTICSEARCH_PASS:-zammad}
              ELASTICSEARCH_NAMESPACE:
              ELASTICSEARCH_REINDEX:
              NGINX_PORT:
              NGINX_CLIENT_MAX_BODY_SIZE:
              NGINX_SERVER_NAME:
              NGINX_SERVER_SCHEME:
              RAILS_TRUSTED_PROXIES:
              ZAMMAD_HTTP_TYPE:
              ZAMMAD_FQDN:
              ZAMMAD_WEB_CONCURRENCY:
              ZAMMAD_PROCESS_SESSIONS_JOBS_WORKERS:
              ZAMMAD_PROCESS_SCHEDULED_JOBS_WORKERS:
              ZAMMAD_PROCESS_DELAYED_JOBS_WORKERS:
              # ZAMMAD_SESSION_JOBS_CONCURRENT is deprecated, please use ZAMMAD_PROCESS_SESSIONS_JOBS_WORKERS instead.
              ZAMMAD_SESSION_JOBS_CONCURRENT:
              # Variables used by ngingx-proxy container for reverse proxy creations
              # for docs refer to https://github.com/nginx-proxy/nginx-proxy
              VIRTUAL_HOST:
              VIRTUAL_PORT:
              # Variables used by acme-companion for retrieval of LetsEncrypt certificate
              # for docs refer to https://github.com/nginx-proxy/acme-companion
              LETSENCRYPT_HOST:
              LETSENCRYPT_EMAIL:

            image: ${IMAGE_REPO:-ghcr.io/zammad/zammad}:${VERSION:-6.5.0-75}
            restart: ${RESTART:-always}
            volumes:
              - zammad-storage:/opt/zammad/storage
            depends_on:
              - zammad-memcached
              - zammad-postgresql
              - zammad-redis

        services:
          zammad-backup:
            <<: *zammad-service
            command: ["zammad-backup"]
            container_name: zammad-backup  
            volumes:
              - zammad-backup:/var/tmp/zammad
              - zammad-storage:/opt/zammad/storage:ro
            user: 0:0

          zammad-elasticsearch:
            image: bitnami/elasticsearch:${ELASTICSEARCH_VERSION:-8.18.0}
            container_name: zammad-elasticsearch  
            restart: ${RESTART:-always}
            volumes:
              - elasticsearch-data:/bitnami/elasticsearch/data
            environment:
              # Enable authorization without HTTPS. For external access with
              #   SSL termination, use solutions like nginx-proxy-manager.
              ELASTICSEARCH_ENABLE_SECURITY: 'true'
              ELASTICSEARCH_SKIP_TRANSPORT_TLS: 'true'
              ELASTICSEARCH_ENABLE_REST_TLS: 'false'
              # ELASTICSEARCH_USER is hardcoded to 'elastic' in the container.
              ELASTICSEARCH_PASSWORD: ${ELASTICSEARCH_PASS:-zammad}
            ports:
              - "9200:9200"
              - "9300:9300"     

          zammad-init:
            <<: *zammad-service
            command: ["zammad-init"]
            depends_on:
              - zammad-postgresql
            container_name: zammad-init    
            restart: on-failure
            user: 0:0

          zammad-memcached:
            command: memcached -m 256M
            image: memcached:${MEMCACHE_VERSION:-1.6.38-alpine}
            container_name: zammad-memcached  
            restart: ${RESTART:-always}

          zammad-nginx:
            <<: *zammad-service
            command: ["zammad-nginx"]
            container_name: zammad-nginx  
            expose:
              - "${NGINX_PORT:-8080}"
            ports:
              - "${NGINX_EXPOSE_PORT:-8080}:${NGINX_PORT:-8080}"
            depends_on:
              - zammad-railsserver
            volumes:
              - /home/jason/zammad-dev/public/assets:/opt/zammad/public/assets:ro

          zammad-postgresql:
            environment:
              POSTGRES_DB: ${POSTGRES_DB:-zammad_production}
              POSTGRES_USER: ${POSTGRES_USER:-zammad}
              POSTGRES_PASSWORD: ${POSTGRES_PASS:-zammad}
            image: postgres:${POSTGRES_VERSION:-17.5-alpine}
            container_name: zammad-postgresql  
            restart: ${RESTART:-always}
            ports: 
              - "5432:5432"
            volumes:
              - postgresql-data:/var/lib/postgresql/data

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

          zammad-redis:
            image: redis:${REDIS_VERSION:-7.4.3-alpine}
            container_name: zammad-redis  
            restart: ${RESTART:-always}
            volumes:
              - redis-data:/data

          zammad-scheduler:
            <<: *zammad-service
            command: ["zammad-scheduler"]
            container_name: zammad-scheduler  

          zammad-websocket:
            <<: *zammad-service
            command: ["zammad-websocket"]
            container_name: zammad-websocket  

        volumes:
          elasticsearch-data:
            driver: local
          postgresql-data:
            driver: local
          redis-data:
            driver: local
          zammad-backup:
            driver: local
          zammad-storage:
            driver: local
          zammad-files:
            driver: local
          zammad-tmp:
            driver: local
          zammad-log:
            driver: local   
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
    - DB 마이그레이션 상태확인
      - **docker exec zammad-railsserver bundle exec rails db:migrate:status**
      ``` bash
      up     20250423083238  Issue5573 increase webhook endpoint limit
      up     20250501141812  Issue5567 microsoft graph outbound shared mailbox
      up     20250812134500  ********** NO FILE **********
      up     20250813000001  Create kakao consultation sessions
      up     20250829000001  ********** NO FILE **********
      up     20250829000002  ********** NO FILE **********
      up     20250901000013  ********** NO FILE **********
      up     20250902000001  ********** NO FILE **********
      up     20250905000001  ********** NO FILE **********
    - DB 마이그레이션 20250813000001 이전까지 롤백
      - **docker exec zammad-railsserver bundle exec rails db:migrate:down VERSION=20250813000001**

    - DB 마이그레이션 20250813000001 재설치
      - **docker exec zammad-railsserver bundle exec rails db:migrate:up VERSION=20250813000001**

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
