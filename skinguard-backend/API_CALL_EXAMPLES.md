# API Call Examples

## Endpoint
**POST** `/predict`

## Request
- **Method**: POST
- **Content-Type**: `multipart/form-data`
- **Body**: Image file with field name `file`

## Response Format
```json
{
  "predicted_class": "Benign",
  "confidence": 0.95,
  "all_probabilities": {
    "Benign": 0.95,
    "Malignant": 0.05
  }
}
```

---

## Examples by Platform

### 1. JavaScript/React/React Native (Fetch API)

```javascript
const predictSkinCondition = async (imageUri) => {
  const formData = new FormData();
  
  // For React Native, use this:
  formData.append('file', {
    uri: imageUri,
    type: 'image/jpeg',
    name: 'photo.jpg',
  });
  
  // For web/React, use this:
  // formData.append('file', imageFile); // where imageFile is from <input type="file">
  
  try {
    const response = await fetch('http://your-api-url/predict', {
      method: 'POST',
      body: formData,
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    const result = await response.json();
    console.log('Prediction:', result.predicted_class);
    console.log('Confidence:', result.confidence);
    return result;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};

// Usage
predictSkinCondition('file:///path/to/image.jpg');
```

### 2. React Native with Axios

```javascript
import axios from 'axios';

const predictSkinCondition = async (imageUri) => {
  const formData = new FormData();
  formData.append('file', {
    uri: imageUri,
    type: 'image/jpeg',
    name: 'photo.jpg',
  });
  
  try {
    const response = await axios.post('http://your-api-url/predict', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};
```

### 3. Flutter/Dart

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

### 5. iOS (Swift)

```swift
import Foundation

func predictSkinCondition(imageData: Data, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let url = URL(string: "http://your-api-url/predict")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = body
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            completion(.failure(NSError(domain: "Invalid response", code: -1)))
            return
        }
        
        completion(.success(json))
    }.resume()
}

// Usage
if let imageData = UIImage(named: "photo")?.jpegData(compressionQuality: 0.8) {
    predictSkinCondition(imageData: imageData) { result in
        switch result {
        case .success(let response):
            print("Prediction: \(response["predicted_class"] ?? "")")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}
```

### 6. Android (Kotlin)

```kotlin
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

fun predictSkinCondition(imageFile: File, callback: (Result<Map<String, Any>>) -> Unit) {
    val client = OkHttpClient()
    val url = "http://your-api-url/predict"
    
    val requestBody = MultipartBody.Builder()
        .setType(MultipartBody.FORM)
        .addFormDataPart(
            "file",
            imageFile.name,
            imageFile.asRequestBody("image/jpeg".toMediaType())
        )
        .build()
    
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .build()
    
    client.newCall(request).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) {
            callback(Result.failure(e))
        }
        
        override fun onResponse(call: Call, response: Response) {
            val json = JSONObject(response.body?.string() ?: "")
            val result = mapOf(
                "predicted_class" to json.getString("predicted_class"),
                "confidence" to json.getDouble("confidence")
            )
            callback(Result.success(result))
        }
    })
}

// Usage
val imageFile = File("/path/to/image.jpg")
predictSkinCondition(imageFile) { result ->
    result.onSuccess { data ->
        println("Prediction: ${data["predicted_class"]}")
    }.onFailure { error ->
        println("Error: ${error.message}")
    }
}
```

### 7. cURL (Testing)

```bash
curl -X POST "http://your-api-url/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/your/image.jpg"
```

---

## Response Fields

- **predicted_class**: The predicted class name (string)
- **confidence**: Confidence score between 0 and 1 (float)
- **all_probabilities**: Object containing probabilities for all classes

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

