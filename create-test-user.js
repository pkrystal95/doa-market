const { Client } = require('pg');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const usersDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres123',
  database: 'doa_auth'
});

async function createTestUser() {
  try {
    console.log('📦 데이터베이스 연결 중...');
    await usersDB.connect();
    console.log('✅ 데이터베이스 연결 완료\n');

    // 테스트 사용자 정보
    const testUser = {
      email: 'test@example.com',
      password: 'Test1234!',
      name: '테스트 유저',
      phone: '010-1234-5678'
    };

    // 비밀번호 해싱
    const hashedPassword = await bcrypt.hash(testUser.password, 10);

    // 기존 테스트 사용자 삭제
    console.log('🗑️  기존 테스트 사용자 확인 및 삭제...');
    await usersDB.query(
      'DELETE FROM users WHERE email = $1',
      [testUser.email]
    );

    // 새 테스트 사용자 생성
    console.log('👤 테스트 사용자 생성 중...');
    const userId = crypto.randomUUID();
    const result = await usersDB.query(
      `INSERT INTO users (id, email, password, name, phone, role, status, "createdAt", "updatedAt")
       VALUES ($1, $2, $3, $4, $5, 'user', 'active', NOW(), NOW())
       RETURNING id, email, name`,
      [userId, testUser.email, hashedPassword, testUser.name, testUser.phone]
    );

    console.log('\n✅ 테스트 사용자 생성 완료!');
    console.log('='.repeat(60));
    console.log('📋 테스트 계정 정보:');
    console.log(`  이메일: ${testUser.email}`);
    console.log(`  비밀번호: ${testUser.password}`);
    console.log(`  이름: ${testUser.name}`);
    console.log(`  전화번호: ${testUser.phone}`);
    console.log('='.repeat(60));
    console.log('\n💡 이 계정으로 앱에서 로그인하세요!');

  } catch (error) {
    console.error('❌ 에러 발생:', error);
  } finally {
    await usersDB.end();
    console.log('\n✅ 데이터베이스 연결 종료');
  }
}

createTestUser();
