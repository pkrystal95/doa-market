# Flutter 앱 개발 계획

## 📋 작업 우선순위

### ✅ 1단계: CartScreen과 HomeScreen 카테고리 탭 업데이트 → 기본 쇼핑 플로우 완성

#### 완료된 작업:

- ✅ HomeScreen에 카테고리 탭 추가 및 카테고리별 상품 필터링 기능 구현
- ✅ CartScreen UI 개선 및 장바구니 아이템 수정/삭제 기능 강화
- ✅ 카테고리 Provider 연동 완료
- ✅ 카테고리 선택 시 상품 목록 표시 기능 구현

#### 진행 중:

- 🔄 기본 쇼핑 플로우 검증: 홈 → 상품 상세 → 장바구니 → 체크아웃 플로우

#### 구현 내용:

1. **HomeScreen 카테고리 탭**

   - 카테고리 목록을 그리드로 표시
   - 카테고리 선택 시 해당 카테고리의 상품 목록 표시
   - 뒤로가기 버튼으로 카테고리 목록으로 복귀
   - 카테고리 Provider와 연동

2. **CartScreen 개선**
   - 수량 조절 UI 개선 (컨테이너 스타일 적용)
   - 수량이 1일 때 감소 버튼 클릭 시 삭제 확인 다이얼로그
   - 재고 정보 표시
   - 전체 삭제 기능 유지

---

### 📝 2단계: 주소 관리 화면 추가 → 체크아웃 개선

#### 예정 작업:

- [ ] 주소 관리 화면(AddressManagementScreen) 생성 및 CRUD 기능 구현
- [ ] 체크아웃 화면에 주소 선택 기능 통합
- [ ] 체크아웃 플로우 개선: 주소 선택 → 결제 수단 선택 → 주문 확인

#### 필요한 파일:

- `lib/screens/address_management_screen.dart` (신규 생성)
- `lib/screens/checkout_screen.dart` (수정)
- AddressProvider는 이미 구현됨 ✅

---

### 📝 3단계: 주문 내역 및 MyPage 기능 완성

#### 예정 작업:

- [ ] 주문 내역 화면(OrderHistoryScreen) 구현 및 주문 상세 조회 기능
- [ ] MyPage 화면 기능 완성: 프로필 수정, 주문 내역, 찜 목록, 설정 등

#### 필요한 파일:

- `lib/screens/order_history_screen.dart` (신규 생성)
- `lib/screens/order_detail_screen.dart` (신규 생성)
- `lib/screens/my_page_screen.dart` (수정)
- `lib/providers/order_provider.dart` (신규 생성 필요)

---

## 🎯 현재 상태

### 완료된 기능:

- ✅ 인증 (로그인/회원가입)
- ✅ 상품 목록 조회
- ✅ 상품 상세 조회
- ✅ 장바구니 기본 기능
- ✅ 찜 목록 기능
- ✅ 카테고리 조회 및 필터링
- ✅ 주소 Provider (백엔드 연동 준비 완료)

### 진행 중:

- 🔄 기본 쇼핑 플로우 검증

### 다음 단계:

1. 주소 관리 화면 구현
2. 체크아웃 화면 개선
3. 주문 내역 화면 구현
4. MyPage 기능 완성

---

## 📁 파일 구조

```
user-app/lib/
├── screens/
│   ├── home_screen.dart ✅ (카테고리 탭 추가 완료)
│   ├── cart_screen.dart ✅ (UI 개선 완료)
│   ├── checkout_screen.dart (주소 선택 기능 추가 필요)
│   ├── my_page_screen.dart (주문 내역 연동 필요)
│   ├── address_management_screen.dart (신규 생성 필요)
│   ├── order_history_screen.dart (신규 생성 필요)
│   └── order_detail_screen.dart (신규 생성 필요)
├── providers/
│   ├── category_provider.dart ✅
│   ├── address_provider.dart ✅
│   ├── cart_provider.dart ✅
│   └── order_provider.dart (신규 생성 필요)
└── models/
    ├── category.dart ✅
    ├── address.dart ✅
    └── order.dart ✅
```

---

## 🚀 실행 방법

```bash
# Flutter 앱 실행
cd user-app
flutter run

# 특정 화면 테스트
flutter test
```

---

## 📝 참고사항

- API Gateway URL: `http://localhost:3000/api/v1`
- 모든 API 요청은 API Gateway를 통해 라우팅됨
- 인증 토큰은 AuthProvider에서 관리
- 상태 관리는 Provider 패턴 사용
