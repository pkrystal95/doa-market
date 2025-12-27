const { Client } = require('pg');
const crypto = require('crypto');

const client = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres123',
  database: 'doa_products'
});

const products = [
  // 전자제품
  {
    name: '무선 블루투스 이어폰',
    description: '고품질 사운드와 긴 배터리 수명을 자랑하는 무선 이어폰입니다.',
    price: 59000,
    originalPrice: 79000,
    categoryId: '11111111-1111-1111-1111-111111111111',
    stock: 50
  },
  {
    name: 'USB-C 고속 충전기',
    description: '빠른 충전 속도로 시간을 절약하는 고속 충전기입니다.',
    price: 25000,
    originalPrice: 35000,
    categoryId: '11111111-1111-1111-1111-111111111111',
    stock: 100
  },
  {
    name: '무선 마우스',
    description: '인체공학적 디자인의 무선 마우스로 장시간 사용해도 편안합니다.',
    price: 32000,
    originalPrice: 45000,
    categoryId: '11111111-1111-1111-1111-111111111111',
    stock: 75
  },

  // 패션/의류
  {
    name: '면 100% 기본 티셔츠',
    description: '부드럽고 편안한 착용감의 데일리 티셔츠입니다.',
    price: 19900,
    originalPrice: 29900,
    categoryId: '22222222-2222-2222-2222-222222222222',
    stock: 200
  },
  {
    name: '데님 청바지',
    description: '트렌디한 디자인의 편안한 핏 청바지입니다.',
    price: 49000,
    originalPrice: 69000,
    categoryId: '22222222-2222-2222-2222-222222222222',
    stock: 150
  },
  {
    name: '캐주얼 스니커즈',
    description: '가볍고 편안한 일상용 운동화입니다.',
    price: 65000,
    originalPrice: 89000,
    categoryId: '22222222-2222-2222-2222-222222222222',
    stock: 80
  },

  // 식품
  {
    name: '유기농 사과 (5kg)',
    description: '당도 높고 신선한 유기농 인증 사과입니다.',
    price: 35000,
    categoryId: '33333333-3333-3333-3333-333333333333',
    stock: 30
  },
  {
    name: '프리미엄 쌀 (10kg)',
    description: '밥맛이 좋은 프리미엄 등급 쌀입니다.',
    price: 45000,
    categoryId: '33333333-3333-3333-3333-333333333333',
    stock: 50
  },
  {
    name: '건강 견과류 믹스',
    description: '다양한 견과류를 한번에! 건강한 간식입니다.',
    price: 18000,
    originalPrice: 25000,
    categoryId: '33333333-3333-3333-3333-333333333333',
    stock: 100
  },

  // 생활용품
  {
    name: '주방 세제 세트',
    description: '기름때 제거에 탁월한 친환경 주방 세제입니다.',
    price: 12000,
    categoryId: '44444444-4444-4444-4444-444444444444',
    stock: 200
  },
  {
    name: '프리미엄 화장지 (30롤)',
    description: '부드럽고 튼튼한 3겹 화장지입니다.',
    price: 22000,
    originalPrice: 28000,
    categoryId: '44444444-4444-4444-4444-444444444444',
    stock: 150
  },
  {
    name: '섬유유연제',
    description: '은은한 향과 부드러운 촉감을 선사하는 섬유유연제입니다.',
    price: 8500,
    categoryId: '44444444-4444-4444-4444-444444444444',
    stock: 180
  },

  // 스포츠/레저
  {
    name: '요가 매트',
    description: '미끄럼 방지 기능이 있는 고급 요가 매트입니다.',
    price: 35000,
    originalPrice: 49000,
    categoryId: '55555555-5555-5555-5555-555555555555',
    stock: 60
  },
  {
    name: '덤벨 세트 (5kg x 2)',
    description: '홈트레이닝에 필수인 덤벨 세트입니다.',
    price: 42000,
    categoryId: '55555555-5555-5555-5555-555555555555',
    stock: 40
  },
  {
    name: '런닝화',
    description: '쿠션감이 좋은 전문 런닝화입니다.',
    price: 89000,
    originalPrice: 129000,
    categoryId: '55555555-5555-5555-5555-555555555555',
    stock: 70
  },

  // 도서
  {
    name: 'Clean Code (클린 코드)',
    description: '개발자 필독서, 깨끗한 코드 작성법을 배우는 책입니다.',
    price: 29700,
    categoryId: '66666666-6666-6666-6666-666666666666',
    stock: 50
  },
  {
    name: '경제학 콘서트',
    description: '일상 속 경제 원리를 쉽게 설명한 베스트셀러입니다.',
    price: 15000,
    categoryId: '66666666-6666-6666-6666-666666666666',
    stock: 80
  },
  {
    name: '어린 왕자',
    description: '전 세계인이 사랑하는 고전 명작 동화입니다.',
    price: 9900,
    categoryId: '66666666-6666-6666-6666-666666666666',
    stock: 100
  }
];

async function seedProducts() {
  try {
    await client.connect();
    console.log('✅ 데이터베이스 연결 완료\n');

    // 기존 상품 삭제
    await client.query('DELETE FROM products');
    console.log('🗑️  기존 상품 삭제 완료\n');

    console.log('📦 상품 생성 중...\n');

    for (const product of products) {
      const productId = crypto.randomUUID();
      const sellerId = crypto.randomUUID();
      const slug = `product-${productId.substring(0, 8)}`;
      const discountRate = product.originalPrice
        ? ((product.originalPrice - product.price) / product.originalPrice * 100).toFixed(2)
        : 0;

      await client.query(
        `INSERT INTO products
         (id, "sellerId", "categoryId", name, slug, description, price, "originalPrice",
          status, "stockQuantity", "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
        [
          productId,
          sellerId,
          product.categoryId,
          product.name,
          slug,
          product.description,
          product.price,
          product.originalPrice || product.price,
          'active',
          product.stock
        ]
      );

      console.log(`  ✓ ${product.name} (${product.price.toLocaleString()}원)`);
    }

    console.log(`\n✅ ${products.length}개의 상품 생성 완료!`);

  } catch (error) {
    console.error('❌ 에러 발생:', error);
  } finally {
    await client.end();
    console.log('\n✅ 데이터베이스 연결 종료');
  }
}

seedProducts();
