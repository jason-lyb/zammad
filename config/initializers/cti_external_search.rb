# CTI External Search Configuration
# This initializer sets up external search functionality for CTI phone numbers

Rails.application.config.after_initialize do
    # CTI 외부 검색 사이트 URL 설정
    Setting.create_if_not_exists(
      title: 'CTI External Search URL',
      name: 'cti_external_search_url',
      area: 'Integration::CTI',
      description: 'External site URL for phone number lookup. Use {phone} as placeholder for phone number.',
      options: {
        form: [
          {
            display: 'URL',
            null: false,
            name: 'cti_external_search_url',
            tag: 'input',
            placeholder: 'https://example.com/search?phone={phone}',
          },
        ],
      },
      state: 'https://backoffice-admin-space.callmaner.com/cid?',
      preferences: {
        permission: ['admin.integration'],
        prio: 1000,
      },
      frontend: true
    )
  
    # CTI 외부 검색 활성화/비활성화 설정
    Setting.create_if_not_exists(
      title: 'CTI External Search Enabled',
      name: 'cti_external_search_enabled',
      area: 'Integration::CTI',
      description: 'Enable external search button for incoming calls.',
      options: {
        form: [
          {
            display: 'Enabled',
            null: true,
            name: 'cti_external_search_enabled',
            tag: 'boolean',
            options: {
              true  => 'yes',
              false => 'no',
            },
          },
        ],
      },
      state: true,
      preferences: {
        permission: ['admin.integration'],
        prio: 999,
      },
      frontend: true
    )
  
  end