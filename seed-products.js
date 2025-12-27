const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres123',
  database: 'doa_products'
});

const categories = ['전자제품', '패션', '식품', '생활용품', '스포츠', '도서'];
const statuses = ['active', 'inactive'];

const productNames = {
  '전자제품': [
    '무선 이어폰', '블루투스 스피커', 'USB 충전기', '노트북 거치대', 'HDMI 케이블',
    '무선 마우스', '키보드', '웹캠', '마이크', 'LED 스탠드'
  ],
  '패션': [
    '면 티셔츠', '청바지', '운동화', '크로스백', '야구모자',
    '후드티', '맨투맨', '슬랙스', '스니커즈', '백팩'
  ],
  '식품': [
    '유기농 사과', '무농약 쌀', '올리브유', '꿀', '견과류',
    '녹차', '커피원두', '초콜릿', '과자', '시리얼'
  ],
  '생활용품': [
    '물티슈', '화장지', '주방세제', '섬유유연제', '칫솔',
    '샴푸', '바디워시', '수건', '슬리퍼', '우산'
  ],
  '스포츠': [
    '요가매트', '덤벨', '줄넘기', '헬스장갑', '운동복',
    '러닝화', '배드민턴채', '축구공', '농구공', '수영모자'
  ],
  '도서': [
    '프로그래밍 입문서', '경제학 원론', '소설책', '자기계발서', '요리책',
    '여행 가이드북', '만화책', '역사책', '과학책', '어린이 동화'
  ]
};

const descriptions = {
  '전자제품': '최신 기술이 적용된 고품질 전자제품입니다.',
  '패션': '트렌디하고 편안한 착용감을 자랑하는 제품입니다.',
  '식품': '신선하고 건강한 식재료입니다.',
  '생활용품': '일상생활에 꼭 필요한 실용적인 제품입니다.',
  '스포츠': '운동 효과를 극대화할 수 있는 스포츠 용품입니다.',
  '도서': '지식과 재미를 동시에 얻을 수 있는 책입니다.'
};

const priceRanges = {
  '전자제품': [15000, 150000],
  '패션': [20000, 100000],
  '식품': [5000, 50000],
  '생활용품': [3000, 30000],
  '스포츠': [10000, 80000],
  '도서': [8000, 35000]
};

function getRandomPrice(category) {
  const [min, max] = priceRanges[category];
  return Math.floor(Math.random() * (max - min + 1) + min);
}

function getRandomStock() {
  return Math.floor(Math.random() * 100) + 1;
}

async function seedProducts() {
  try {
    await client.connect();
    console.log('데이터베이스에 연결되었습니다.');

    // 기존 상품 삭제
    await client.query('DELETE FROM products');
    console.log('기존 상품 데이터를 삭제했습니다.');

    const products = [];
    let productIndex = 1;

    for (const category of categories) {
      const names = productNames[category];
      const description = descriptions[category];

      for (let i = 0; i < 5; i++) {
        const name = names[i];
        const price = getRandomPrice(category);
        const stock = getRandomStock();
        const status = Math.random() > 0.1 ? 'active' : 'inactive';
        const sellerId = `seller${Math.floor(Math.random() * 5) + 1}`;
        const imageUrl = `https://via.placeholder.com/300x300.png?text=${encodeURIComponent(name)}`;

        products.push({
          id: `PROD${String(productIndex).padStart(4, '0')}`,
          name,
          description,
          price,
          imageUrl,
          stock,
          sellerId,
          status,
          category
        });

        productIndex++;
      }
    }

    // 상품 삽입
    for (const product of products) {
      await client.query(
        `INSERT INTO products (id, name, description, price, "imageUrl", stock, "sellerId", status, category, "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())`,
        [
          product.id,
          product.name,
          product.description,
          product.price,
          product.imageUrl,
          product.stock,
          product.sellerId,
          product.status,
          product.category
        ]
      );
    }

    console.log(`${products.length}개의 상품 데이터가 생성되었습니다.`);
    console.log('\n생성된 상품 목록:');
    products.forEach((p, idx) => {
      console.log(`${idx + 1}. [${p.category}] ${p.name} - ${p.price.toLocaleString()}원 (재고: ${p.stock}개)`);
    });

  } catch (error) {
    console.error('에러 발생:', error);
  } finally {
    await client.end();
    console.log('\n데이터베이스 연결이 종료되었습니다.');
  }
}

seedProducts();
