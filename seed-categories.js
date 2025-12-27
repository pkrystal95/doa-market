const { Client } = require('pg');
const crypto = require('crypto');

function generateUUID() {
  return crypto.randomUUID();
}

const productsDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres123',
  database: 'doa_products'
});

// 대분류 카테고리
const mainCategories = [
  { id: '11111111-1111-1111-1111-111111111111', name: '전자제품', slug: 'electronics' },
  { id: '22222222-2222-2222-2222-222222222222', name: '패션/의류', slug: 'fashion' },
  { id: '33333333-3333-3333-3333-333333333333', name: '식품', slug: 'food' },
  { id: '44444444-4444-4444-4444-444444444444', name: '생활용품', slug: 'living' },
  { id: '55555555-5555-5555-5555-555555555555', name: '스포츠/레저', slug: 'sports' },
  { id: '66666666-6666-6666-6666-666666666666', name: '도서', slug: 'books' },
  { id: '77777777-7777-7777-7777-777777777777', name: '뷰티', slug: 'beauty' },
  { id: '88888888-8888-8888-8888-888888888888', name: '건강', slug: 'health' },
  { id: '99999999-9999-9999-9999-999999999999', name: '반려용품', slug: 'pet' },
  { id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa00', name: '리빙', slug: 'home' }
];

// 중분류 카테고리 (각 대분류별)
const subCategories = [
  // 전자제품
  { name: '스마트폰', slug: 'smartphone', parentId: '11111111-1111-1111-1111-111111111111' },
  { name: '노트북/PC', slug: 'laptop-pc', parentId: '11111111-1111-1111-1111-111111111111' },
  { name: '태블릿', slug: 'tablet', parentId: '11111111-1111-1111-1111-111111111111' },
  { name: '이어폰/헤드폰', slug: 'earphones', parentId: '11111111-1111-1111-1111-111111111111' },
  { name: '스피커/오디오', slug: 'speaker', parentId: '11111111-1111-1111-1111-111111111111' },

  // 패션/의류
  { name: '남성의류', slug: 'men-clothing', parentId: '22222222-2222-2222-2222-222222222222' },
  { name: '여성의류', slug: 'women-clothing', parentId: '22222222-2222-2222-2222-222222222222' },
  { name: '신발', slug: 'shoes', parentId: '22222222-2222-2222-2222-222222222222' },
  { name: '가방/지갑', slug: 'bags', parentId: '22222222-2222-2222-2222-222222222222' },
  { name: '악세서리', slug: 'accessories', parentId: '22222222-2222-2222-2222-222222222222' },

  // 식품
  { name: '과일', slug: 'fruits', parentId: '33333333-3333-3333-3333-333333333333' },
  { name: '채소', slug: 'vegetables', parentId: '33333333-3333-3333-3333-333333333333' },
  { name: '쌀/곡물', slug: 'rice-grains', parentId: '33333333-3333-3333-3333-333333333333' },
  { name: '건강식품', slug: 'health-food', parentId: '33333333-3333-3333-3333-333333333333' },
  { name: '간식/과자', slug: 'snacks', parentId: '33333333-3333-3333-3333-333333333333' },

  // 생활용품
  { name: '청소용품', slug: 'cleaning', parentId: '44444444-4444-4444-4444-444444444444' },
  { name: '세탁용품', slug: 'laundry', parentId: '44444444-4444-4444-4444-444444444444' },
  { name: '욕실용품', slug: 'bathroom', parentId: '44444444-4444-4444-4444-444444444444' },
  { name: '주방용품', slug: 'kitchen', parentId: '44444444-4444-4444-4444-444444444444' },
  { name: '생활잡화', slug: 'misc', parentId: '44444444-4444-4444-4444-444444444444' },

  // 스포츠/레저
  { name: '운동기구', slug: 'equipment', parentId: '55555555-5555-5555-5555-555555555555' },
  { name: '운동복', slug: 'sportswear', parentId: '55555555-5555-5555-5555-555555555555' },
  { name: '등산용품', slug: 'hiking', parentId: '55555555-5555-5555-5555-555555555555' },
  { name: '캠핑용품', slug: 'camping', parentId: '55555555-5555-5555-5555-555555555555' },
  { name: '자전거', slug: 'bicycle', parentId: '55555555-5555-5555-5555-555555555555' },

  // 도서
  { name: '소설/에세이', slug: 'fiction', parentId: '66666666-6666-6666-6666-666666666666' },
  { name: '경제/경영', slug: 'business', parentId: '66666666-6666-6666-6666-666666666666' },
  { name: 'IT/컴퓨터', slug: 'it-computer', parentId: '66666666-6666-6666-6666-666666666666' },
  { name: '자기계발', slug: 'self-improvement', parentId: '66666666-6666-6666-6666-666666666666' },
  { name: '어린이/청소년', slug: 'children', parentId: '66666666-6666-6666-6666-666666666666' },

  // 뷰티
  { name: '스킨케어', slug: 'skincare', parentId: '77777777-7777-7777-7777-777777777777' },
  { name: '메이크업', slug: 'makeup', parentId: '77777777-7777-7777-7777-777777777777' },
  { name: '헤어케어', slug: 'haircare', parentId: '77777777-7777-7777-7777-777777777777' },
  { name: '바디케어', slug: 'bodycare', parentId: '77777777-7777-7777-7777-777777777777' },
  { name: '향수', slug: 'perfume', parentId: '77777777-7777-7777-7777-777777777777' },

  // 건강
  { name: '영양제', slug: 'supplements', parentId: '88888888-8888-8888-8888-888888888888' },
  { name: '건강기능식품', slug: 'health-functional', parentId: '88888888-8888-8888-8888-888888888888' },
  { name: '의료용품', slug: 'medical', parentId: '88888888-8888-8888-8888-888888888888' },
  { name: '안마/마사지', slug: 'massage', parentId: '88888888-8888-8888-8888-888888888888' },
  { name: '다이어트', slug: 'diet', parentId: '88888888-8888-8888-8888-888888888888' },

  // 반려용품
  { name: '강아지용품', slug: 'dog', parentId: '99999999-9999-9999-9999-999999999999' },
  { name: '고양이용품', slug: 'cat', parentId: '99999999-9999-9999-9999-999999999999' },
  { name: '사료/간식', slug: 'pet-food', parentId: '99999999-9999-9999-9999-999999999999' },
  { name: '장난감/놀이', slug: 'pet-toys', parentId: '99999999-9999-9999-9999-999999999999' },
  { name: '위생/배변', slug: 'pet-hygiene', parentId: '99999999-9999-9999-9999-999999999999' },

  // 리빙
  { name: '가구', slug: 'furniture', parentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa00' },
  { name: '침구/커튼', slug: 'bedding', parentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa00' },
  { name: '조명', slug: 'lighting', parentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa00' },
  { name: '인테리어소품', slug: 'interior', parentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa00' },
  { name: '수납/정리', slug: 'storage', parentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa00' }
];

async function seedCategories() {
  try {
    console.log('📦 데이터베이스 연결 중...');
    await productsDB.connect();
    console.log('✅ 데이터베이스 연결 완료\n');

    // Step 1: 기존 카테고리 삭제 (중분류부터)
    console.log('🗑️  기존 카테고리 삭제 중...');
    await productsDB.query('DELETE FROM categories');
    console.log('✅ 기존 카테고리 삭제 완료\n');

    // Step 2: 대분류 카테고리 생성
    console.log('📂 대분류 카테고리 생성 중...');
    for (const category of mainCategories) {
      await productsDB.query(
        `INSERT INTO categories ("categoryId", name, slug, "parentId", "displayOrder", "isActive", "createdAt", "updatedAt")
         VALUES ($1, $2, $3, NULL, 0, true, NOW(), NOW())`,
        [category.id, category.name, category.slug]
      );
      console.log(`  ✓ ${category.name}`);
    }
    console.log(`✅ ${mainCategories.length}개의 대분류 생성 완료\n`);

    // Step 3: 중분류 카테고리 생성
    console.log('📁 중분류 카테고리 생성 중...');
    let subIndex = 1;
    for (const category of subCategories) {
      const categoryId = generateUUID();
      await productsDB.query(
        `INSERT INTO categories ("categoryId", name, slug, "parentId", "displayOrder", "isActive", "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, $5, true, NOW(), NOW())`,
        [categoryId, category.name, category.slug, category.parentId, subIndex]
      );

      // 부모 카테고리 이름 찾기
      const parent = mainCategories.find(m => m.id === category.parentId);
      console.log(`  ✓ ${parent?.name} > ${category.name}`);
      subIndex++;
    }
    console.log(`✅ ${subCategories.length}개의 중분류 생성 완료\n`);

    // Summary
    console.log('='.repeat(60));
    console.log('🎉 카테고리 데이터 생성 완료!\n');
    console.log('📊 생성된 데이터 요약:');
    console.log(`  - 대분류: ${mainCategories.length}개`);
    console.log(`  - 중분류: ${subCategories.length}개`);
    console.log(`  - 총 카테고리: ${mainCategories.length + subCategories.length}개`);
    console.log('='.repeat(60));

  } catch (error) {
    console.error('❌ 에러 발생:', error);
  } finally {
    await productsDB.end();
    console.log('\n✅ 데이터베이스 연결 종료');
  }
}

seedCategories();
