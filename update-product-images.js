const axios = require('axios');

// 상품별 이미지 URL (Unsplash placeholder 사용)
const productImages = {
  '무선 블루투스 이어폰': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500',
  'USB-C 고속 충전기': 'https://images.unsplash.com/photo-1591290619762-7e68e45f93f3?w=500',
  '무선 마우스': 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500',
  '기계식 키보드': 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
  '27인치 모니터': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500',
  '노트북 거치대': 'https://images.unsplash.com/photo-1625948515291-69613efd103f?w=500',
  'HD 웹캠': 'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=500',
  '외장 SSD 1TB': 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=500',
  '스마트워치': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
  '운동화': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
  '백팩': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
  '텀블러': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500',
  '선글라스': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=500',
  '가죽 지갑': 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500',
  '요가 매트': 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=500',
  '블루투스 스피커': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500',
  '가습기': 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=500',
  '공기청정기': 'https://images.unsplash.com/photo-1607199992386-f1f43f1e20a0?w=500'
};

async function updateProductImages() {
  try {
    // 모든 상품 가져오기
    const response = await axios.get('http://localhost:3003/api/v1/products');
    const products = response.data.data || [];

    console.log(`총 ${products.length}개 상품 발견`);

    let updated = 0;
    for (const product of products) {
      const imageUrl = productImages[product.name];
      if (imageUrl && product.imageUrl !== imageUrl) {
        try {
          await axios.put(`http://localhost:3003/api/v1/products/${product.id}`, {
            imageUrl: imageUrl,
            name: product.name,
            price: product.price,
            categoryId: product.categoryId
          });
          console.log(`✓ ${product.name} 이미지 업데이트 완료`);
          updated++;
        } catch (err) {
          console.log(`✗ ${product.name} 업데이트 실패:`, err.message);
        }
      }
    }

    console.log(`\n${updated}개 상품 이미지 업데이트 완료!`);
  } catch (error) {
    console.error('오류 발생:', error.message);
  }
}

updateProductImages();
