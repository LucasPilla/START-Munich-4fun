# Pre-Deployment Checklist ✅

## Before Pushing to GitHub

- [x] **main.py** - FastAPI app with model + LLM integration
- [x] **llm_pipeline.py** - OpenAI integration
- [x] **requirements.txt** - All dependencies included
- [x] **apprunner.yaml** - AWS App Runner config
- [x] **model/** directory - ONNX model file present
- [x] **.gitignore** - .env file excluded (API key won't be committed)

## Files to Commit

```bash
git add main.py
git add llm_pipeline.py
git add requirements.txt
git add apprunner.yaml
git add model/
git add .gitignore
git add README.md
git add DEPLOY_AWS_APPRUNNER.md
# DO NOT commit .env file (it's in .gitignore)
```

## AWS App Runner Setup

When creating the service in AWS:

1. **Connect GitHub** - Link your repository
2. **Select branch** - `main` (or your default branch)
3. **Build config** - Use `apprunner.yaml` ✅
4. **Service settings:**
   - CPU: 1 vCPU (minimum)
   - Memory: 2 GB (recommended)
   - Port: 8000 ✅
5. **Environment Variable:**
   - Key: `OPENAI_API_KEY`
   - Value: `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`

## Quick Test After Deployment

```bash
curl -X POST "https://your-app-runner-url/predict" \
  -F "file=@test_image.jpg" \
  -F "age=30" \
  -F "gender=male"
```

## Expected Response

```json
{
  "model_prediction": {
    "predicted_class": "...",
    "confidence": 0.95,
    "all_probabilities": {...}
  },
  "ai_assessment": {
    "disease_description": "...",
    "severity_level": "...",
    "immediate_action": "...",
    "things_to_keep_in_mind": [...],
    "consult_doctor": "...",
    "consult_doctor_reasoning": "..."
  }
}
```

## You're Ready! 🚀

Everything is configured. Just push to GitHub and connect to AWS App Runner!

