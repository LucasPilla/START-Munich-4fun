# API Call Examples

## Endpoint
**POST** `/predict`

## Request
- **Method**: POST
- **Content-Type**: `multipart/form-data`
- **Body**: 
  - `file`: Image file (required)
  - `age`: Optional age of patient (integer, default: 30)
  - `gender`: Optional gender - "male", "female", or "other" (default: "other")

## Response Format
```json
{
  "model_prediction": {
    "predicted_class": "Benign",
    "confidence": 0.95,
    "all_probabilities": {
      "Benign": 0.95,
      "Malignant": 0.05
    }
  },
  "ai_assessment": {
    "disease_description": "A 1 sentence description",
    "severity_level": "High",
    "immediate_action": "What to do right now. Extremely short 1 - 3 bullet points",
    "things_to_keep_in_mind": ["point 1", "point 2", "point 3"],
    "consult_doctor": "Yes",
    "consult_doctor_reasoning": "Brief explanation"
  }
}
```

---

## Examples by Platform

## Flutter/Dart

```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, dynamic>> predictSkinCondition(File imageFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://your-api-url/predict'),
  );
  
  request.files.add(
    await http.MultipartFile.fromPath('file', imageFile.path),
  );
  
  try {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    return json.decode(responseBody);
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

// Usage
File imageFile = File('/path/to/image.jpg');
var result = await predictSkinCondition(imageFile);
print('Prediction: ${result['predicted_class']}');
print('Confidence: ${result['confidence']}');
```

### 4. Python (requests)

```python
import requests

def predict_skin_condition(image_path):
    url = "http://your-api-url/predict"
    
    with open(image_path, 'rb') as f:
        files = {'file': f}
        response = requests.post(url, files=files)
    
    if response.status_code == 200:
        result = response.json()
        print(f"Prediction: {result['predicted_class']}")
        print(f"Confidence: {result['confidence']}")
        return result
    else:
        print(f"Error: {response.status_code}")
        return None

# Usage
result = predict_skin_condition('path/to/image.jpg')
```


### 7. cURL (Testing)

```bash
# Basic (without age/gender)
curl -X POST "http://your-api-url/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/your/image.jpg"

# With age and gender
curl -X POST "http://your-api-url/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/your/image.jpg" \
  -F "age=25" \
  -F "gender=male"
```

---

## Response Fields

### model_prediction
- **predicted_class**: The predicted class name (string)
- **confidence**: Confidence score between 0 and 1 (float)
- **all_probabilities**: Object containing probabilities for all classes

### ai_assessment
- **disease_description**: Description of the condition
- **severity_level**: "High", "Medium", or "Low"
- **immediate_action**: What to do right now (short bullet points)
- **things_to_keep_in_mind**: Array of important points
- **consult_doctor**: "Yes" or "No"
- **consult_doctor_reasoning**: Brief explanation

## Error Responses

- **400**: Bad Request - File is not an image
- **500**: Internal Server Error - Prediction failed
- **503**: Service Unavailable - Model not loaded

---

## Quick Test

Replace `your-api-url` with your actual API URL:
- Local: `http://localhost:8000`
- AWS: `https://your-api-id.execute-api.region.amazonaws.com` (Lambda)
- AWS App Runner: `https://your-service-id.region.awsapprunner.com`

