# SkinGuard Backend API

FastAPI-based REST API for skin condition classification using an ONNX model.

## Features

- FastAPI REST API with async support
- ONNX model inference
- Image preprocessing and prediction
- Batch prediction support
- CORS enabled for frontend integration
- Health check endpoints

## Setup

### Local Development

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the application:
```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

3. Access the API:
- API: http://localhost:8000
- Interactive docs: http://localhost:8000/docs
- Alternative docs: http://localhost:8000/redoc

## API Endpoints

### Health Check
- `GET /` - Basic health check
- `GET /health` - Detailed health check with model status

### Prediction
- `POST /predict` - Predict from a single image
  - Body: `multipart/form-data` with `file` field
  - Returns: JSON with predicted class and confidence

- `POST /predict/batch` - Predict from multiple images
  - Body: `multipart/form-data` with multiple `files`
  - Returns: JSON array with results for each image

## Testing the API

### Using curl:
```bash
curl -X POST "http://localhost:8000/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@path/to/your/image.jpg"
```

### Using Python:
```python
import requests

url = "http://localhost:8000/predict"
files = {"file": open("path/to/image.jpg", "rb")}
response = requests.post(url, files=files)
print(response.json())
```

## AWS Deployment Options

### Option 1: AWS Lambda (Serverless)

1. **Install dependencies for Lambda:**
```bash
pip install -r requirements.txt -t .
```

2. **Create a Lambda handler** (create `lambda_handler.py`):
```python
from mangum import Mangum
from main import app

handler = Mangum(app)
```

3. **Add to requirements.txt:**
```
mangum==0.17.0
```

4. **Package for Lambda:**
```bash
zip -r lambda-deployment.zip . -x "*.git*" "*.md" "__pycache__/*"
```

5. **Deploy via AWS Console or CLI:**
- Upload the zip file
- Set handler to `lambda_handler.handler`
- Set timeout to 30+ seconds
- Increase memory to 1024MB+ (for model loading)

### Option 2: AWS ECS/Fargate (Container)

1. **Build Docker image:**
```bash
docker build -t skinguard-api .
```

2. **Tag for ECR:**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker tag skinguard-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/skinguard-api:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/skinguard-api:latest
```

3. **Create ECS Task Definition:**
- Use the pushed image
- Set port mapping: 8000
- Configure memory: 2GB+
- Configure CPU: 1 vCPU+

4. **Create ECS Service:**
- Use Fargate launch type
- Configure load balancer if needed

### Option 3: AWS EC2

1. **Launch EC2 instance:**
- Use Ubuntu/Amazon Linux AMI
- t3.medium or larger (for model inference)

2. **SSH into instance and setup:**
```bash
sudo apt-get update
sudo apt-get install -y python3-pip docker.io
git clone <your-repo>
cd skinguard-backend
pip3 install -r requirements.txt
```

3. **Run with systemd service** (create `/etc/systemd/system/skinguard.service`):
```ini
[Unit]
Description=SkinGuard API
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/skinguard-backend
ExecStart=/usr/bin/python3 main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

4. **Enable and start:**
```bash
sudo systemctl enable skinguard
sudo systemctl start skinguard
```

5. **Configure security group:**
- Allow inbound traffic on port 8000

### Option 4: AWS App Runner (Recommended for simplicity)

1. **Create `apprunner.yaml`:**
```yaml
version: 1.0
runtime: python3
build:
  commands:
    build:
      - pip install -r requirements.txt
run:
  runtime-version: 3.11
  command: uvicorn main:app --host 0.0.0.0 --port 8000
  network:
    port: 8000
    env: PORT
  env:
    - name: PORT
      value: "8000"
```

2. **Deploy via AWS Console:**
- Go to AWS App Runner
- Create new service
- Connect to your GitHub/CodeCommit repository
- App Runner will auto-detect and deploy

## Configuration

### Model Settings

Update these in `main.py` based on your model:
- `IMAGE_SIZE`: Input image size (default: 224)
- `MEAN` and `STD`: Normalization values
- `class_names`: Output class names

### CORS Settings

For production, update CORS origins in `main.py`:
```python
allow_origins=["https://yourdomain.com"]
```

## Environment Variables

You can use environment variables for configuration:
- `MODEL_PATH`: Path to model file (default: `model/model2_2025-11-30_03-02-21.onnx`)
- `PORT`: Server port (default: 8000)

## Notes

- The model is loaded once at startup for better performance
- Image preprocessing follows ImageNet normalization standards
- Adjust class names in the `predict()` function based on your model's output
- For production, consider adding authentication/authorization
- Add rate limiting for production use
- Consider using AWS API Gateway in front of Lambda for additional features

