# PG사 심사를 위한 화면 캡처 가이드

## 캡처 준비사항

### 1. 테스트 계정 준비
- **테스트 계정 정보**:
  - 이메일: test@example.com
  - 비밀번호: Test1234!
  - (또는 실제 사용 중인 테스트 계정)

### 2. 테스트 상품 준비
- 장바구니에 상품 1~2개 추가된 상태
- 결제 금액: 10,000원 ~ 50,000원 권장

### 3. 배송지 정보 준비
- 수령인 이름
- 전화번호
- 우편번호
- 주소 및 상세주소

---

## 캡처해야 할 화면 체크리스트

### STEP 1: 로그인 화면 ✅
**파일 위치**: `user-app/lib/screens/login_screen.dart`

**캡처 포인트**:
- [ ] 로그인 화면 전체
  - 앱 로고
  - 이메일 입력 필드
  - 비밀번호 입력 필드
  - 로그인 버튼

**캡처 타이밍**: 앱 실행 직후

---

### STEP 2: 홈 화면 (로그인 성공 후) ✅
**파일 위치**: `user-app/lib/screens/home_screen.dart`

**캡처 포인트**:
- [ ] 홈 화면 전체
  - 상단 배너/헤더
  - 상품 목록
  - 하단 네비게이션 바
  - 사용자 로그인 상태 확인 (프로필 아이콘 등)

**캡처 타이밍**: 로그인 성공 직후

---

### STEP 3: 상품 목록 화면 ✅
**파일 위치**: `user-app/lib/screens/product_list_screen.dart`

**캡처 포인트**:
- [ ] 상품 목록 화면
  - 카테고리별 상품 표시
  - 상품 카드 (이미지, 이름, 가격)
  - 정렬/필터 옵션 (있는 경우)

**캡처 타이밍**: 카테고리 선택 또는 전체 상품 조회 시

---

### STEP 4: 상품 상세 화면 ✅
**파일 위치**: `user-app/lib/screens/product_detail_screen.dart`

**캡처 포인트**:
- [ ] 상품 상세 화면
  - 상품 이미지
  - 상품명
  - 가격
  - 상품 설명
  - 수량 선택
  - **"장바구니 담기" 버튼**

**캡처 타이밍**: 상품 클릭 후 상세 화면 진입

---

### STEP 5: 장바구니 담기 완료 알림 ✅
**캡처 포인트**:
- [ ] 장바구니 담기 성공 메시지
  - SnackBar 또는 Toast 메시지
  - "장바구니에 담겼습니다" 등의 안내

**캡처 타이밍**: "장바구니 담기" 버튼 클릭 직후

---

### STEP 6: 장바구니 화면 ✅
**파일 위치**: `user-app/lib/screens/cart_screen.dart`

**캡처 포인트**:
- [ ] 장바구니 화면 전체
  - 장바구니에 담긴 상품 목록
  - 각 상품의 이미지, 이름, 가격, 수량
  - 수량 조절 버튼 (+/-)
  - 상품 삭제 버튼
  - **총 상품 금액** 표시
  - **총 배송비** 표시 (있는 경우)
  - **최종 결제 금액** 표시
  - **"결제하기" 버튼**

**캡처 타이밍**: 장바구니 화면 진입 시

---

### STEP 7: 결제/주문 화면 (Checkout) ✅ ⭐ 중요
**파일 위치**: `user-app/lib/screens/checkout_screen.dart`

**캡처 포인트**:
- [ ] **결제 화면 - 상단 부분**
  - 주문 상품 목록 요약
  - 각 상품의 이름, 수량, 가격

- [ ] **결제 화면 - 배송지 정보 입력**
  - 수령인 이름 입력 필드
  - 전화번호 입력 필드
  - 우편번호 입력 필드
  - 주소 입력 필드
  - 상세주소 입력 필드
  - (또는 저장된 배송지 선택)

- [ ] **결제 화면 - 포인트 사용 (선택)**
  - 사용 가능 포인트 표시
  - 포인트 사용 입력 필드
  - 최대 사용 가능 포인트 안내 (주문 금액의 50%)

- [ ] **결제 화면 - 결제 금액 요약**
  - 상품 금액
  - 배송비
  - 포인트 할인 (사용 시)
  - **최종 결제 금액** (강조 표시)

- [ ] **결제 화면 - 결제 버튼**
  - "KG 이니시스로 결제하기" 버튼 또는 "결제하기" 버튼

**캡처 타이밍**: "결제하기" 버튼 클릭 후 결제 화면 진입

**⚠️ 중요**: 이 화면은 여러 섹션으로 나누어 캡처해야 합니다.
- 캡처 1: 주문 상품 목록
- 캡처 2: 배송지 정보 (입력된 상태)
- 캡처 3: 포인트 사용 섹션 (사용하는 경우)
- 캡처 4: 결제 금액 요약 + 결제 버튼

