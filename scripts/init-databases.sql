-- DOA Market Database Initialization Script
-- This script creates all databases required for the microservices architecture

-- Authentication Service Database
CREATE DATABASE doa_auth;

-- User Service Database
CREATE DATABASE doa_users;

-- Product Service Database
CREATE DATABASE doa_products;

-- Order Service Database
CREATE DATABASE doa_orders;

-- Payment Service Database
CREATE DATABASE doa_payments;

-- Shipping Service Database
CREATE DATABASE doa_shippings;

-- Seller Service Database
CREATE DATABASE doa_sellers;

-- Settlement Service Database
CREATE DATABASE doa_settlements;

-- Coupon Service Database
CREATE DATABASE doa_coupons;

-- Inventory Service Database
CREATE DATABASE doa_inventory;

-- Notification Service Database
CREATE DATABASE doa_notifications;

-- Review Service Database
CREATE DATABASE doa_reviews;

-- Stats Service Database (for analytics)
CREATE DATABASE doa_stats;

-- Grant privileges (optional, adjust as needed)
GRANT ALL PRIVILEGES ON DATABASE doa_auth TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_users TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_products TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_orders TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_payments TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_shippings TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_sellers TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_settlements TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_coupons TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_inventory TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_notifications TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_reviews TO postgres;
GRANT ALL PRIVILEGES ON DATABASE doa_stats TO postgres;
