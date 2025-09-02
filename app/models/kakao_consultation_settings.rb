# 카카오톡 상담 시스템 설정
class KakaoConsultationSettings
  class << self
    # 다중 상담원 읽음 처리 정책 설정
    def setup_multi_agent_settings
      # 읽음 처리 정책
      Setting.create_or_update(
        title: 'KakaoTalk Multi-Agent Read Policy',
        name: 'kakao_multi_agent_read_policy',
        area: 'Integration::KakaoTalk',
        description: 'Defines how message read status is handled with multiple agents.',
        options: {
          form: [
            {
              display: 'Read Policy',
              null: false,
              name: 'policy',
              tag: 'select',
              options: {
                'assigned_only' => 'Only assigned agent can mark as read',
                'first_reader_claims' => 'First reader becomes assigned agent',
                'team_shared' => 'Any agent can mark as read (shared responsibility)'
              }
            }
          ]
        },
        state: 'first_reader_claims',
        frontend: false
      )
      
      # 자동 상담원 할당 설정
      Setting.create_or_update(
        title: 'KakaoTalk Auto Agent Assignment',
        name: 'kakao_auto_agent_assignment',
        area: 'Integration::KakaoTalk',
        description: 'Automatically assign agent when they first interact with a session.',
        options: {
          form: [
            {
              display: 'Enable Auto Assignment',
              null: false,
              name: 'enabled',
              tag: 'boolean',
              default: true
            }
          ]
        },
        state: true,
        frontend: false
      )
      
      # 읽음 상태 실시간 동기화
      Setting.create_or_update(
        title: 'KakaoTalk Real-time Read Sync',
        name: 'kakao_realtime_read_sync',
        area: 'Integration::KakaoTalk',
        description: 'Enable real-time synchronization of read status across all agents.',
        options: {
          form: [
            {
              display: 'Enable Real-time Sync',
              null: false,
              name: 'enabled',
              tag: 'boolean',
              default: true
            }
          ]
        },
        state: true,
        frontend: false
      )
    end
  end
end
