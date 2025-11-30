# Deploy to AWS App Runner using ECR (Frankfurt Region)

## Prerequisites
1. AWS CLI installed and configured
2. Docker installed
3. AWS Account with access to ECR in Frankfurt (eu-central-1)

## Step-by-Step Deployment

### 1. Create ECR Repository

```bash
aws ecr create-repository \
    --repository-name skinguard-api \
    --region eu-central-1
```

Note the repository URI from the output (will be something like: `123456789012.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api`)

### 2. Authenticate Docker to ECR

```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.eu-central-1.amazonaws.com
```

**Replace `123456789012` with your AWS account ID**

### 3. Build Docker Image

```bash
docker build -t skinguard-api .
```

### 4. Tag the Image

```bash
docker tag skinguard-api:latest 123456789012.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
```

**Replace `123456789012` with your AWS account ID**

### 5. Push Image to ECR

```bash
docker push 123456789012.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
```

### 6. Create App Runner Service from ECR

1. **Go to AWS Console** → App Runner → Create service

2. **Source Configuration:**
   - Choose: **Container registry**
   - Provider: **Amazon ECR**
   - Container image URI: `123456789012.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest`
   - Deployment trigger: **Manual** (or **Automatic** if you want auto-deploy on push)

3. **Service Settings:**
   - Service name: `skinguard-api`
   - Virtual CPU: **1 vCPU** (minimum)
   - Memory: **2 GB** (recommended for ML models)
   - Port: **8000**

4. **Environment Variables:**
   - Add environment variable:
     - Key: `OPENAI_API_KEY`
     - Value: `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`

5. **Auto Scaling:**
   - Min instances: **1**
   - Max instances: **5**

6. **Review and Create**

### 7. Wait for Deployment
- First deployment takes 5-10 minutes
- App Runner will pull the image and start the service

### 8. Get Your API URL
Once deployed, you'll get a URL like:
```
https://xxxxx.eu-central-1.awsapprunner.com
```

## Quick Script (All-in-One)

Save this as `deploy.sh`:

```bash
#!/bin/bash

# Configuration
AWS_ACCOUNT_ID="YOUR_ACCOUNT_ID"  # Replace with your AWS account ID
REGION="eu-central-1"
REPO_NAME="skinguard-api"
IMAGE_NAME="skinguard-api"

echo "Step 1: Creating ECR repository..."
aws ecr create-repository \
    --repository-name $REPO_NAME \
    --region $REGION \
    2>/dev/null || echo "Repository already exists"

ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}"

echo "Step 2: Authenticating Docker to ECR..."
aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin $ECR_URI

echo "Step 3: Building Docker image..."
docker build -t $IMAGE_NAME .

echo "Step 4: Tagging image..."
docker tag ${IMAGE_NAME}:latest ${ECR_URI}:latest

echo "Step 5: Pushing image to ECR..."
docker push ${ECR_URI}:latest

echo "✅ Deployment complete!"
echo "ECR Image URI: ${ECR_URI}:latest"
echo "Now create App Runner service using this image URI"
```

Make it executable:
```bash
chmod +x deploy.sh
```

Run it:
```bash
./deploy.sh
```

## Updating the Service

When you make changes:

1. Rebuild the image:
```bash
docker build -t skinguard-api .
```

2. Tag and push:
```bash
docker tag skinguard-api:latest 123456789012.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
docker push 123456789012.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
```

3. In App Runner console, click "Deploy" or it will auto-deploy if trigger is set to Automatic

## Getting Your AWS Account ID

```bash
aws sts get-caller-identity --query Account --output text
```

## Troubleshooting

### Docker login fails
- Make sure AWS CLI is configured: `aws configure`
- Check your IAM permissions for ECR

### Push fails
- Verify ECR repository exists
- Check IAM permissions for `ecr:PutImage`

### Image not found in App Runner
- Verify the image URI is correct
- Make sure image was pushed successfully
- Check region matches (eu-central-1)

### Service fails to start
- Check App Runner logs
- Verify environment variable `OPENAI_API_KEY` is set
- Check that port 8000 is correct

## Cost Estimate

- ECR: ~$0.10 per GB/month for storage
- App Runner: Based on vCPU and memory usage
- Estimate: ~$10-30/month for low traffic

