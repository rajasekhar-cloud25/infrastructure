#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
PROJECT_NAME="ecommerce-demo"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
STATE_BUCKET="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}"
LOCK_TABLE="terraform-state-lock"

echo "============================================"
echo "Bootstrapping Terraform State Infrastructure"
echo "============================================"
echo "Region:       $AWS_REGION"
echo "State Bucket: $STATE_BUCKET"
echo "Lock Table:   $LOCK_TABLE"
echo ""

# ── Create S3 bucket ──────────────────────────
echo "Creating S3 bucket: $STATE_BUCKET"
aws s3api create-bucket \
  --bucket "$STATE_BUCKET" \
  --region "$AWS_REGION" \
  2>/dev/null || echo "Bucket already exists"

aws s3api put-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$STATE_BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws s3api put-public-access-block \
  --bucket "$STATE_BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "✅ S3 bucket ready"

# ── Export for GitHub Actions ─────────────────
echo "STATE_BUCKET=${STATE_BUCKET}" >> $GITHUB_OUTPUT
echo "LOCK_TABLE=${LOCK_TABLE}" >> $GITHUB_OUTPUT