# Admin Dashboard 리뉴얼 설치 가이드

## 📦 패키지 설치

```bash
cd /Users/krystal/workspace/doa-market/frontend/admin-web

# 패키지 설치
npm install

# 또는 기존 패키지 제거 후 재설치
rm -rf node_modules package-lock.json
npm install
```

## 🚀 실행

```bash
npm run dev
```

브라우저에서 http://localhost:3100 접속

## 🎨 주요 변경사항

### 1. Material-UI 기반 디자인
- **Tailwind CSS** → **Material-UI v7**
- 더 세련되고 현대적인 UI
- 일관된 디자인 시스템

### 2. 로그인 페이지
- 그라디언트 배경
- 부드러운 애니메이션
- 향상된 UX
- 비밀번호 표시/숨김 토글
- 테스트 계정 자동 입력

### 3. 테마 시스템
- Minimal 템플릿 컬러 팔레트
- 다크모드 준비
- 커스텀 그림자 효과
- 일관된 타이포그래피

## 📋 체크리스트

- [x] Material-UI 설치
- [x] 로그인 페이지 리뉴얼
- [x] 테마 설정
- [ ] 대시보드 레이아웃
- [ ] 사이드바 네비게이션
- [ ] 헤더 컴포넌트
- [ ] 대시보드 위젯

## 🎯 다음 단계

1. 대시보드 레이아웃 구축
2. 네비게이션 메뉴 추가
3. 대시보드 위젯 구현
4. 데이터 테이블 통합

## 🔧 문제 해결

### Material-UI 타입 에러
```bash
npm install --save-dev @types/react @types/react-dom
```

### 빌드 오류
```bash
npm run build
```

### 캐시 정리
```bash
rm -rf .next
npm run dev
```

## 📸 스크린샷

### Before (Tailwind CSS)
- 기본적인 로그인 폼
- 단순한 디자인

### After (Material-UI)
- 그라디언트 배경
- 세련된 카드 디자인
- 부드러운 그림자 효과
- 향상된 인터랙션

## 🎨 컬러 팔레트

### Primary (Green)
- Main: #00A76F
- Light: #5BE49B
- Dark: #007867

### Secondary (Purple)
- Main: #8E33FF
- Light: #C684FF
- Dark: #5119B7

### Info (Cyan)
- Main: #00B8D9
- Light: #61F3F3
- Dark: #006C9C

### Success (Green)
- Main: #36B37E
- Light: #86E8AB
- Dark: #1B806A

## 📚 참고 자료

- [Material-UI Docs](https://mui.com/)
- [Minimal UI Kit](https://minimals.cc/)
- [Next.js 15](https://nextjs.org/)

