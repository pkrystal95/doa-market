# 마이페이지 기능 추가 완료

오픈마켓처럼 실제 서비스 수준의 마이페이지 기능이 구현되었습니다.

## 새로 추가된 백엔드 서비스

### 1. 포인트/적립금 서비스 (Port 3016)
- **위치**: `backend/services/point-service/`
- **기능**:
  - 포인트 적립 (구매, 리뷰, 이벤트 등)
  - 포인트 사용 및 환불
  - 거래 내역 조회
  - 만료 예정 포인트 조회
  - 자동 포인트 만료 처리

### 2. 1:1 문의 서비스 (Port 3017)
- **위치**: `backend/services/inquiry-service/`
- **기능**:
  - 고객 1:1 문의 작성
  - 관리자 답변
  - 문의 타입별 분류 (상품, 주문, 배송, 결제, 환불 등)
  - 우선순위 관리
  - 문의 통계

### 3. 최근 본 상품 서비스 (Port 3018)
- **위치**: `backend/services/recently-viewed-service/`
- **기능**:
  - 상품 조회 추적
  - 조회 횟수 카운팅
  - 상품 정보 캐싱
  - 사용자별 최대 100개 자동 관리
  - 상품별 조회 통계
  - 사용자 관심 분석 (추천 시스템용)

### 4. 상품 Q&A 서비스 (Port 3019)
- **위치**: `backend/services/product-qna-service/`
- **기능**:
  - 상품 문의 작성 (공개/비밀글)
  - 판매자 답변
  - 도움이 됐어요 기능
  - 문의 통계

### 5. 배송지 관리 서비스 (Port 3020)
- **위치**: `backend/services/address-service/`
- **기능**:
  - 다중 배송지 관리 (최대 10개)
  - 기본 배송지 설정
  - 배송 요청사항 저장
  - 공동현관 비밀번호 저장
  - 마지막 사용 시간 추적

### 6. 사용자 등급/멤버십 시스템
- **위치**: `backend/services/user-service/src/models/UserTier.ts`
- **기능**:
  - 6단계 등급 시스템 (Bronze, Silver, Gold, Platinum, Diamond, VIP)
  - 구매 금액 및 주문 수 기반 자동 승급
  - 등급별 혜택 (할인율, 적립률, 무료배송 등)
  - 다음 등급까지 진행률 표시
  - 등급 변경 히스토리

### 7. 사용자 활동 내역 및 통계
- **위치**: `backend/services/user-service/src/models/UserActivity.ts`
- **기능**:
  - 모든 사용자 활동 로깅
  - 구매 통계 (총 주문 수, 총 구매액, 평균 주문액)
  - 상품 활동 (조회, 좋아요, 찜)
  - 리뷰 및 문의 통계
  - 기간별 활동 통계
  - 최근 활동 요약

## Flutter 앱 마이페이지 UI

### 위치
`user-app/lib/screens/my_page_screen.dart`

### 주요 섹션
1. **사용자 프로필**
   - 프로필 이미지
   - 이름 및 이메일
   - 프로필 편집

2. **등급 및 포인트**
   - 현재 등급 표시
   - 적립금 잔액
   - 터치하여 상세 정보 확인

3. **주문 관리**
   - 결제대기, 배송중, 배송완료, 리뷰작성
   - 각 상태별 개수 표시
   - 전체 주문내역
   - 취소/반품/교환

4. **쇼핑 활동**
   - 찜한 상품
   - 최근 본 상품
   - 내 리뷰
   - 내 상품문의

5. **고객센터**
   - 1:1 문의
   - 자주 묻는 질문
   - 공지사항

6. **설정**
   - 배송지 관리
   - 회원정보 수정
   - 알림 설정
   - 개인정보 처리방침
   - 로그아웃

## API 엔드포인트 요약

### 포인트 서비스
```
POST   /api/v1/points/earn                    # 포인트 적립
POST   /api/v1/points/use                     # 포인트 사용
GET    /api/v1/points/users/:userId           # 포인트 조회
GET    /api/v1/points/users/:userId/transactions  # 거래 내역
```

### 1:1 문의 서비스
```
POST   /api/v1/inquiries                      # 문의 작성
GET    /api/v1/inquiries/:id                  # 문의 조회
GET    /api/v1/inquiries/users/:userId        # 사용자 문의 목록
POST   /api/v1/inquiries/responses            # 답변 작성
```

### 최근 본 상품 서비스
```
POST   /api/v1/recently-viewed                # 조회 기록
GET    /api/v1/recently-viewed/users/:userId  # 최근 본 상품 목록
GET    /api/v1/recently-viewed/users/:userId/analysis  # 관심 분석
```

### 상품 Q&A 서비스
```
POST   /api/v1/product-qna                    # 문의 작성
GET    /api/v1/product-qna/products/:productId  # 상품별 문의
POST   /api/v1/product-qna/answer             # 답변 작성
POST   /api/v1/product-qna/helpful            # 도움이 됐어요
```

### 배송지 관리 서비스
```
POST   /api/v1/addresses                      # 배송지 추가
GET    /api/v1/addresses/users/:userId        # 배송지 목록
GET    /api/v1/addresses/users/:userId/default  # 기본 배송지
POST   /api/v1/addresses/:id/set-default      # 기본 배송지 설정
```

### 사용자 등급 서비스
```
GET    /api/v1/tiers/users/:userId            # 등급 조회
POST   /api/v1/tiers/update-stats             # 등급 통계 업데이트
GET    /api/v1/tiers/users/:userId/history    # 등급 변경 히스토리
```

### 사용자 활동 서비스
```
POST   /api/v1/activities/log                 # 활동 기록
GET    /api/v1/activities/users/:userId       # 활동 내역
GET    /api/v1/activities/users/:userId/statistics  # 통계 조회
GET    /api/v1/activities/users/:userId/recent-summary  # 최근 활동 요약
```

## 실행 방법

### 1. 백엔드 서비스 실행
각 서비스 디렉토리에서:
```bash
npm install
npm run dev
```

### 2. Flutter 앱 실행
```bash
cd user-app
flutter pub get
flutter run
```

## 환경 변수 설정

각 서비스의 `.env` 파일:
```
PORT=<서비스별 포트>
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=<서비스별_db>
NODE_ENV=development
```

## 데이터베이스

각 서비스는 독립적인 PostgreSQL 데이터베이스를 사용합니다:
- `point_service_db`
- `inquiry_service_db`
- `recently_viewed_db`
- `product_qna_db`
- `address_service_db`
- `doa_users` (등급, 활동 내역 포함)

## 주요 특징

1. **마이크로서비스 아키텍처**: 각 기능이 독립된 서비스로 분리
2. **실시간 통계**: 사용자 활동을 실시간으로 추적 및 집계
3. **자동 등급 관리**: 구매 내역에 따라 자동 승급/강등
4. **포인트 만료 관리**: 배치 작업을 통한 자동 만료 처리
5. **사용자 경험**: 실제 오픈마켓 수준의 UI/UX
6. **확장 가능성**: 새로운 기능 추가가 용이한 구조

## 다음 단계 개선 사항

1. 각 기능의 실제 API 연동
2. 실시간 알림 기능
3. 소셜 로그인 통합
4. 결제 모듈 통합
5. 추천 시스템 고도화
6. A/B 테스트 기능

