-- CDC 테스트용 샘플 스키마
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

-- Debezium 유저에게 binlog 읽기 권한 부여
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';
FLUSH PRIVILEGES;

-- CDC 테스트용 주문 테이블
CREATE TABLE IF NOT EXISTS orders (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  customer    VARCHAR(100) NOT NULL,
  product     VARCHAR(100) NOT NULL,
  quantity    INT          NOT NULL DEFAULT 1,
  status      ENUM('pending', 'processing', 'shipped', 'cancelled') NOT NULL DEFAULT 'pending',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 초기 샘플 데이터 (snapshot 테스트용)
INSERT INTO orders (customer, product, quantity, status) VALUES
  ('alice', 'laptop', 1, 'pending'),
  ('bob',   'mouse',  2, 'shipped'),
  ('carol', 'keyboard', 1, 'processing');