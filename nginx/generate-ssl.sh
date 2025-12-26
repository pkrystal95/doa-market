#!/bin/bash

# SSL 인증서 생성 스크립트
# 개발 환경용 자체 서명 인증서 생성

SSL_DIR="./ssl"

echo "=== DOA Market SSL 인증서 생성 ==="
echo ""

# SSL 디렉토리 생성
mkdir -p $SSL_DIR

# 자체 서명 인증서 생성
echo "1. 자체 서명 SSL 인증서 생성 중..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $SSL_DIR/key.pem \
    -out $SSL_DIR/cert.pem \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=DOA Market/OU=Development/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:192.168.0.19"

if [ $? -eq 0 ]; then
    echo "✅ SSL 인증서 생성 완료!"
    echo ""
    echo "생성된 파일:"
    echo "  - $SSL_DIR/cert.pem (인증서)"
    echo "  - $SSL_DIR/key.pem (개인키)"
    echo ""
    echo "인증서 정보:"
    openssl x509 -in $SSL_DIR/cert.pem -text -noout | grep -A 2 "Subject:"
    echo ""
    echo "⚠️  주의사항:"
    echo "  - 이 인증서는 개발 환경용 자체 서명 인증서입니다."
    echo "  - 프로덕션 환경에서는 신뢰할 수 있는 CA의 인증서를 사용하세요."
    echo "  - Let's Encrypt를 사용하려면 certbot을 사용하세요."
    echo ""
    echo "iOS 시뮬레이터/디바이스에서 사용하려면:"
    echo "  1. Settings > General > About > Certificate Trust Settings"
    echo "  2. 인증서를 신뢰할 수 있는 루트 인증서로 추가"
    echo ""
else
    echo "❌ SSL 인증서 생성 실패!"
    exit 1
fi

# 권한 설정
chmod 600 $SSL_DIR/key.pem
chmod 644 $SSL_DIR/cert.pem

echo "✅ 완료!"