---

### STEP 8: PG 결제 창 (KG 이니시스) ⭐⭐ 매우 중요
**캡처 포인트**:
- [ ] **PG 결제 창 - 초기 화면**
  - PG사 로고 (KG 이니시스)
  - 결제 금액 표시
  - 주문 정보 (상품명)

- [ ] **PG 결제 창 - 결제 수단 선택**
  - 신용카드
  - 체크카드
  - 계좌이체
  - 가상계좌
  - 간편결제 (카카오페이, 네이버페이 등)

- [ ] **PG 결제 창 - 카드 정보 입력** (카드 결제 선택 시)
  - 카드번호 입력 필드
  - 유효기간 입력 필드
  - CVC 입력 필드
  - 할부 선택 (일시불/할부)

- [ ] **PG 결제 창 - 결제 진행 중**
  - 로딩 화면 또는 "결제 처리 중" 메시지

- [ ] **PG 결제 창 - 결제 완료**
  - "결제가 완료되었습니다" 메시지
  - 거래번호 (Transaction ID)
  - 승인번호

**캡처 타이밍**:
- 결제 창이 열린 직후부터 결제 완료까지 각 단계별로 캡처

**⚠️ 중요**:
- PG 결제 창은 별도의 웹뷰 또는 팝업 창으로 열립니다.
- 실제 결제를 진행하거나 테스트 결제 모드를 사용해야 합니다.
- 테스트 모드에서는 가짜 카드번호를 사용할 수 있습니다.

---

### STEP 9: 주문 완료 화면 ✅
**캡처 포인트**:
- [ ] **주문 완료 안내**
  - "주문이 완료되었습니다" 메시지
  - 주문번호 (Order ID)
  - 결제 금액

- [ ] **주문 내역 확인 버튼**
  - "주문 내역 보기" 또는 "주문 상세" 버튼
  - "홈으로 돌아가기" 버튼

**캡처 타이밍**: 결제 완료 후 앱으로 리턴된 직후

---

### STEP 10: 주문 내역 화면 ✅
**파일 위치**: `user-app/lib/screens/order_list_screen.dart` 또는 `order_detail_screen.dart`

**캡처 포인트**:
- [ ] **주문 목록 화면**
  - 주문 번호
  - 주문 날짜
  - 주문 상품 (이미지, 이름)
  - 주문 금액
  - 주문 상태 (결제 완료, 배송 준비 중 등)

- [ ] **주문 상세 화면**
  - 주문 번호
  - 주문 날짜 및 시간
  - 주문 상품 목록
  - 배송지 정보
  - 결제 정보 (결제 방법, 결제 금액)
  - 주문 상태

**캡처 타이밍**: 마이페이지 → 주문내역 메뉴 선택 시

---

## 추가 캡처 권장 사항

### 옵션 1: 결제 수단별 캡처 (가능한 경우)
- [ ] 신용카드 결제
- [ ] 체크카드 결제
- [ ] 계좌이체
- [ ] 카카오페이
- [ ] 네이버페이

### 옵션 2: 에러 케이스 캡처
- [ ] 결제 실패 화면
- [ ] 잔액 부족 안내
- [ ] 네트워크 오류 안내

---

## 캡처 방법 안내

### iOS 기기 (iPhone/iPad)
1. **스크린샷**: 전원 버튼 + 볼륨 업 버튼 동시 누르기
2. **화면 녹화**: 제어 센터 → 화면 기록 버튼

### Android 기기
1. **스크린샷**: 전원 버튼 + 볼륨 다운 버튼 동시 누르기
2. **화면 녹화**:
   - Android 11 이상: 빠른 설정 → 화면 녹화
   - Android 10 이하: 서드파티 앱 사용 (AZ Screen Recorder 등)

### 에뮬레이터 (Android Studio / iOS Simulator)
1. **스크린샷**:
   - Android Studio: 에뮬레이터 우측 툴바 → 카메라 아이콘
   - iOS Simulator: Cmd + S
2. **화면 녹화**:
   - macOS: QuickTime Player 사용

---

## 캡처 파일 정리 방법

### 파일명 규칙
```
01_login_screen.png
02_home_screen.png
03_product_list_screen.png
04_product_detail_screen.png
05_cart_add_confirmation.png
06_cart_screen.png
07_checkout_screen_order_summary.png
08_checkout_screen_shipping_info.png
09_checkout_screen_points.png
10_checkout_screen_payment_summary.png
11_pg_payment_window_initial.png
12_pg_payment_window_method_selection.png
13_pg_payment_window_card_input.png
14_pg_payment_window_processing.png
15_pg_payment_window_complete.png
16_order_complete_screen.png
17_order_list_screen.png
18_order_detail_screen.png
```

