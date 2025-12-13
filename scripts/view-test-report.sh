#!/bin/bash

# DOA Market - 테스트 보고서 보기 스크립트

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
REPORT_DIR="$PROJECT_ROOT/test-reports"

# 보고서가 없으면 생성
if [ ! -f "$REPORT_DIR/index.html" ]; then
  echo "📊 테스트 보고서가 없습니다. 생성 중..."
  ./scripts/generate-test-report.sh
fi

# 보고서 열기
if command -v open &> /dev/null; then
  open "$REPORT_DIR/index.html"
  echo "✅ 보고서를 브라우저에서 열었습니다."
elif command -v xdg-open &> /dev/null; then
  xdg-open "$REPORT_DIR/index.html"
  echo "✅ 보고서를 브라우저에서 열었습니다."
else
  echo "📄 보고서 위치: $REPORT_DIR/index.html"
  echo "   브라우저에서 직접 열어주세요."
fi

echo ""
echo "📁 추가 파일:"
echo "   - 커버리지 리포트: $REPORT_DIR/coverage/"
echo "   - 테스트 로그: $PROJECT_ROOT/test-results/"

