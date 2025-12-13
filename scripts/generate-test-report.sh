#!/bin/bash

# DOA Market - 테스트 보고서 생성 스크립트
# 모든 테스트 결과를 HTML 보고서로 생성합니다

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "📊 DOA Market - 테스트 보고서 생성 중..."
echo ""

# 보고서 디렉토리
REPORT_DIR="$PROJECT_ROOT/test-reports"
mkdir -p "$REPORT_DIR"

# 테스트 결과 디렉토리
TEST_RESULTS_DIR="$PROJECT_ROOT/test-results"
mkdir -p "$TEST_RESULTS_DIR/unit" "$TEST_RESULTS_DIR/integration" "$TEST_RESULTS_DIR/e2e"

# HTML 보고서 생성
cat > "$REPORT_DIR/index.html" << 'HTML_HEAD'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DOA Market - 테스트 보고서</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .card {
            background: #f9f9f9;
            border-radius: 8px;
            padding: 20px;
            border-left: 4px solid #4CAF50;
        }
        .card.failed {
            border-left-color: #f44336;
        }
        .card.warning {
            border-left-color: #ff9800;
        }
        .card h3 {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
            text-transform: uppercase;
        }
        .card .number {
            font-size: 36px;
            font-weight: bold;
            color: #333;
        }
        .card .label {
            color: #999;
            font-size: 12px;
            margin-top: 5px;
        }
        .section {
            margin: 40px 0;
        }
        .section h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }
        .test-item {
            background: #f9f9f9;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .test-item.passed {
            border-left: 4px solid #4CAF50;
        }
        .test-item.failed {
            border-left: 4px solid #f44336;
        }
        .test-item.unknown {
            border-left: 4px solid #9e9e9e;
        }
        .status {
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status.passed {
            background: #4CAF50;
            color: white;
        }
        .status.failed {
            background: #f44336;
            color: white;
        }
        .status.unknown {
            background: #9e9e9e;
            color: white;
        }
        .log-link {
            color: #2196F3;
            text-decoration: none;
            font-size: 12px;
            margin-left: 10px;
        }
        .log-link:hover {
            text-decoration: underline;
        }
        .timestamp {
            color: #999;
            font-size: 12px;
            margin-top: 10px;
        }
        pre {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
            font-size: 12px;
            margin-top: 10px;
            max-height: 300px;
            overflow-y: auto;
        }
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }
        .tab {
            padding: 10px 20px;
            cursor: pointer;
            border: none;
            background: none;
            font-size: 14px;
            color: #666;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
        }
        .tab.active {
            color: #4CAF50;
            border-bottom-color: #4CAF50;
            font-weight: bold;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        .error-details {
            margin-top: 10px;
            padding: 10px;
            background: #ffebee;
            border-left: 3px solid #f44336;
            border-radius: 4px;
            font-size: 12px;
        }
        .coverage-link {
            display: inline-block;
            margin-top: 5px;
            padding: 5px 10px;
            background: #2196F3;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 12px;
        }
        .coverage-link:hover {
            background: #1976D2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 DOA Market 테스트 보고서</h1>
        <div class="timestamp">생성 시간: <span id="timestamp"></span></div>
        
        <div class="summary" id="summary">
            <!-- 동적으로 생성됨 -->
        </div>
        
        <div class="tabs">
            <button class="tab active" onclick="showTab('unit')">단위 테스트</button>
            <button class="tab" onclick="showTab('integration')">통합 테스트</button>
            <button class="tab" onclick="showTab('e2e')">E2E 테스트</button>
        </div>
        
        <div id="unit" class="tab-content active">
            <div class="section">
                <h2>단위 테스트 결과</h2>
                <div id="unit-tests">
                    <!-- 동적으로 생성됨 -->
                </div>
            </div>
        </div>
        
        <div id="integration" class="tab-content">
            <div class="section">
                <h2>통합 테스트 결과</h2>
                <div id="integration-tests">
                    <!-- 동적으로 생성됨 -->
                </div>
            </div>
        </div>
        
        <div id="e2e" class="tab-content">
            <div class="section">
                <h2>E2E 테스트 결과</h2>
                <div id="e2e-tests">
                    <!-- 동적으로 생성됨 -->
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function showTab(tabName) {
            // 모든 탭 콘텐츠 숨기기
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            // 모든 탭 버튼 비활성화
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            // 선택한 탭 활성화
            document.getElementById(tabName).classList.add('active');
            event.target.classList.add('active');
        }
        
        // 타임스탬프 설정
        document.getElementById('timestamp').textContent = new Date().toLocaleString('ko-KR');
        
        // 테스트 데이터
        const testData = {
HTML_HEAD

# 단위 테스트 결과 수집
echo "            unit: {" >> "$REPORT_DIR/index.html"
TOTAL_UNIT=0
PASSED_UNIT=0
FAILED_UNIT=0

for service in api-gateway auth-service user-service product-service order-service payment-service; do
  SERVICE_DIR="$PROJECT_ROOT/backend/$service"
  if [ -d "$SERVICE_DIR" ]; then
    TOTAL_UNIT=$((TOTAL_UNIT + 1))
    LOG_FILE="$TEST_RESULTS_DIR/unit/$service.log"
    
    STATUS="unknown"
    ERROR_MSG=""
    COVERAGE=""
    
    if [ -f "$LOG_FILE" ]; then
      # 테스트 통과 여부 확인 (Jest 출력 형식 기반)
      # "Test Suites: X passed" 또는 "Tests: X passed" 형식 확인
      # 실패가 있는지 먼저 확인 (우선순위)
      if grep -qE "Test Suites:.*[1-9][0-9]* failed" "$LOG_FILE" 2>/dev/null || \
         grep -qE "Tests:.*[1-9][0-9]* failed" "$LOG_FILE" 2>/dev/null || \
         grep -qE "No tests found" "$LOG_FILE" 2>/dev/null; then
        STATUS="failed"
        FAILED_UNIT=$((FAILED_UNIT + 1))
        # 에러 메시지 추출 (실제 에러만)
        ERROR_MSG=$(grep -E "FAIL|Error:|at " "$LOG_FILE" 2>/dev/null | head -3 | tr -d "'" | tr '\n' ' ' || echo "")
      elif grep -qE "Test Suites:.*[0-9]+ passed" "$LOG_FILE" 2>/dev/null || \
           grep -qE "Tests:.*[0-9]+ passed" "$LOG_FILE" 2>/dev/null; then
        STATUS="passed"
        PASSED_UNIT=$((PASSED_UNIT + 1))
      else
        # 로그는 있지만 결과를 파싱할 수 없는 경우
        STATUS="unknown"
      fi
      
      # 커버리지 확인
      if [ -d "$SERVICE_DIR/coverage" ]; then
        COVERAGE="coverage/$service/index.html"
      fi
    fi
    
    # JSON 이스케이프
    ERROR_MSG=$(echo "$ERROR_MSG" | sed "s/'/\\\'/g" | sed 's/"/\\"/g' || echo "")
    
    echo "                '$service': {" >> "$REPORT_DIR/index.html"
    echo "                    status: '$STATUS'," >> "$REPORT_DIR/index.html"
    echo "                    log: 'test-results/unit/$service.log'," >> "$REPORT_DIR/index.html"
    if [ -n "$COVERAGE" ]; then
      echo "                    coverage: '$COVERAGE'," >> "$REPORT_DIR/index.html"
    fi
    if [ -n "$ERROR_MSG" ]; then
      echo "                    error: '${ERROR_MSG:0:200}'," >> "$REPORT_DIR/index.html"
    fi
    echo "                }," >> "$REPORT_DIR/index.html"
  fi
done

echo "            }," >> "$REPORT_DIR/index.html"

# 통합 테스트 결과 수집
echo "            integration: {" >> "$REPORT_DIR/index.html"
INTEGRATION_LOG="$TEST_RESULTS_DIR/integration/integration.log"
if [ -f "$INTEGRATION_LOG" ]; then
  # Jest 출력 형식 기반 확인
  # 실패가 있는지 먼저 확인 (우선순위)
  if grep -qE "Test Suites:.*[1-9][0-9]* failed" "$INTEGRATION_LOG" 2>/dev/null || \
     grep -qE "Tests:.*[1-9][0-9]* failed" "$INTEGRATION_LOG" 2>/dev/null; then
    echo "                status: 'failed'," >> "$REPORT_DIR/index.html"
  elif grep -qE "Test Suites:.*[0-9]+ passed" "$INTEGRATION_LOG" 2>/dev/null || \
       grep -qE "Tests:.*[0-9]+ passed" "$INTEGRATION_LOG" 2>/dev/null; then
    echo "                status: 'passed'," >> "$REPORT_DIR/index.html"
  else
    echo "                status: 'unknown'," >> "$REPORT_DIR/index.html"
  fi
  echo "                log: 'test-results/integration/integration.log'," >> "$REPORT_DIR/index.html"
else
  echo "                status: 'unknown'," >> "$REPORT_DIR/index.html"
fi
echo "            }," >> "$REPORT_DIR/index.html"

# E2E 테스트 결과 수집
echo "            e2e: {" >> "$REPORT_DIR/index.html"
E2E_LOG="$TEST_RESULTS_DIR/e2e/e2e.log"
if [ -f "$E2E_LOG" ]; then
  # Playwright 출력 형식: "X passed (Xms)" 또는 "X failed"
  # 실패한 테스트가 있는지 먼저 확인
  if grep -qE "[1-9][0-9]* failed" "$E2E_LOG" 2>/dev/null; then
    echo "                status: 'failed'," >> "$REPORT_DIR/index.html"
  elif grep -qE "[0-9]+ passed \([0-9]+m?s\)" "$E2E_LOG" 2>/dev/null; then
    echo "                status: 'passed'," >> "$REPORT_DIR/index.html"
  else
    echo "                status: 'unknown'," >> "$REPORT_DIR/index.html"
  fi
  echo "                log: 'test-results/e2e/e2e.log'," >> "$REPORT_DIR/index.html"
else
  echo "                status: 'unknown'," >> "$REPORT_DIR/index.html"
fi
echo "            }" >> "$REPORT_DIR/index.html"

cat >> "$REPORT_DIR/index.html" << 'HTML_FOOT'
        };
        
        // 요약 카드 생성
        function renderSummary() {
            const summaryDiv = document.getElementById('summary');
            const unitData = testData.unit;
            const total = Object.keys(unitData).length;
            const passed = Object.values(unitData).filter(t => t.status === 'passed').length;
            const failed = Object.values(unitData).filter(t => t.status === 'failed').length;
            const unknown = Object.values(unitData).filter(t => t.status === 'unknown').length;
            
            summaryDiv.innerHTML = `
                <div class="card">
                    <h3>총 테스트</h3>
                    <div class="number">${total}</div>
                    <div class="label">서비스</div>
                </div>
                <div class="card">
                    <h3>통과</h3>
                    <div class="number" style="color: #4CAF50">${passed}</div>
                    <div class="label">서비스</div>
                </div>
                <div class="card ${failed > 0 ? 'failed' : ''}">
                    <h3>실패</h3>
                    <div class="number" style="color: #f44336">${failed}</div>
                    <div class="label">서비스</div>
                </div>
                ${unknown > 0 ? `
                <div class="card warning">
                    <h3>미실행</h3>
                    <div class="number" style="color: #ff9800">${unknown}</div>
                    <div class="label">서비스</div>
                </div>
                ` : ''}
            `;
        }
        
        // 단위 테스트 렌더링
        function renderUnitTests() {
            const container = document.getElementById('unit-tests');
            const tests = testData.unit;
            
            let html = '';
            for (const [service, data] of Object.entries(tests)) {
                const statusClass = data.status || 'unknown';
                const statusText = statusClass === 'passed' ? '통과' : statusClass === 'failed' ? '실패' : '미실행';
                const logPath = data.log || '';
                const coveragePath = data.coverage || '';
                const errorMsg = data.error || '';
                
                html += `
                    <div class="test-item ${statusClass}">
                        <div style="flex: 1;">
                            <strong>${service}</strong>
                            <div style="margin-top: 5px; font-size: 12px;">
                                ${logPath ? `<a href="${logPath}" class="log-link" target="_blank">로그 보기</a>` : ''}
                                ${coveragePath ? `<a href="${coveragePath}" class="coverage-link" target="_blank">커버리지</a>` : ''}
                            </div>
                            ${errorMsg ? `<div class="error-details">${errorMsg}</div>` : ''}
                        </div>
                        <span class="status ${statusClass}">${statusText}</span>
                    </div>
                `;
            }
            
            container.innerHTML = html || '<p>테스트 결과가 없습니다.</p>';
        }
        
        // 통합 테스트 렌더링
        function renderIntegrationTests() {
            const container = document.getElementById('integration-tests');
            const data = testData.integration;
            
            if (data && data.status) {
                const statusClass = data.status;
                const statusText = statusClass === 'passed' ? '통과' : statusClass === 'failed' ? '실패' : '미실행';
                const logPath = data.log || '';
                
                container.innerHTML = `
                    <div class="test-item ${statusClass}">
                        <div style="flex: 1;">
                            <strong>통합 테스트</strong>
                            ${logPath ? `<div style="margin-top: 5px;"><a href="${logPath}" class="log-link" target="_blank">로그 보기</a></div>` : ''}
                        </div>
                        <span class="status ${statusClass}">${statusText}</span>
                    </div>
                `;
            } else {
                container.innerHTML = '<p>통합 테스트 결과가 없습니다.</p>';
            }
        }
        
        // E2E 테스트 렌더링
        function renderE2ETests() {
            const container = document.getElementById('e2e-tests');
            const data = testData.e2e;
            
            if (data && data.status) {
                const statusClass = data.status;
                const statusText = statusClass === 'passed' ? '통과' : statusClass === 'failed' ? '실패' : '미실행';
                const logPath = data.log || '';
                
                container.innerHTML = `
                    <div class="test-item ${statusClass}">
                        <div style="flex: 1;">
                            <strong>E2E 테스트</strong>
                            ${logPath ? `<div style="margin-top: 5px;"><a href="${logPath}" class="log-link" target="_blank">로그 보기</a></div>` : ''}
                        </div>
                        <span class="status ${statusClass}">${statusText}</span>
                    </div>
                `;
            } else {
                container.innerHTML = '<p>E2E 테스트 결과가 없습니다.</p>';
            }
        }
        
        // 초기화
        renderSummary();
        renderUnitTests();
        renderIntegrationTests();
        renderE2ETests();
    </script>
</body>
</html>
HTML_FOOT

echo "  ✅ HTML 보고서 생성 완료: $REPORT_DIR/index.html"
echo ""

# 커버리지 리포트 수집
echo "📊 커버리지 리포트 수집 중..."
COVERAGE_DIR="$REPORT_DIR/coverage"
mkdir -p "$COVERAGE_DIR"

for service in api-gateway auth-service user-service product-service order-service payment-service; do
  SERVICE_DIR="$PROJECT_ROOT/backend/$service"
  COVERAGE_SRC="$SERVICE_DIR/coverage"
  
  if [ -d "$COVERAGE_SRC" ]; then
    echo "  → $service 커버리지 복사 중..."
    cp -r "$COVERAGE_SRC" "$COVERAGE_DIR/$service" 2>/dev/null || true
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 테스트 보고서 생성 완료"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📁 보고서 위치:"
echo "    - HTML 보고서: $REPORT_DIR/index.html"
echo "    - 커버리지: $COVERAGE_DIR/"
echo ""
echo "  🌐 보고서 열기:"
echo "    npm run test:view"
echo "    또는"
echo "    open $REPORT_DIR/index.html"
echo ""
