import json
import base64
import numpy as np
from PIL import Image
import onnxruntime as ort
import io
import os

# Initialize model session (loaded once per container)
ONNX_MODEL_PATH = "./models/model2_2025-11-30_03-02-21.onnx"

model = None
input_name = None
input_shape = None

def get_disease_name(index: int) -> str:
    """
    Get disease name from index.
    Note: This assumes classes are 1-indexed in classes.txt.
    """
    with open('./models/classes.txt', 'r') as f:
        classes = f.readlines()
    return classes[index-1] if index-1 < len(classes) else "Not mapped"

def load_model():
    """Load ONNX model and cache it."""
    global model, input_name, input_shape, ONNX_MODEL_PATH
    if model is None:
        model = ort.InferenceSession(ONNX_MODEL_PATH)
        input_name = model.get_inputs()[0].name
        input_shape = model.get_inputs()[0].shape
    return model, input_name, input_shape

def classify_image(encoded_image: str) -> dict:
    """
    Classify an image using the ONNX model.
    
    Args:
        encoded_image: Base64 encoded image string (with or without data URL prefix)
    
    Returns:
        dict with 'prediction', 'max_index', and 'disease_name' keys
    """
    try:
        # Load model
        model_session, input_name, input_shape = load_model()
        _, h, w, c = input_shape

        # Load image from base64 string
        if ',' in encoded_image:
            encoded_image = encoded_image.split(',')[1]
        image_data = base64.b64decode(encoded_image)
        image = Image.open(io.BytesIO(image_data))
        
        # Reshape image to model input size (no preprocessing, just resize)
        image = image.resize((w, h))
        img_array = np.array(image, dtype=np.float32)
        
        # Add batch dimension
        img_array = np.expand_dims(img_array, 0)
        
        # Run inference
        output = model_session.run(None, {input_name: img_array})[0]
        
        # Get prediction
        max_idx = np.argmax(output[0][:, 0])
        disease_idx = int(output[0][max_idx][1])
        disease_name = get_disease_name(disease_idx)

        return {
            'disease_name': disease_name
        }
        
    except Exception as e:

        raise Exception(f'Failed to classify image: {str(e)}')


