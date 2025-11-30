# Manual Deployment Steps (If AWS CLI not available)

Since AWS CLI is not installed, here are the manual steps:

## Step 1: Install AWS CLI

### On macOS (using Homebrew):
```bash
brew install awscli
```

### Or download installer:
Visit: https://aws.amazon.com/cli/

After installation, configure:
```bash
aws configure
```
Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `eu-central-1`
- Default output format: `json`

## Step 2: Build Docker Image Locally

```bash
docker build -t skinguard-api .
```

## Step 3: Manual ECR Deployment

### Option A: Use AWS Console

1. **Create ECR Repository:**
   - Go to AWS Console → ECR (Elastic Container Registry)
   - Region: Frankfurt (eu-central-1)
   - Click "Create repository"
   - Name: `skinguard-api`
   - Click "Create"

2. **Get Login Command:**
   - Click on the repository
   - Click "View push commands"
   - Copy the commands shown

3. **Push Image:**
   - Run the commands from step 2 in your terminal

### Option B: Use Docker Desktop + AWS Console

1. Build the image:
```bash
docker build -t skinguard-api .
```

2. Tag it:
```bash
docker tag skinguard-api:latest 404338647393.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
```

3. Login to ECR (get command from AWS Console → ECR → View push commands)

4. Push:
```bash
docker push 404338647393.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
```

## Step 4: Create App Runner Service

1. Go to AWS App Runner Console (Frankfurt region)
2. Click "Create service"
3. Choose: **Container registry** → **Amazon ECR**
4. Container image URI: `404338647393.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest`
5. Service settings:
   - Service name: `skinguard-api`
   - Virtual CPU: 1 vCPU
   - Memory: 2 GB
   - Port: 8000
6. Environment Variables:
   - Key: `OPENAI_API_KEY`
   - Value: `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`
7. Click "Create & deploy"

## Quick Commands (After AWS CLI is installed)

```bash
# 1. Login to ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 404338647393.dkr.ecr.eu-central-1.amazonaws.com

# 2. Build
docker build -t skinguard-api .

# 3. Tag
docker tag skinguard-api:latest 404338647393.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest

# 4. Push
docker push 404338647393.dkr.ecr.eu-central-1.amazonaws.com/skinguard-api:latest
```

