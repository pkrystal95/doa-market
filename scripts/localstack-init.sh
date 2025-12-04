#!/bin/bash

# LocalStack Initialization Script
# This script sets up AWS resources for local development

echo "Initializing LocalStack resources..."

# Set AWS CLI to use LocalStack endpoint
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=ap-northeast-2

# Wait for LocalStack to be ready
sleep 5

# Create S3 Buckets
echo "Creating S3 buckets..."
awslocal s3 mb s3://doa-market-dev-uploads
awslocal s3 mb s3://doa-market-dev-products
awslocal s3 mb s3://doa-market-dev-resized-images

# Create SQS Queues
echo "Creating SQS queues..."
awslocal sqs create-queue --queue-name doa-market-order-events-queue
awslocal sqs create-queue --queue-name doa-market-payment-events-queue
awslocal sqs create-queue --queue-name doa-market-notification-queue
awslocal sqs create-queue --queue-name doa-market-order-events-dlq
awslocal sqs create-queue --queue-name doa-market-payment-events-dlq

# Create SNS Topics
echo "Creating SNS topics..."
awslocal sns create-topic --name doa-market-order-events
awslocal sns create-topic --name doa-market-payment-events
awslocal sns create-topic --name doa-market-notifications

# Create EventBridge Event Bus
echo "Creating EventBridge event bus..."
awslocal events create-event-bus --name doa-market-dev-event-bus

# Create DynamoDB Tables
echo "Creating DynamoDB tables..."

# Order Events Table
awslocal dynamodb create-table \
    --table-name doa-market-dev-order-events \
    --attribute-definitions \
        AttributeName=orderId,AttributeType=S \
        AttributeName=timestamp,AttributeType=N \
    --key-schema \
        AttributeName=orderId,KeyType=HASH \
        AttributeName=timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Payment Transactions Table
awslocal dynamodb create-table \
    --table-name doa-market-dev-payment-transactions \
    --attribute-definitions \
        AttributeName=transactionId,AttributeType=S \
        AttributeName=createdAt,AttributeType=N \
    --key-schema \
        AttributeName=transactionId,KeyType=HASH \
        AttributeName=createdAt,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Sessions Table
awslocal dynamodb create-table \
    --table-name doa-market-dev-sessions \
    --attribute-definitions \
        AttributeName=sessionId,AttributeType=S \
    --key-schema \
        AttributeName=sessionId,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Notifications Table
awslocal dynamodb create-table \
    --table-name doa-market-dev-notifications \
    --attribute-definitions \
        AttributeName=userId,AttributeType=S \
        AttributeName=timestamp,AttributeType=N \
    --key-schema \
        AttributeName=userId,KeyType=HASH \
        AttributeName=timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Create Secrets
echo "Creating secrets..."
awslocal secretsmanager create-secret \
    --name doa-market/pg-api-keys/toss-payments \
    --secret-string '{"apiKey":"test_api_key","secretKey":"test_secret_key"}'

awslocal secretsmanager create-secret \
    --name doa-market/databases/product-db \
    --secret-string '{"host":"postgres","port":"5432","username":"postgres","password":"postgres123","database":"doa_products"}'

echo "LocalStack initialization completed!"
