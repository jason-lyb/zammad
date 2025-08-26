class KakaoChat extends App.ControllerSubContent
  @requiredPermission: 'admin'
  header: __('카카오톡 상담')

  constructor: (params) ->
    super
    @render()

  render: =>
    @html '''
      <div class="page-header">
        <div class="page-header-title">
          <h1>카카오톡 상담</h1>
        </div>
      </div>
      <div class="page-content">
        <div class="row">
          <div class="col-md-6">
            <div class="well">
              <h3>활성 상담 목록</h3>
              <div id="chatList">
                <p>상담 목록을 불러오는 중...</p>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <div class="well">
              <h3>채팅 내용</h3>
              <div id="chatContent">
                <p>상담을 선택하여 채팅을 시작하세요</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    '''
    
    # 데모 데이터 표시
    setTimeout(@loadDemoData, 500)

  loadDemoData: =>
    @$('#chatList').html '''
      <div style="border: 1px solid #ddd; padding: 10px; margin: 5px 0; cursor: pointer;">
        <strong>고객1</strong><br>
        <small>안녕하세요. 문의사항이 있습니다.</small>
      </div>
      <div style="border: 1px solid #ddd; padding: 10px; margin: 5px 0; cursor: pointer;">
        <strong>고객2</strong><br>
        <small>상품 문의드립니다.</small>
      </div>
    '''
    
    @$('#chatContent').html '''
      <div style="background: #f8f9fa; padding: 15px; margin: 5px 0;">
        <p><strong>상담 기능:</strong></p>
        <ul>
          <li>실시간 채팅 목록 조회</li>
          <li>메시지 송수신</li>
          <li>상담 세션 관리</li>
          <li>통계 및 리포팅</li>
        </ul>
        <p><em>현재는 데모 화면입니다.</em></p>
      </div>
    '''

App.KakaoChat = KakaoChat