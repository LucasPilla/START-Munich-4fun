#!/bin/bash

# --- Configuration ---
REGION="eu-central-1"
ACCOUNT_ID="166023636276"
REPO_NAME="skinguard"
FUNCTION_NAME="skinguard-function" # <--- MAKE SURE THIS MATCHES YOUR LAMBDA NAME IN AWS
URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}"

# --- Execution ---

echo "1. Logging in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

echo "2. Building Docker Image..."
# FIXED: Added --provenance=false to solve the "manifest not supported" error
docker build --platform linux/amd64 --provenance=false -t $REPO_NAME .

echo "3. Tagging Image..."
docker tag $REPO_NAME:latest $URI:latest

echo "4. Pushing to ECR..."
docker push $URI:latest

echo "5. Updating Lambda Function Code..."
# This forces Lambda to pull the new image immediately
aws lambda update-function-code --function-name $FUNCTION_NAME --image-uri $URI:latest

echo "Done! Deployment complete."