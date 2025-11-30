from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import onnxruntime as ort
import numpy as np
from PIL import Image
import io
import os
from typing import Optional
import uvicorn

app = FastAPI(
    title="SkinGuard API",
    description="API for skin condition classification using ONNX model",
    version="1.0.0"
)

# Enable CORS for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables for model
model_path = "model/model2_2025-11-30_03-02-21.onnx"
session = None
input_name = None
output_name = None

# Model configuration (adjust based on your model)
IMAGE_SIZE = 224  # Common size for skin models, adjust if needed
MEAN = np.array([0.485, 0.456, 0.406])  # ImageNet mean
STD = np.array([0.229, 0.224, 0.225])   # ImageNet std

def load_model():
    """Load the ONNX model"""
    global session, input_name, output_name
    
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model file not found at {model_path}")
    
    try:
        session = ort.InferenceSession(model_path)
        input_name = session.get_inputs()[0].name
        output_name = session.get_outputs()[0].name
        print(f"Model loaded successfully. Input: {input_name}, Output: {output_name}")
    except Exception as e:
        raise RuntimeError(f"Failed to load model: {str(e)}")

#May or may not be used
def preprocess_image(image: Image.Image) -> np.ndarray:
    """Preprocess image for model inference"""
    # Resize image
    image = image.resize((IMAGE_SIZE, IMAGE_SIZE))
    
    # Convert to RGB if needed
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    # Convert to numpy array and normalize
    img_array = np.array(image, dtype=np.float32) / 255.0
    
    # Normalize with ImageNet stats
    img_array = (img_array - MEAN) / STD
    
    # Convert from HWC to CHW format
    img_array = np.transpose(img_array, (2, 0, 1))
    
    # Add batch dimension
    img_array = np.expand_dims(img_array, axis=0)
    
    return img_array

def predict(image: np.ndarray) -> dict:
    """Run inference on preprocessed image"""
    global session, input_name, output_name
    
    if session is None:
        raise RuntimeError("Model not loaded")
    
    try:
        # Run inference
        outputs = session.run([output_name], {input_name: image})
        predictions = outputs[0][0]  # Get first batch item
        
        # Apply softmax to get probabilities
        exp_predictions = np.exp(predictions - np.max(predictions))
        probabilities = exp_predictions / exp_predictions.sum()
        
        # Get top prediction
        top_class_idx = np.argmax(probabilities)
        confidence = float(probabilities[top_class_idx])
        
        # Return results
        # Adjust class names based on your model's output classes
        class_names = ["Benign", "Malignant"]  # Update with your actual class names
        
        result = {
            "predicted_class": class_names[top_class_idx] if top_class_idx < len(class_names) else f"Class_{top_class_idx}",
            "confidence": confidence,
            "all_probabilities": {
                class_names[i] if i < len(class_names) else f"Class_{i}": float(probabilities[i])
                for i in range(len(probabilities))
            }
        }
        
        return result
    except Exception as e:
        raise RuntimeError(f"Inference failed: {str(e)}")

@app.on_event("startup")
async def startup_event():
    """Load model on startup"""
    try:
        load_model()
        print("API started successfully")
    except Exception as e:
        print(f"Failed to start API: {str(e)}")
        raise

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "message": "SkinGuard API is running",
        "model_loaded": session is not None
    }

@app.get("/health")
async def health():
    """Detailed health check"""
    return {
        "status": "healthy",
        "model_loaded": session is not None,
        "model_path": model_path
    }

@app.post("/predict")
async def predict_endpoint(file: UploadFile = File(...)):
    """
    Predict skin condition from uploaded image
    
    Args:
        file: Image file (JPEG, PNG, etc.)
    
    Returns:
        Prediction results with class and confidence
    """
    if session is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    # Validate file type
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        # Read image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Preprocess
        processed_image = preprocess_image(image)
        
        # Predict
        result = predict(processed_image)
        
        return JSONResponse(content=result)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")



if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

