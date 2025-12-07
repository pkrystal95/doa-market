#!/usr/bin/env node

const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const BASE_URL = 'http://localhost:3000/api/v1'; // API Gateway

// 샘플 UUID 생성
const generateSampleData = () => {
  const userIds = Array.from({ length: 5 }, () => uuidv4());
  const productIds = Array.from({ length: 10 }, () => uuidv4());
  const sellerIds = Array.from({ length: 3 }, () => uuidv4());

  return {
    users: userIds.map((id, idx) => ({
      userId: id,
      firstName: ['John', 'Jane', 'Mike', 'Sarah', 'Tom'][idx],
      lastName: ['Doe', 'Smith', 'Johnson', 'Williams', 'Brown'][idx],
      email: `user${idx + 1}@example.com`,
      phone: `010-1234-${String(idx).padStart(4, '0')}`,
      address: `서울시 강남구 테헤란로 ${100 + idx * 10}`,
      dateOfBirth: new Date(1990 + idx, idx, 15).toISOString(),
    })),
    products: productIds.map((id, idx) => ({
      productId: id,
      name: [
        '노트북',
        '무선 마우스',
        '기계식 키보드',
        '모니터',
        '웹캠',
        '헤드셋',
        'USB 허브',
        '노트북 거치대',
        '무선 충전기',
        '외장 SSD',
      ][idx],
      description: `고품질 ${['노트북', '무선 마우스', '기계식 키보드', '모니터', '웹캠', '헤드셋', 'USB 허브', '노트북 거치대', '무선 충전기', '외장 SSD'][idx]}입니다.`,
      price: (idx + 1) * 50000,
      stock: 100 - idx * 5,
      category: ['전자기기', '주변기기', '주변기기', '전자기기', '주변기기', '주변기기', '액세서리', '액세서리', '액세서리', '저장장치'][idx],
      sellerId: sellerIds[idx % 3],
    })),
    sellers: sellerIds.map((id, idx) => ({
      sellerId: id,
      userId: userIds[idx],
      businessName: ['테크샵', '디지털마켓', 'IT스토어'][idx],
      businessNumber: `123-45-6789${idx}`,
      contactEmail: `seller${idx + 1}@example.com`,
      contactPhone: `02-1234-567${idx}`,
      address: `서울시 송파구 올림픽로 ${300 + idx * 50}`,
      status: 'active',
    })),
  };
};

async function seedDatabase() {
  console.log('\n🌱 데이터 시드 시작...\n');

  const data = generateSampleData();
  const results = {
    success: [],
    failed: [],
  };

  // 1. User Profiles 생성
  console.log('📝 User Profiles 생성 중...');
  for (const user of data.users) {
    try {
      const response = await axios.post(`${BASE_URL}/profiles`, user);
      results.success.push({ type: 'User', id: user.userId, name: user.firstName });
      console.log(`  ✅ ${user.firstName} ${user.lastName} (${user.userId})`);
    } catch (error) {
      results.failed.push({ type: 'User', error: error.message });
      console.log(`  ❌ ${user.firstName}: ${error.response?.data?.error || error.message}`);
    }
  }

  // 2. Sellers 생성
  console.log('\n📝 Sellers 생성 중...');
  for (const seller of data.sellers) {
    try {
      const response = await axios.post(`${BASE_URL}/sellers`, seller);
      results.success.push({ type: 'Seller', id: seller.sellerId, name: seller.businessName });
      console.log(`  ✅ ${seller.businessName} (${seller.sellerId})`);
    } catch (error) {
      results.failed.push({ type: 'Seller', error: error.message });
      console.log(`  ❌ ${seller.businessName}: ${error.response?.data?.error || error.message}`);
    }
  }

  // 3. Products 생성
  console.log('\n📝 Products 생성 중...');
  for (const product of data.products) {
    try {
      const response = await axios.post(`${BASE_URL}/products`, product);
      results.success.push({ type: 'Product', id: product.productId, name: product.name });
      console.log(`  ✅ ${product.name} (${product.productId})`);
    } catch (error) {
      results.failed.push({ type: 'Product', error: error.message });
      console.log(`  ❌ ${product.name}: ${error.response?.data?.error || error.message}`);
    }
  }

  // 결과 요약
  console.log('\n\n📊 시드 결과:');
  console.log(`  ✅ 성공: ${results.success.length}개`);
  console.log(`  ❌ 실패: ${results.failed.length}개`);

  if (results.success.length > 0) {
    console.log('\n✨ 생성된 데이터:');
    console.log(`  - Users: ${results.success.filter((r) => r.type === 'User').length}개`);
    console.log(`  - Sellers: ${results.success.filter((r) => r.type === 'Seller').length}개`);
    console.log(`  - Products: ${results.success.filter((r) => r.type === 'Product').length}개`);
  }

  // 샘플 테스트 명령어
  if (results.success.length > 0) {
    const sampleUser = data.users[0];
    const sampleProduct = data.products[0];

    console.log('\n\n🧪 테스트 명령어:');
    console.log('\n# User Profile 조회');
    console.log(`curl "http://localhost:3002/api/v1/profiles/${sampleUser.userId}"`);
    console.log('\n# User Profile 검색');
    console.log(`curl "http://localhost:3002/api/v1/profiles/search?q=${sampleUser.firstName}"`);
    console.log('\n# Product 조회');
    console.log(`curl "http://localhost:3003/api/v1/products/${sampleProduct.productId}"`);
    console.log('\n# Product 검색');
    console.log(`curl "http://localhost:3003/api/v1/products/search?query=노트북"`);
    console.log('\n# 전체 Products 목록');
    console.log(`curl "http://localhost:3003/api/v1/products?page=1&limit=10"`);
    console.log('\n');
  }

  console.log('\n완료!\n');
}

// 스크립트 실행
seedDatabase().catch((error) => {
  console.error('\n❌ 시드 실패:', error.message);
  process.exit(1);
});
