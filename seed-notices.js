const axios = require('axios');

// Admin user ID (dummy for seeding)
const ADMIN_ID = '00000000-0000-0000-0000-000000000001';

const notices = [
  {
    title: '🎉 DOA 마켓 오픈 기념 이벤트',
    content: `DOA 마켓 오픈을 축하합니다!

오픈 기념으로 전 상품 20% 할인 이벤트를 진행합니다.

기간: 2025년 1월 1일 ~ 1월 31일
대상: 전 상품
할인율: 20%

많은 관심 부탁드립니다!`,
    category: '이벤트',
    priority: 'normal',
    isPinned: true,
    status: 'published',
  },
  {
    title: '설 연휴 배송 일정 안내',
    content: `설 연휴 기간 배송 일정을 안내드립니다.

연휴 기간: 2025년 1월 28일 ~ 2월 2일
- 1월 27일 오후 3시 이후 주문건은 2월 3일부터 순차 발송됩니다.
- 연휴 기간 중 고객센터 운영이 제한될 수 있습니다.

고객 여러분의 양해 부탁드립니다.`,
    category: '공지',
    priority: 'urgent',
    isPinned: true,
    status: 'published',
  },
  {
    title: '개인정보 처리방침 개정 안내',
    content: `개인정보 처리방침이 2025년 1월 15일자로 개정되었습니다.

주요 변경사항:
- 개인정보 보관 기간 명시
- 제3자 제공 항목 추가
- 개인정보 열람 요청 절차 간소화

자세한 내용은 마이페이지 > 개인정보 처리방침에서 확인하실 수 있습니다.`,
    category: '공지',
    priority: 'normal',
    isPinned: false,
    status: 'published',
  },
  {
    title: '서버 정기 점검 안내',
    content: `보다 나은 서비스 제공을 위해 정기 점검을 실시합니다.

일시: 2025년 1월 10일 새벽 2시 ~ 6시 (4시간)
영향: 점검 시간 동안 일시적으로 서비스 이용이 불가능합니다.

점검 완료 후 더욱 안정적인 서비스로 찾아뵙겠습니다.`,
    category: '점검',
    priority: 'urgent',
    isPinned: false,
    status: 'published',
  },
  {
    title: '모바일 앱 v2.0 업데이트',
    content: `모바일 앱이 v2.0으로 업데이트되었습니다.

주요 업데이트 내용:
- 새로운 UI/UX 디자인 적용
- 상품 검색 기능 개선
- 위시리스트 기능 추가
- 성능 최적화

앱스토어에서 업데이트하시고 새로운 기능을 만나보세요!`,
    category: '업데이트',
    priority: 'normal',
    isPinned: false,
    status: 'published',
  },
  {
    title: '겨울 시즌 특별 할인 이벤트',
    content: `추운 겨울, 따뜻한 혜택을 드립니다!

이벤트 기간: 2025년 1월 5일 ~ 1월 20일
대상 카테고리: 의류, 가전제품
할인율: 최대 30%

회원 등급별 추가 할인 혜택도 제공됩니다!`,
    category: '이벤트',
    priority: 'normal',
    isPinned: false,
    status: 'published',
  },
  {
    title: '신규 결제 수단 추가 안내',
    content: `더욱 편리한 결제를 위해 새로운 결제 수단을 추가했습니다.

추가된 결제 수단:
- 카카오페이
- 네이버페이
- 토스페이

간편 결제로 더 빠르고 안전하게 결제하세요!`,
    category: '업데이트',
    priority: 'normal',
    isPinned: false,
    status: 'published',
  },
  {
    title: '포인트 적립 정책 변경 안내',
    content: `포인트 적립 정책이 변경됩니다.

변경 시행일: 2025년 2월 1일

변경 내용:
- 기본 적립률: 1% → 2%
- VIP 회원 적립률: 3% → 5%
- 포인트 유효기간: 6개월 → 12개월

더 많은 혜택을 받으실 수 있습니다!`,
    category: '공지',
    priority: 'normal',
    isPinned: false,
    status: 'published',
  },
];

async function seedNotices() {
  console.log('공지사항 데이터 추가 시작...\n');

  try {
    for (const notice of notices) {
      try {
        const response = await axios.post(
          'http://localhost:3014/api/v1/admin/notices',
          { ...notice, createdBy: ADMIN_ID },
          {
            headers: {
              'Content-Type': 'application/json',
            },
          }
        );

        if (response.status === 201) {
          console.log(`✓ ${notice.title} - 추가 완료`);
        }
      } catch (error) {
        console.error(`✗ ${notice.title} - 추가 실패:`, error.response?.data?.message || error.message);
      }
    }

    console.log(`\n총 ${notices.length}개의 공지사항 처리 완료!`);
  } catch (error) {
    console.error('오류 발생:', error.message);
  }
}

seedNotices();
