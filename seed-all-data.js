const { Client } = require('pg');

// Database connections
const usersDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres',
  database: 'doa_users'
});

const sellersDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres',
  database: 'doa_sellers'
});

const productsDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres',
  database: 'doa_products'
});

// Category IDs (already created)
const categoryIds = {
  '전자제품': '11111111-1111-1111-1111-111111111111',
  '패션': '22222222-2222-2222-2222-222222222222',
  '식품': '33333333-3333-3333-3333-333333333333',
  '생활용품': '44444444-4444-4444-4444-444444444444',
  '스포츠': '55555555-5555-5555-5555-555555555555',
  '도서': '66666666-6666-6666-6666-666666666666'
};

// Seller data
const sellersData = [
  {
    id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    userId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    email: 'seller1@doamarket.com',
    name: '김테크',
    storeName: '테크월드',
    businessNumber: '123-45-67890'
  },
  {
    id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    userId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    email: 'seller2@doamarket.com',
    name: '이패션',
    storeName: '패션하우스',
    businessNumber: '234-56-78901'
  },
  {
    id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    userId: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
    email: 'seller3@doamarket.com',
    name: '박푸드',
    storeName: '신선마켓',
    businessNumber: '345-67-89012'
  },
  {
    id: '10101010-1010-1010-1010-101010101010',
    userId: '20202020-2020-2020-2020-202020202020',
    email: 'seller4@doamarket.com',
    name: '최생활',
    storeName: '라이프샵',
    businessNumber: '456-78-90123'
  },
  {
    id: '30303030-3030-3030-3030-303030303030',
    userId: '40404040-4040-4040-4040-404040404040',
    email: 'seller5@doamarket.com',
    name: '정스포츠',
    storeName: '스포츠존',
    businessNumber: '567-89-01234'
  }
];

// Products data
const productsData = [
  // 전자제품 (5개)
  { name: '무선 이어폰', price: 89000, stock: 50, categoryId: categoryIds['전자제품'], sellerId: sellersData[0].id },
  { name: '블루투스 스피커', price: 125000, stock: 30, categoryId: categoryIds['전자제품'], sellerId: sellersData[0].id },
  { name: 'USB 충전기', price: 25000, stock: 100, categoryId: categoryIds['전자제품'], sellerId: sellersData[0].id },
  { name: '노트북 거치대', price: 45000, stock: 40, categoryId: categoryIds['전자제품'], sellerId: sellersData[0].id },
  { name: 'HDMI 케이블 2M', price: 15000, stock: 80, categoryId: categoryIds['전자제품'], sellerId: sellersData[0].id },

  // 패션 (5개)
  { name: '면 티셔츠 (화이트)', price: 29000, stock: 150, categoryId: categoryIds['패션'], sellerId: sellersData[1].id },
  { name: '청바지 (슬림핏)', price: 79000, stock: 60, categoryId: categoryIds['패션'], sellerId: sellersData[1].id },
  { name: '운동화 (블랙)', price: 95000, stock: 45, categoryId: categoryIds['패션'], sellerId: sellersData[1].id },
  { name: '크로스백 (브라운)', price: 65000, stock: 35, categoryId: categoryIds['패션'], sellerId: sellersData[1].id },
  { name: '야구모자 (네이비)', price: 35000, stock: 70, categoryId: categoryIds['패션'], sellerId: sellersData[1].id },

  // 식품 (5개)
  { name: '유기농 사과 1kg', price: 12000, stock: 200, categoryId: categoryIds['식품'], sellerId: sellersData[2].id },
  { name: '무농약 쌀 10kg', price: 45000, stock: 50, categoryId: categoryIds['식품'], sellerId: sellersData[2].id },
  { name: '엑스트라버진 올리브유 500ml', price: 28000, stock: 80, categoryId: categoryIds['식품'], sellerId: sellersData[2].id },
  { name: '국산 야생화 꿀 500g', price: 35000, stock: 40, categoryId: categoryIds['식품'], sellerId: sellersData[2].id },
  { name: '혼합 견과류 300g', price: 18000, stock: 100, categoryId: categoryIds['식품'], sellerId: sellersData[2].id },

  // 생활용품 (5개)
  { name: '물티슈 10팩', price: 15000, stock: 120, categoryId: categoryIds['생활용품'], sellerId: sellersData[3].id },
  { name: '화장지 30롤', price: 22000, stock: 90, categoryId: categoryIds['생활용품'], sellerId: sellersData[3].id },
  { name: '주방세제 1L', price: 8000, stock: 150, categoryId: categoryIds['생활용품'], sellerId: sellersData[3].id },
  { name: '섬유유연제 2L', price: 12000, stock: 80, categoryId: categoryIds['생활용품'], sellerId: sellersData[3].id },
  { name: '칫솔 6개입', price: 9000, stock: 200, categoryId: categoryIds['생활용품'], sellerId: sellersData[3].id },

  // 스포츠 (5개)
  { name: '요가매트 (6mm)', price: 35000, stock: 60, categoryId: categoryIds['스포츠'], sellerId: sellersData[4].id },
  { name: '덤벨 세트 (5kg x 2)', price: 55000, stock: 40, categoryId: categoryIds['스포츠'], sellerId: sellersData[4].id },
  { name: '줄넘기 (카운터기능)', price: 18000, stock: 80, categoryId: categoryIds['스포츠'], sellerId: sellersData[4].id },
  { name: '헬스 장갑', price: 25000, stock: 50, categoryId: categoryIds['스포츠'], sellerId: sellersData[4].id },
  { name: '기능성 운동복 세트', price: 89000, stock: 35, categoryId: categoryIds['스포츠'], sellerId: sellersData[4].id },

  // 도서 (5개)
  { name: '자바스크립트 완벽 가이드', price: 42000, stock: 30, categoryId: categoryIds['도서'], sellerId: sellersData[0].id },
  { name: '경제학 콘서트', price: 18000, stock: 50, categoryId: categoryIds['도서'], sellerId: sellersData[1].id },
  { name: '미드나잇 라이브러리', price: 16000, stock: 40, categoryId: categoryIds['도서'], sellerId: sellersData[2].id },
  { name: '아침 30분 기적의 습관', price: 15000, stock: 60, categoryId: categoryIds['도서'], sellerId: sellersData[3].id },
  { name: '백종원의 집밥 레시피', price: 25000, stock: 45, categoryId: categoryIds['도서'], sellerId: sellersData[4].id }
];

