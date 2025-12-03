#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE doa_auth;
    CREATE DATABASE doa_users;
    CREATE DATABASE doa_products;
    CREATE DATABASE doa_orders;
    CREATE DATABASE doa_payments;
    CREATE DATABASE doa_settlements;
EOSQL

echo "Multiple databases created successfully!"

