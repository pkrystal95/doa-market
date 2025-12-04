#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE doa_auth;
    CREATE DATABASE doa_users;
    CREATE DATABASE doa_products;
    CREATE DATABASE doa_orders;
    CREATE DATABASE doa_payments;
    CREATE DATABASE doa_shippings;
    CREATE DATABASE doa_sellers;
    CREATE DATABASE doa_settlements;
    CREATE DATABASE doa_coupons;
    CREATE DATABASE doa_inventory;
    CREATE DATABASE doa_notifications;
    CREATE DATABASE doa_reviews;
EOSQL

echo "Multiple databases created successfully!"

