# Deploy to AWS App Runner - Quick Guide

## Prerequisites
1. AWS Account
2. GitHub repository with your code
3. Model file in the `model/` directory

## Step-by-Step Deployment

### 1. Push to GitHub
Make sure all files are committed and pushed:
```bash
git add .
git commit -m "Initial commit - SkinGuard API"
git push origin main
```

**Important:** Make sure your `model/` directory with the ONNX model file is included in the repository.

### 2. Create AWS App Runner Service

1. **Go to AWS Console** → Search for "App Runner"

2. **Click "Create service"**

3. **Source Configuration:**
   - Choose: **Source code repository**
   - Connect to GitHub (if first time, authorize AWS)
   - Select your repository: `skinguard-backend`
   - Branch: `main`
   - Deployment trigger: **Automatic** (deploys on every push)

4. **Build Settings:**
   - Build configuration: **Use a configuration file**
   - Configuration file: `apprunner.yaml` (already created ✅)

5. **Service Settings:**
   - Service name: `skinguard-api` (or any name you prefer)
   - Virtual CPU: **1 vCPU** (minimum, increase if needed)
   - Memory: **2 GB** (recommended for ML models)
   - Port: **8000** (already configured in apprunner.yaml)

6. **Auto Scaling:**
   - Min instances: **1**
   - Max instances: **5** (adjust based on traffic)

7. **Review and Create**

### 3. Wait for Deployment
- First deployment takes 5-10 minutes
- App Runner will:
  - Clone your repo
  - Install dependencies
  - Build the service
  - Deploy and start the API

### 4. Get Your API URL
Once deployed, you'll get a URL like:
```
https://xxxxx.us-east-1.awsapprunner.com
```

### 5. Test Your API
```bash
curl -X POST "https://your-app-runner-url/predict" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@test_image.jpg"
```

## File Structure (What App Runner Needs)
```
skinguard-backend/
├── main.py              ✅
├── requirements.txt     ✅
├── apprunner.yaml       ✅
└── model/
    └── model2_2025-11-30_03-02-21.onnx  ✅
```

## Important Notes

1. **Model File Size**: If your model is very large (>500MB), consider:
   - Using AWS S3 to store the model
   - Downloading it at startup instead of including in repo

2. **Environment Variables**: If needed, add them in App Runner service settings

3. **Costs**: App Runner charges based on:
   - vCPU hours
   - Memory GB-hours
   - Data transfer
   - Estimate: ~$10-30/month for low traffic

4. **Automatic Deployments**: Every push to `main` branch will trigger a new deployment

5. **Health Checks**: App Runner automatically checks `/health` endpoint

## Troubleshooting

### Build Fails
- Check build logs in App Runner console
- Ensure `requirements.txt` has all dependencies
- Verify Python version matches (3.11)

### Model Not Found
- Ensure `model/` directory is committed to Git
- Check file path in `main.py` matches

### API Not Responding
- Check service logs in App Runner console
- Verify port 8000 is correct
- Check health endpoint: `GET /health`

## Update Your App
After deployment, update your app's API URL:
```javascript
const API_URL = 'https://your-app-runner-url';
```

That's it! Your API will be live and automatically update on every GitHub push.

