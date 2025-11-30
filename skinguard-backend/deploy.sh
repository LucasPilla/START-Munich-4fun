#!/bin/bash

# Configuration
AWS_ACCOUNT_ID="404338647393"  # Replace with your AWS account ID
REGION="eu-central-1"
REPO_NAME="skinguard-api"
IMAGE_NAME="skinguard-api"

# Verify AWS account ID is set
if [ -z "$AWS_ACCOUNT_ID" ] || [ "$AWS_ACCOUNT_ID" == "YOUR_ACCOUNT_ID" ]; then
    echo "Getting AWS Account ID..."
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        echo "❌ Error: Could not get AWS Account ID. Please set AWS_ACCOUNT_ID manually or configure AWS CLI."
        exit 1
    fi
    echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"
else
    echo "✅ Using AWS Account ID: $AWS_ACCOUNT_ID"
fi

ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}"

echo "=========================================="
echo "Deploying SkinGuard API to ECR (Frankfurt)"
echo "=========================================="
echo ""

echo "Step 1: Creating ECR repository..."
aws ecr create-repository \
    --repository-name $REPO_NAME \
    --region $REGION \
    2>/dev/null || echo "✅ Repository already exists"

echo ""
echo "Step 2: Authenticating Docker to ECR..."
aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin $ECR_URI

if [ $? -ne 0 ]; then
    echo "❌ Error: Docker login failed. Check your AWS credentials."
    exit 1
fi

echo ""
echo "Step 3: Building Docker image..."
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
    echo "❌ Error: Docker build failed."
    exit 1
fi

echo ""
echo "Step 4: Tagging image..."
docker tag ${IMAGE_NAME}:latest ${ECR_URI}:latest

echo ""
echo "Step 5: Pushing image to ECR..."
docker push ${ECR_URI}:latest

if [ $? -ne 0 ]; then
    echo "❌ Error: Docker push failed."
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Deployment complete!"
echo "=========================================="
echo ""
echo "ECR Image URI: ${ECR_URI}:latest"
echo ""
echo "Next steps:"
echo "1. Go to AWS App Runner console"
echo "2. Create new service"
echo "3. Choose 'Container registry' → 'Amazon ECR'"
echo "4. Use this image URI: ${ECR_URI}:latest"
echo "5. Add environment variable: OPENAI_API_KEY"
echo "6. Set port to 8000"
echo ""

