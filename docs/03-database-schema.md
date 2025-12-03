# 3단계: 데이터베이스 스키마 설계 (RDS + DynamoDB)

## 목차
- [RDS (PostgreSQL) 스키마](#1-rds-postgresql-데이터베이스-스키마)
  - [users_db](#11-users_db-사용자-데이터베이스)
  - [products_db](#12-products_db-상품-데이터베이스)
  - [orders_db](#13-orders_db-주문-데이터베이스)
  - [payments_db](#14-payments_db-결제-데이터베이스)
  - [settlements_db](#15-settlements_db-정산-데이터베이스)
  - [admin_db](#16-admin_db-관리자-데이터베이스)
  - [files_db](#17-files_db-파일-메타데이터)
- [DynamoDB 스키마](#2-dynamodb-테이블-스키마)
- [데이터베이스 파티셔닝 전략](#3-데이터베이스-파티셔닝-전략)
- [백업 및 복구 전략](#4-데이터베이스-백업-및-복구-전략)

---

## 1. RDS (PostgreSQL) 데이터베이스 스키마

### 1.1 users_db (사용자 데이터베이스)

#### users 테이블
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),  -- null if social login only
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'customer',  -- customer, seller, admin
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active, suspended, deleted
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    user_grade VARCHAR(20) DEFAULT 'bronze',  -- bronze, silver, gold, vip
    total_purchase_amount DECIMAL(15,2) DEFAULT 0,
    cognito_sub VARCHAR(255),  -- Cognito User Sub
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_cognito_sub ON users(cognito_sub);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);
```

#### sellers 테이블
```sql
CREATE TABLE sellers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    business_number VARCHAR(50) UNIQUE NOT NULL,  -- 사업자등록번호
    business_type VARCHAR(50),  -- 개인, 법인
    representative_name VARCHAR(100) NOT NULL,
    business_address TEXT,
    business_phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'pending',  -- pending, approved, rejected, suspended
    approval_date TIMESTAMP WITH TIME ZONE,
    commission_rate DECIMAL(5,2) DEFAULT 10.00,  -- 수수료율 (%)
    bank_account_holder VARCHAR(100),
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sellers_user_id ON sellers(user_id);
CREATE INDEX idx_sellers_status ON sellers(status);
CREATE INDEX idx_sellers_business_number ON sellers(business_number);
```

#### addresses 테이블
```sql
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    address VARCHAR(255) NOT NULL,
    address_detail VARCHAR(255),
    is_default BOOLEAN DEFAULT FALSE,
    label VARCHAR(50),  -- home, office, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_user_default ON addresses(user_id, is_default);
```

#### auth_tokens 테이블
```sql
CREATE TABLE auth_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_type VARCHAR(20) NOT NULL,  -- access, refresh
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_auth_tokens_user_id ON auth_tokens(user_id);
CREATE INDEX idx_auth_tokens_hash ON auth_tokens(token_hash);
CREATE INDEX idx_auth_tokens_expires ON auth_tokens(expires_at);
```

---

### 1.2 products_db (상품 데이터베이스)

#### categories 테이블
```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    level INT NOT NULL DEFAULT 1,  -- 1: 대분류, 2: 중분류, 3: 소분류
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_level ON categories(level);
```

#### products 테이블
```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL,
    original_price DECIMAL(15,2),  -- 원가
    discount_rate DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'draft',  -- draft, pending, approved, rejected, active, inactive
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    purchase_count INT DEFAULT 0,
    rating_avg DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    metadata JSONB,  -- 추가 속성 (색상, 사이즈, 재질 등)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_products_seller_id ON products(seller_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_created_at ON products(created_at DESC);
CREATE INDEX idx_products_rating ON products(rating_avg DESC);
CREATE INDEX idx_products_metadata ON products USING GIN(metadata);
```

#### product_images 테이블
```sql
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    alt_text VARCHAR(255),
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_images_product_id ON product_images(product_id);
```

#### product_options 테이블
```sql
CREATE TABLE product_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,  -- 색상, 사이즈 등
    values JSONB NOT NULL,  -- ["빨강", "파랑", "노랑"]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_options_product_id ON product_options(product_id);
```

#### product_variants 테이블 (옵션 조합별 SKU)
```sql
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(100) UNIQUE NOT NULL,
    option_values JSONB NOT NULL,  -- {"색상": "빨강", "사이즈": "L"}
    price_adjustment DECIMAL(15,2) DEFAULT 0,  -- 추가 금액
    stock INT NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_variants_product_id ON product_variants(product_id);
CREATE INDEX idx_product_variants_sku ON product_variants(sku);
```

#### inventory 테이블
```sql
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
    stock INT NOT NULL DEFAULT 0,
    reserved_stock INT NOT NULL DEFAULT 0,  -- 주문 대기 중인 재고
    available_stock INT GENERATED ALWAYS AS (stock - reserved_stock) STORED,
    low_stock_threshold INT DEFAULT 10,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_stock_positive CHECK (stock >= 0),
    CONSTRAINT check_reserved_stock_valid CHECK (reserved_stock >= 0 AND reserved_stock <= stock)
);

CREATE INDEX idx_inventory_product_id ON inventory(product_id);
CREATE INDEX idx_inventory_variant_id ON inventory(variant_id);
CREATE INDEX idx_inventory_available_stock ON inventory(available_stock);
```

#### inventory_logs 테이블
```sql
CREATE TABLE inventory_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    change_type VARCHAR(20) NOT NULL,  -- in, out, reserved, released, adjusted
    quantity INT NOT NULL,
    previous_stock INT NOT NULL,
    new_stock INT NOT NULL,
    reason TEXT,
    reference_id UUID,  -- order_id 등
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_created_at ON inventory_logs(created_at DESC);
```

#### coupons 테이블
```sql
CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL,  -- percentage, fixed_amount
    discount_value DECIMAL(15,2) NOT NULL,
    max_discount_amount DECIMAL(15,2),  -- 최대 할인 금액
    min_purchase_amount DECIMAL(15,2),  -- 최소 구매 금액
    total_quantity INT,  -- 발급 가능 수량 (null이면 무제한)
    used_quantity INT DEFAULT 0,
    valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    applicable_to VARCHAR(20) DEFAULT 'all',  -- all, category, product, seller
    applicable_ids JSONB,  -- [uuid, uuid, ...]
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_coupons_valid_period ON coupons(valid_from, valid_until);
```

#### user_coupons 테이블
```sql
CREATE TABLE user_coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'available',  -- available, used, expired
    used_at TIMESTAMP WITH TIME ZONE,
    order_id UUID,  -- 사용된 주문 ID
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_user_coupons_user_id ON user_coupons(user_id);
CREATE INDEX idx_user_coupons_status ON user_coupons(user_id, status);
```

#### reviews 테이블
```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id UUID NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    content TEXT NOT NULL,
    images JSONB,  -- [{"url": "...", "thumbnail": "..."}]
    is_verified_purchase BOOLEAN DEFAULT TRUE,
    helpful_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'published',  -- published, hidden, deleted
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_review_per_order UNIQUE(order_id, product_id, user_id)
);

CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);
```

---

### 1.3 orders_db (주문 데이터베이스)

#### orders 테이블
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,  -- ORD-20250101-000001
    user_id UUID NOT NULL REFERENCES users(id),
    seller_id UUID NOT NULL REFERENCES sellers(id),
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    -- pending, payment_waiting, paid, preparing, shipped, delivered, cancelled, refunded

    -- 금액 정보
    items_total DECIMAL(15,2) NOT NULL,  -- 상품 금액 합계
    shipping_fee DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,  -- 쿠폰 할인
    total_amount DECIMAL(15,2) NOT NULL,  -- 최종 결제 금액

    -- 배송 정보
    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(20) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    address VARCHAR(255) NOT NULL,
    address_detail VARCHAR(255),
    delivery_memo TEXT,

    -- 쿠폰 정보
    coupon_id UUID,
    user_coupon_id UUID,

    -- 추가 정보
    metadata JSONB,

    -- 날짜
    ordered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP WITH TIME ZONE,
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_seller_id ON orders(seller_id);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_ordered_at ON orders(ordered_at DESC);
CREATE INDEX idx_orders_metadata ON orders USING GIN(metadata);
```

#### order_items 테이블
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    product_name VARCHAR(255) NOT NULL,  -- 스냅샷
    product_image VARCHAR(500),
    option_values JSONB,  -- {"색상": "빨강", "사이즈": "L"}
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(15,2) NOT NULL,  -- 개당 가격
    total_price DECIMAL(15,2) NOT NULL,  -- quantity * unit_price
    status VARCHAR(30) DEFAULT 'pending',  -- pending, confirmed, cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

#### shipments 테이블
```sql
CREATE TABLE shipments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    carrier VARCHAR(50) NOT NULL,  -- CJ대한통운, 우체국택배 등
    tracking_number VARCHAR(100) UNIQUE,
    status VARCHAR(30) DEFAULT 'preparing',
    -- preparing, picked_up, in_transit, out_for_delivery, delivered, failed, returned

    shipped_at TIMESTAMP WITH TIME ZONE,
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,

    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(20) NOT NULL,
    address VARCHAR(500) NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shipments_order_id ON shipments(order_id);
CREATE INDEX idx_shipments_tracking_number ON shipments(tracking_number);
CREATE INDEX idx_shipments_status ON shipments(status);
```

#### shipment_tracking 테이블
```sql
CREATE TABLE shipment_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id UUID NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL,
    location VARCHAR(255),
    description TEXT,
    tracked_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shipment_tracking_shipment_id ON shipment_tracking(shipment_id);
CREATE INDEX idx_shipment_tracking_tracked_at ON shipment_tracking(tracked_at DESC);
```

---

### 1.4 payments_db (결제 데이터베이스)

#### payments 테이블
```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_key VARCHAR(100) UNIQUE NOT NULL,  -- PG사 결제 키
    order_id UUID NOT NULL REFERENCES orders(id),
    user_id UUID NOT NULL REFERENCES users(id),

    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'pending',
    -- pending, in_progress, completed, failed, cancelled, partial_refunded, refunded

    method VARCHAR(50) NOT NULL,  -- card, virtual_account, transfer, mobile
    provider VARCHAR(50) NOT NULL,  -- tosspayments, inicis, nice 등

    -- PG 정보
    pg_transaction_id VARCHAR(255),
    pg_response JSONB,

    -- 카드 정보 (카드 결제시)
    card_company VARCHAR(50),
    card_number VARCHAR(20),  -- 마스킹된 카드번호
    installment_months INT DEFAULT 0,

    -- 가상계좌 정보
    virtual_account_bank VARCHAR(50),
    virtual_account_number VARCHAR(50),
    virtual_account_holder VARCHAR(100),
    virtual_account_due_date TIMESTAMP WITH TIME ZONE,

    approved_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_payment_key ON payments(payment_key);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_approved_at ON payments(approved_at DESC);
```

#### refunds 테이블
```sql
CREATE TABLE refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id),
    order_id UUID NOT NULL REFERENCES orders(id),

    refund_amount DECIMAL(15,2) NOT NULL,
    refund_reason VARCHAR(50) NOT NULL,  -- customer_request, out_of_stock, seller_cancel
    refund_reason_detail TEXT,

    status VARCHAR(30) DEFAULT 'pending',  -- pending, processing, completed, failed

    -- PG 환불 정보
    pg_refund_id VARCHAR(255),
    pg_response JSONB,

    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_refunds_payment_id ON refunds(payment_id);
CREATE INDEX idx_refunds_order_id ON refunds(order_id);
CREATE INDEX idx_refunds_status ON refunds(status);
```

---

### 1.5 settlements_db (정산 데이터베이스)

#### settlements 테이블
```sql
CREATE TABLE settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_number VARCHAR(50) UNIQUE NOT NULL,  -- SETTLE-202501-0001
    seller_id UUID NOT NULL REFERENCES sellers(id),

    -- 정산 기간
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,

    -- 금액 정보
    total_sales DECIMAL(15,2) NOT NULL,  -- 총 매출
    commission_amount DECIMAL(15,2) NOT NULL,  -- 수수료
    shipping_fee DECIMAL(15,2) DEFAULT 0,
    refund_amount DECIMAL(15,2) DEFAULT 0,  -- 환불액
    adjustment_amount DECIMAL(15,2) DEFAULT 0,  -- 조정액
    settlement_amount DECIMAL(15,2) NOT NULL,  -- 정산 금액

    -- 상태
    status VARCHAR(30) DEFAULT 'calculated',
    -- calculated, confirmed, paid, failed

    -- 계좌 정보 (스냅샷)
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(100),
    bank_account_holder VARCHAR(100),

    -- 문서
    settlement_document_url VARCHAR(500),

    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_settlements_seller_id ON settlements(seller_id);
CREATE INDEX idx_settlements_period ON settlements(period_start, period_end);
CREATE INDEX idx_settlements_status ON settlements(status);
```

#### settlement_items 테이블
```sql
CREATE TABLE settlement_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_id UUID NOT NULL REFERENCES settlements(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id),

    order_number VARCHAR(50) NOT NULL,
    order_amount DECIMAL(15,2) NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL,
    commission_amount DECIMAL(15,2) NOT NULL,
    shipping_fee DECIMAL(15,2) DEFAULT 0,
    item_settlement_amount DECIMAL(15,2) NOT NULL,

    ordered_at TIMESTAMP WITH TIME ZONE NOT NULL,
    delivered_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_settlement_items_settlement_id ON settlement_items(settlement_id);
CREATE INDEX idx_settlement_items_order_id ON settlement_items(order_id);
```

---

### 1.6 admin_db (관리자 데이터베이스)

#### notices 테이블
```sql
CREATE TABLE notices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(20) NOT NULL,  -- general, maintenance, event, urgent
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    target VARCHAR(20) DEFAULT 'all',  -- all, customers, sellers
    is_pinned BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    published_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notices_type ON notices(type);
CREATE INDEX idx_notices_published ON notices(is_published, published_at DESC);
```

#### system_configs 테이블
```sql
CREATE TABLE system_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    category VARCHAR(50),  -- payment, shipping, notification, etc.
    updated_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_configs_key ON system_configs(key);
CREATE INDEX idx_system_configs_category ON system_configs(category);
```

---

### 1.7 files_db (파일 메타데이터)

#### files 테이블
```sql
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_key VARCHAR(500) UNIQUE NOT NULL,  -- S3 key
    bucket VARCHAR(100) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    uploaded_by UUID REFERENCES users(id),
    reference_type VARCHAR(50),  -- product, review, notice, etc.
    reference_id UUID,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_files_file_key ON files(file_key);
CREATE INDEX idx_files_reference ON files(reference_type, reference_id);
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
```

---

## 2. DynamoDB 테이블 스키마

### 2.1 Sessions 테이블
```typescript
// Partition Key: sessionId (String)
// TTL: expiresAt (Number - Unix timestamp)

{
  "sessionId": "sess_abc123...",  // PK
  "userId": "uuid",
  "deviceId": "device_xyz",
  "ipAddress": "123.456.789.0",
  "userAgent": "Mozilla/5.0...",
  "data": {
    "cart": ["product_id_1", "product_id_2"],
    "lastVisitedProducts": ["..."],
    "preferences": {}
  },
  "createdAt": 1704067200000,
  "expiresAt": 1704153600000  // TTL
}

// GSI: userId-index (userId as PK)
```

### 2.2 Carts 테이블
```typescript
// Partition Key: userId (String)
// Sort Key: productId#variantId (String)

{
  "userId": "uuid",  // PK
  "productId#variantId": "prod_uuid#var_uuid",  // SK
  "productId": "prod_uuid",
  "variantId": "var_uuid",
  "productName": "상품명",
  "productImage": "https://...",
  "quantity": 2,
  "unitPrice": 29900,
  "totalPrice": 59800,
  "options": {
    "색상": "빨강",
    "사이즈": "L"
  },
  "sellerId": "seller_uuid",
  "addedAt": 1704067200000,
  "updatedAt": 1704067200000,
  "expiresAt": 1706659200000  // TTL (30일 후)
}
```

### 2.3 Wishlists 테이블
```typescript
// Partition Key: userId (String)
// Sort Key: productId (String)

{
  "userId": "uuid",  // PK
  "productId": "prod_uuid",  // SK
  "productName": "상품명",
  "productImage": "https://...",
  "price": 29900,
  "discount_rate": 10,
  "addedAt": 1704067200000
}

// GSI: productId-index (productId as PK, userId as SK)
// 상품별 찜 수 집계용
```

### 2.4 ProductViews 테이블
```typescript
// Partition Key: userId (String)
// Sort Key: viewedAt#productId (String)

{
  "userId": "uuid",  // PK
  "viewedAt#productId": "1704067200000#prod_uuid",  // SK
  "productId": "prod_uuid",
  "productName": "상품명",
  "productImage": "https://...",
  "categoryId": "cat_uuid",
  "viewedAt": 1704067200000,
  "viewDuration": 45,  // seconds
  "source": "search",  // search, category, recommendation, direct
  "expiresAt": 1711843200000  // TTL (90일 후)
}

// GSI: productId-viewedAt-index (productId as PK, viewedAt as SK)
// 상품별 조회수 집계용
```

### 2.5 OrderEvents 테이블 (이벤트 소싱)
```typescript
// Partition Key: orderId (String)
// Sort Key: timestamp#eventType (String)

{
  "orderId": "order_uuid",  // PK
  "timestamp#eventType": "1704067200000#order.created",  // SK
  "eventId": "event_uuid",
  "eventType": "order.created",
  "eventVersion": "v1",
  "timestamp": 1704067200000,
  "actor": {
    "userId": "uuid",
    "role": "customer",
    "ipAddress": "123.456.789.0"
  },
  "data": {
    "orderId": "order_uuid",
    "userId": "uuid",
    "items": [...],
    "totalAmount": 59800
  },
  "metadata": {
    "correlationId": "corr_uuid",
    "traceId": "trace_uuid"
  }
}

// GSI: eventType-timestamp-index (eventType as PK, timestamp as SK)
// 이벤트 타입별 조회용
```

### 2.6 AuditLogs 테이블
```typescript
// Partition Key: resourceType#resourceId (String)
// Sort Key: timestamp (Number)

{
  "resourceType#resourceId": "user#uuid",  // PK
  "timestamp": 1704067200000,  // SK
  "logId": "log_uuid",
  "action": "UPDATE",  // CREATE, READ, UPDATE, DELETE
  "actor": {
    "userId": "uuid",
    "role": "admin",
    "ipAddress": "123.456.789.0"
  },
  "changes": {
    "before": {"status": "active"},
    "after": {"status": "suspended"}
  },
  "reason": "위반 행위",
  "expiresAt": 1735689600000  // TTL (1년 후)
}

// GSI: actor-timestamp-index (actor.userId as PK, timestamp as SK)
// 사용자별 활동 로그 조회용
```

### 2.7 Notifications 테이블
```typescript
// Partition Key: userId (String)
// Sort Key: createdAt#notificationId (String)

{
  "userId": "uuid",  // PK
  "createdAt#notificationId": "1704067200000#notif_uuid",  // SK
  "notificationId": "notif_uuid",
  "type": "order",  // order, payment, shipping, promotion, system
  "title": "주문이 접수되었습니다",
  "message": "주문번호 ORD-20250101-000001이 접수되었습니다.",
  "data": {
    "orderId": "order_uuid",
    "orderNumber": "ORD-20250101-000001"
  },
  "channels": ["push", "email"],  // 발송 채널
  "status": {
    "push": "sent",
    "email": "sent"
  },
  "isRead": false,
  "readAt": null,
  "createdAt": 1704067200000,
  "expiresAt": 1712025600000  // TTL (90일 후)
}

// GSI: type-createdAt-index (type as PK, createdAt as SK)
// 타입별 알림 조회용
```

### 2.8 NotificationSettings 테이블
```typescript
// Partition Key: userId (String)

{
  "userId": "uuid",  // PK
  "channels": {
    "push": true,
    "email": true,
    "sms": false
  },
  "preferences": {
    "order": true,
    "payment": true,
    "shipping": true,
    "promotion": false,
    "marketing": false,
    "nightTime": false  // 야간 알림 수신
  },
  "deviceTokens": [
    {
      "token": "fcm_token_...",
      "platform": "ios",
      "addedAt": 1704067200000
    }
  ],
  "updatedAt": 1704067200000
}
```

---

## 3. 데이터베이스 파티셔닝 전략

### 3.1 RDS 파티셔닝 (시간 기반)

#### orders 테이블 월별 파티셔닝
```sql
-- orders 테이블 월별 파티셔닝
CREATE TABLE orders (
    -- columns...
) PARTITION BY RANGE (EXTRACT(YEAR FROM ordered_at), EXTRACT(MONTH FROM ordered_at));

CREATE TABLE orders_2025_01 PARTITION OF orders
    FOR VALUES FROM (2025, 1) TO (2025, 2);

CREATE TABLE orders_2025_02 PARTITION OF orders
    FOR VALUES FROM (2025, 2) TO (2025, 3);

-- 자동 파티션 생성 함수
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS void AS $$
DECLARE
    partition_date DATE;
    partition_name TEXT;
BEGIN
    partition_date := DATE_TRUNC('month', CURRENT_DATE + INTERVAL '1 month');
    partition_name := 'orders_' || TO_CHAR(partition_date, 'YYYY_MM');

    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF orders FOR VALUES FROM (%L, %L) TO (%L, %L)',
        partition_name,
        EXTRACT(YEAR FROM partition_date),
        EXTRACT(MONTH FROM partition_date),
        EXTRACT(YEAR FROM partition_date + INTERVAL '1 month'),
        EXTRACT(MONTH FROM partition_date + INTERVAL '1 month')
    );
END;
$$ LANGUAGE plpgsql;
```

#### 자동 파티션 생성 스케줄러
```sql
-- pg_cron 확장 설치
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 매월 1일 새벽 3시에 다음 달 파티션 생성
SELECT cron.schedule('create-monthly-partitions', '0 3 1 * *', 'SELECT create_monthly_partition()');
```

### 3.2 DynamoDB 파티셔닝 전략

DynamoDB는 자동으로 파티셔닝되지만, 효율적인 파티션 키 설계가 중요:

**Hot Partition 방지**:
```typescript
// 나쁜 예: userId만 사용
PK: userId

// 좋은 예: userId + timestamp 조합으로 분산
PK: userId
SK: timestamp#eventType

// 또는 복합 키 사용
PK: userId#YYYY-MM
SK: timestamp
```

---

## 4. 데이터베이스 백업 및 복구 전략

### 4.1 RDS 백업 전략

#### 자동 백업 설정
```typescript
// Terraform/CDK 예시
resource "aws_db_instance" "main" {
  backup_retention_period = 7      // 7일간 보관
  backup_window          = "03:00-04:00"  // KST 12:00-13:00
  maintenance_window     = "mon:04:00-mon:05:00"

  // Point-in-Time Recovery
  enabled_cloudwatch_logs_exports = ["postgresql"]

  // 자동 마이너 버전 업그레이드
  auto_minor_version_upgrade = true

  // Multi-AZ 설정
  multi_az = true
}
```

#### 수동 스냅샷 정책
- 배포 전 필수 수동 스냅샷 생성
- 주요 데이터 변경 작업 전 스냅샷
- 스냅샷 태깅: `Environment`, `Purpose`, `CreatedBy`

#### 복구 절차
1. **전체 복구**: 스냅샷에서 새 RDS 인스턴스 생성
2. **Point-in-Time Recovery**: 5분 단위로 특정 시점 복구
3. **테이블 단위 복구**: pg_dump를 사용한 선택적 복구

### 4.2 DynamoDB 백업 전략

#### Point-in-Time Recovery (PITR) 활성화
```typescript
// Terraform/CDK 예시
resource "aws_dynamodb_table" "sessions" {
  name = "Sessions"

  point_in_time_recovery {
    enabled = true  // 35일 이내 복구 가능
  }
}
```

#### On-Demand 백업
```bash
# AWS CLI로 수동 백업
aws dynamodb create-backup \
  --table-name Orders \
  --backup-name orders-backup-2025-01-01
```

#### 백업 보관 정책
- **Hot Data**: PITR 활성화 (35일)
- **Warm Data**: 월별 수동 백업 (6개월 보관)
- **Cold Data**: S3로 Export 후 Glacier로 이동 (장기 보관)

### 4.3 크로스 리전 복제

#### RDS Read Replica
```typescript
// 다른 리전에 Read Replica 생성
resource "aws_db_instance" "replica" {
  replicate_source_db = aws_db_instance.main.arn

  // 다른 리전
  provider = aws.us-east-1
}
```

#### DynamoDB Global Tables
```typescript
resource "aws_dynamodb_table" "sessions_global" {
  name = "Sessions"

  replica {
    region_name = "us-east-1"
  }

  replica {
    region_name = "eu-west-1"
  }
}
```

### 4.4 백업 모니터링

#### CloudWatch Alarms
```typescript
// 백업 실패 알람
resource "aws_cloudwatch_metric_alarm" "backup_failed" {
  alarm_name          = "rds-backup-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BackupRetentionPeriodStorageUsed"
  namespace           = "AWS/RDS"
  period             = "3600"
  statistic          = "Average"
  threshold          = "0"

  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

---

## 5. 데이터베이스 성능 최적화

### 5.1 Connection Pooling

#### RDS Connection Pool 설정
```typescript
// Node.js 예시
import { Pool } from 'pg';

const pool = new Pool({
  host: process.env.DB_HOST,
  port: 5432,
  database: 'users_db',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,              // 최대 연결 수
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### 5.2 쿼리 최적화

#### EXPLAIN ANALYZE 사용
```sql
EXPLAIN ANALYZE
SELECT * FROM products
WHERE category_id = 'uuid'
  AND status = 'active'
  AND price BETWEEN 10000 AND 50000
ORDER BY created_at DESC
LIMIT 20;
```

#### 인덱스 사용률 모니터링
```sql
-- 사용되지 않는 인덱스 찾기
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY schemaname, tablename;
```

### 5.3 캐싱 전략

#### Redis 캐시 레이어
```typescript
// 상품 정보 캐싱
const cacheKey = `product:${productId}`;
const cached = await redis.get(cacheKey);

if (cached) {
  return JSON.parse(cached);
}

const product = await db.query('SELECT * FROM products WHERE id = $1', [productId]);
await redis.setex(cacheKey, 3600, JSON.stringify(product));  // 1시간 캐시

return product;
```

---

**작성일**: 2025-12-03
**버전**: 1.0
