#!/bin/bash

# DOA Market 사용자 앱 E2E 테스트 실행 스크립트
# 작성일: 2025-12-27

set -e

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  DOA Market E2E 테스트 실행${NC}"
echo -e "${BLUE}========================================${NC}\n"

# 디바이스 선택
echo -e "${YELLOW}📱 사용 가능한 디바이스:${NC}"
flutter devices

echo -e "\n${YELLOW}디바이스 ID를 입력하세요 (예: apple_ios_simulator):${NC}"
read DEVICE_ID

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ 디바이스 ID가 입력되지 않았습니다.${NC}"
    exit 1
fi

# 테스트 결과 디렉토리 생성
REPORT_DIR="test_reports"
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORT_DIR/e2e_test_report_$TIMESTAMP.txt"
HTML_REPORT="$REPORT_DIR/e2e_test_report_$TIMESTAMP.html"

echo -e "${GREEN}✅ 테스트 보고서 저장 위치: $REPORT_FILE${NC}\n"

# HTML 보고서 헤더 생성
cat > "$HTML_REPORT" << 'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DOA Market E2E 테스트 보고서</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 30px;
        }
        .test-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .summary-card {
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .summary-card.success {
            background: #d4edda;
            border: 2px solid #28a745;
        }
        .summary-card.fail {
            background: #f8d7da;
            border: 2px solid #dc3545;
        }
        .summary-card.total {
            background: #d1ecf1;
            border: 2px solid #17a2b8;
        }
        .summary-card h3 {
            margin: 0;
            font-size: 2em;
            color: #2c3e50;
        }
        .summary-card p {
            margin: 5px 0 0 0;
            color: #666;
        }
        .test-item {
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid #3498db;
            background: #f8f9fa;
            border-radius: 4px;
        }
        .test-item.pass {
            border-left-color: #28a745;
        }
        .test-item.fail {
            border-left-color: #dc3545;
        }
        .timestamp {
            color: #666;
            font-size: 0.9em;
        }
        pre {
            background: #f4f4f4;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 DOA Market E2E 테스트 보고서</h1>
        <p class="timestamp">생성일시: TIMESTAMP_PLACEHOLDER</p>

        <div class="test-summary">
            <div class="summary-card total">
                <h3 id="total-tests">0</h3>
                <p>전체 테스트</p>
            </div>
            <div class="summary-card success">
                <h3 id="passed-tests">0</h3>
                <p>성공</p>
            </div>
            <div class="summary-card fail">
                <h3 id="failed-tests">0</h3>
                <p>실패</p>
            </div>
        </div>

        <h2>📋 테스트 결과 상세</h2>
        <div id="test-results">
EOF

sed -i '' "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/" "$HTML_REPORT"

# 테스트 파일 목록
TESTS=(
    "app_flow_test.dart:앱 기본 플로우"
    "mypage_flow_test.dart:마이페이지 플로우"
    "product_exploration_test.dart:상품 탐색 플로우"
    "purchase_flow_test.dart:구매 플로우"
    "review_flow_test.dart:리뷰 작성 및 조회"
    "point_checkin_flow_test.dart:포인트 및 출석체크"
    "notice_inquiry_flow_test.dart:공지사항 및 문의"
    "order_cancel_return_flow_test.dart:주문 취소 및 반품"
)

TOTAL_TESTS=${#TESTS[@]}
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}========================================${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}  테스트 실행 시작${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}========================================${NC}\n" | tee -a "$REPORT_FILE"

# 각 테스트 실행
for TEST_INFO in "${TESTS[@]}"; do
    IFS=':' read -r TEST_FILE TEST_NAME <<< "$TEST_INFO"

    echo -e "${YELLOW}🔄 실행 중: $TEST_NAME${NC}" | tee -a "$REPORT_FILE"

    if flutter test "integration_test/$TEST_FILE" -d "$DEVICE_ID" >> "$REPORT_FILE" 2>&1; then
        echo -e "${GREEN}✅ 성공: $TEST_NAME${NC}\n" | tee -a "$REPORT_FILE"
        PASSED_TESTS=$((PASSED_TESTS + 1))

        # HTML 보고서에 추가
        cat >> "$HTML_REPORT" << EOF
            <div class="test-item pass">
                <h3>✅ $TEST_NAME</h3>
                <p>파일: $TEST_FILE</p>
                <p>상태: <strong style="color: #28a745;">성공</strong></p>
            </div>
EOF
    else
        echo -e "${RED}❌ 실패: $TEST_NAME${NC}\n" | tee -a "$REPORT_FILE"
        FAILED_TESTS=$((FAILED_TESTS + 1))

        # HTML 보고서에 추가
        cat >> "$HTML_REPORT" << EOF
            <div class="test-item fail">
                <h3>❌ $TEST_NAME</h3>
                <p>파일: $TEST_FILE</p>
                <p>상태: <strong style="color: #dc3545;">실패</strong></p>
                <p>자세한 내용은 텍스트 보고서를 확인하세요.</p>
            </div>
EOF
    fi
done

# HTML 보고서 마무리
cat >> "$HTML_REPORT" << EOF
        </div>
    </div>

    <script>
        document.getElementById('total-tests').textContent = '$TOTAL_TESTS';
        document.getElementById('passed-tests').textContent = '$PASSED_TESTS';
        document.getElementById('failed-tests').textContent = '$FAILED_TESTS';
    </script>
</body>
</html>
EOF

# 최종 결과 출력
echo -e "\n${BLUE}========================================${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}  테스트 결과 요약${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}========================================${NC}\n" | tee -a "$REPORT_FILE"

echo -e "전체 테스트: ${BLUE}$TOTAL_TESTS${NC}" | tee -a "$REPORT_FILE"
echo -e "성공: ${GREEN}$PASSED_TESTS${NC}" | tee -a "$REPORT_FILE"
echo -e "실패: ${RED}$FAILED_TESTS${NC}" | tee -a "$REPORT_FILE"

echo -e "\n${GREEN}✅ 테스트 보고서 생성 완료!${NC}"
echo -e "📄 텍스트 보고서: $REPORT_FILE"
echo -e "🌐 HTML 보고서: $HTML_REPORT"

# HTML 보고서 자동 열기
echo -e "\n${YELLOW}HTML 보고서를 여시겠습니까? (y/n)${NC}"
read OPEN_REPORT

if [ "$OPEN_REPORT" = "y" ] || [ "$OPEN_REPORT" = "Y" ]; then
    open "$HTML_REPORT"
    echo -e "${GREEN}✅ 브라우저에서 보고서를 열었습니다.${NC}"
fi

# 종료 코드 반환
if [ $FAILED_TESTS -gt 0 ]; then
    exit 1
else
    exit 0
fi