async function seedAllData() {
  try {
    // Connect to all databases
    console.log('📦 데이터베이스에 연결 중...');
    await usersDB.connect();
    await sellersDB.connect();
    await productsDB.connect();
    console.log('✅ 모든 데이터베이스 연결 완료\n');

    // Step 1: Create users
    console.log('👥 Step 1: 사용자 계정 생성 중...');
    await usersDB.query('DELETE FROM users WHERE email LIKE \'%@doamarket.com\'');

    for (const seller of sellersData) {
      await usersDB.query(
        `INSERT INTO users (id, email, name, phone, role, status, "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, 'user', 'active', NOW(), NOW())
         ON CONFLICT (email) DO NOTHING`,
        [seller.userId, seller.email, seller.name, '010-1234-5678']
      );
      console.log(`  ✓ ${seller.name} (${seller.email})`);
    }
    console.log(`✅ ${sellersData.length}명의 사용자 생성 완료\n`);

    // Step 2: Create sellers
    console.log('🏪 Step 2: 판매자 정보 생성 중...');
    await sellersDB.query('DELETE FROM sellers WHERE "businessNumber" LIKE \'%-%\'');

    for (const seller of sellersData) {
      await sellersDB.query(
        `INSERT INTO sellers (id, "userId", "storeName", "businessNumber", status, "verifiedAt", "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, 'verified', NOW(), NOW(), NOW())
         ON CONFLICT ("businessNumber") DO NOTHING`,
        [seller.id, seller.userId, seller.storeName, seller.businessNumber]
      );
      console.log(`  ✓ ${seller.storeName} (사업자번호: ${seller.businessNumber})`);
    }
    console.log(`✅ ${sellersData.length}개의 판매자 생성 완료\n`);

    // Step 3: Create products
    console.log('📦 Step 3: 상품 데이터 생성 중...');
    await productsDB.query('DELETE FROM products');

    let productIndex = 1;
    for (const product of productsData) {
      const productId = `${productIndex.toString().padStart(8, '0')}-0000-0000-0000-000000000000`;
      const thumbnail = `https://via.placeholder.com/400x400.png?text=${encodeURIComponent(product.name)}`;
      const description = `고품질 ${product.name}입니다. 안심하고 구매하세요!`;
      const slug = product.name.toLowerCase().replace(/\s+/g, '-') + '-' + productIndex;

      await productsDB.query(
        `INSERT INTO products (id, name, slug, description, price, thumbnail, "stockQuantity", "sellerId", "categoryId", status, "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'active', NOW(), NOW())`,
        [productId, product.name, slug, description, product.price, thumbnail, product.stock, product.sellerId, product.categoryId]
      );
      console.log(`  ✓ [${productIndex}] ${product.name} - ${product.price.toLocaleString()}원`);
      productIndex++;
    }
    console.log(`✅ ${productsData.length}개의 상품 생성 완료\n`);

    // Summary
    console.log('='.repeat(60));
    console.log('🎉 모든 더미 데이터 생성 완료!\n');
    console.log('📊 생성된 데이터 요약:');
    console.log(`  - 사용자: ${sellersData.length}명`);
    console.log(`  - 판매자: ${sellersData.length}개`);
    console.log(`  - 카테고리: 6개 (이미 생성됨)`);
    console.log(`  - 상품: ${productsData.length}개`);
    console.log('='.repeat(60));

  } catch (error) {
    console.error('❌ 에러 발생:', error);
  } finally {
    await usersDB.end();
    await sellersDB.end();
    await productsDB.end();
    console.log('\n✅ 모든 데이터베이스 연결 종료');
  }
}

seedAllData();