### 폴더 구조
```
PG_Review_Captures/
├── 01_Login/
│   └── 01_login_screen.png
├── 02_Home/
│   └── 02_home_screen.png
├── 03_Product_Browsing/
│   ├── 03_product_list_screen.png
│   └── 04_product_detail_screen.png
├── 04_Cart/
│   ├── 05_cart_add_confirmation.png
│   └── 06_cart_screen.png
├── 05_Checkout/
│   ├── 07_checkout_screen_order_summary.png
│   ├── 08_checkout_screen_shipping_info.png
│   ├── 09_checkout_screen_points.png
│   └── 10_checkout_screen_payment_summary.png
├── 06_PG_Payment/
│   ├── 11_pg_payment_window_initial.png
│   ├── 12_pg_payment_window_method_selection.png
│   ├── 13_pg_payment_window_card_input.png
│   ├── 14_pg_payment_window_processing.png
│   └── 15_pg_payment_window_complete.png
└── 07_Order_Confirmation/
    ├── 16_order_complete_screen.png
    ├── 17_order_list_screen.png
    └── 18_order_detail_screen.png
```

---

## PG사 심사 체크포인트

### 필수 확인 사항
- [x] 사업자 정보가 올바르게 표시되는가?
- [x] 상품명과 가격이 정확하게 표시되는가?
- [x] 최종 결제 금액이 명확하게 표시되는가?
- [x] 배송지 정보 입력이 정상적으로 동작하는가?
- [x] PG 결제 창이 정상적으로 열리는가?
- [x] 결제 완료 후 주문 정보가 저장되는가?
- [x] 사용자가 주문 내역을 확인할 수 있는가?

### 보안 요구사항
- [x] HTTPS 통신을 사용하는가?
- [x] 카드 정보가 암호화되어 전송되는가?
- [x] 개인정보 취급 동의 절차가 있는가? (필요 시)

### 사용자 경험
- [x] 결제 흐름이 직관적인가?
- [x] 에러 상황에 대한 안내가 명확한가?
- [x] 로딩 상태가 적절히 표시되는가?

---

## 참고: 현재 구현된 결제 플로우

```
1. 사용자 로그인
   ↓
2. 상품 탐색 및 선택
   ↓
3. 장바구니에 담기
   ↓
4. 장바구니 확인
   ↓
5. 결제하기 버튼 클릭
   ↓
6. 주문/결제 화면 (CheckoutScreen)
   - 배송지 정보 입력/선택
   - 포인트 사용 (선택)
   - 결제 금액 확인
   ↓
7. KG 이니시스 결제 창 열림
   - 결제 수단 선택
   - 카드 정보 입력
   - 결제 진행
   ↓
8. 결제 완료 처리
   - 주문 생성 (Order Service)
   - 결제 기록 생성 (Payment Service)
   - 포인트 차감 (사용한 경우)
   - 장바구니 비우기
   ↓
9. 주문 완료 화면
   ↓
10. 주문 내역 확인
```

---

## 테스트 실행 전 체크리스트

### 백엔드 서비스 확인
```bash
# Docker 컨테이너 실행 확인
docker-compose ps

# 필요 시 서비스 재시작
docker-compose up -d
```

### 데이터베이스 확인
```bash
# PostgreSQL 연결 확인
PGPASSWORD=postgres123 psql -h localhost -U postgres -d user_db -c "SELECT COUNT(*) FROM users;"

# 테스트 사용자 확인
PGPASSWORD=postgres123 psql -h localhost -U postgres -d user_db -c "SELECT user_id, email, name FROM users WHERE email='test@example.com';"
```

### 테스트 상품 확인
```bash
# 상품 데이터 확인
PGPASSWORD=postgres123 psql -h localhost -U postgres -d product_db -c "SELECT COUNT(*) FROM products WHERE is_active=true;"
```

### 앱 실행
```bash
# user-app 디렉토리로 이동
cd user-app

# Flutter 의존성 설치
flutter pub get

# 앱 실행 (iOS)
flutter run

# 앱 실행 (Android)
flutter run
```

---

## 문제 해결 (Troubleshooting)

### 결제 창이 열리지 않는 경우
1. 네트워크 연결 확인
2. API Gateway 정상 작동 확인 (`curl http://localhost:3000/health`)
3. Payment Service 로그 확인 (`docker-compose logs payment-service`)

### 주문이 생성되지 않는 경우
1. Order Service 로그 확인 (`docker-compose logs order-service`)
2. 데이터베이스 연결 확인
3. 사용자 인증 토큰 확인

### 포인트 사용이 안 되는 경우
1. 사용자의 포인트 잔액 확인
2. 최대 사용 가능 금액 확인 (주문 금액의 50%)
3. User Service 로그 확인

---

## 연락처

PG사 심사 과정에서 추가 자료가 필요하거나 질문이 있는 경우:
- 기술 지원: [담당자 이메일]
- 사업자 정보: [사업자등록번호]

---

**작성일**: 2025-12-27
**마지막 업데이트**: 2025-12-27
