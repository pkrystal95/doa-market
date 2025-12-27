const { Client } = require('pg');
const crypto = require('crypto');

const authDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres123',
  database: 'doa_auth'
});

const usersDB = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'postgres123',
  database: 'doa_users'
});

async function addPoints() {
  try {
    await authDB.connect();
    await usersDB.connect();
    console.log('✅ 데이터베이스 연결 완료\n');

    // doa_auth에서 테스트 사용자 찾기
    const userResult = await authDB.query(
      'SELECT id, email, name FROM users WHERE email = $1',
      ['test@example.com']
    );

    if (userResult.rows.length === 0) {
      console.log('❌ 테스트 사용자를 찾을 수 없습니다.');
      return;
    }

    const user = userResult.rows[0];
    console.log(`👤 사용자: ${user.name} (${user.email})`);

    // doa_users에 사용자가 있는지 확인, 없으면 생성
    const usersDBUser = await usersDB.query(
      'SELECT id FROM users WHERE id = $1 OR email = $2',
      [user.id, user.email]
    );

    let finalUserId = user.id;

    if (usersDBUser.rows.length === 0) {
      console.log('📝 doa_users에 사용자 레코드 생성...');
      await usersDB.query(
        `INSERT INTO users (id, email, name, phone, "totalPoints", "createdAt", "updatedAt")
         VALUES ($1, $2, $3, $4, 0, NOW(), NOW())`,
        [user.id, user.email, user.name, '010-1234-5678']
      );
    } else {
      finalUserId = usersDBUser.rows[0].id;
      console.log('✅ doa_users에 사용자가 이미 존재합니다.');
    }

    // 포인트 추가 (100,000 포인트)
    const pointId = crypto.randomUUID();
    const points = 100000;

    // 현재 총 포인트 확인
    const currentBalance = await usersDB.query(
      'SELECT "totalPoints" FROM users WHERE id = $1',
      [finalUserId]
    );
    const currentTotal = currentBalance.rows[0]?.totalPoints || 0;

    await usersDB.query(
      `INSERT INTO points (id, "userId", amount, type, source, description, balance, "remainingAmount", "usedAmount", "isExpired", "createdAt", "updatedAt")
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 0, false, NOW(), NOW())`,
      [pointId, finalUserId, points, 'earn', 'admin', '테스트 포인트 지급', currentTotal + points, points]
    );

    // 사용자의 totalPoints 업데이트
    await usersDB.query(
      `UPDATE users SET "totalPoints" = COALESCE("totalPoints", 0) + $1 WHERE id = $2`,
      [points, finalUserId]
    );

    console.log(`✅ ${points.toLocaleString()}P 추가 완료!\n`);

    // 현재 잔액 확인
    const balanceResult = await usersDB.query(
      'SELECT "totalPoints" FROM users WHERE id = $1',
      [finalUserId]
    );

    console.log('💰 현재 포인트 잔액:', balanceResult.rows[0].totalPoints?.toLocaleString() || '0', 'P');

  } catch (error) {
    console.error('❌ 에러 발생:', error);
  } finally {
    await authDB.end();
    await usersDB.end();
    console.log('\n✅ 데이터베이스 연결 종료');
  }
}

addPoints();
