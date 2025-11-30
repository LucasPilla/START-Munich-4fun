"""
Simple test script for the SkinGuard API
"""
import requests
import sys

API_URL = "http://localhost:8000"

def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{API_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    return response.status_code == 200

def test_predict(image_path):
    """Test prediction endpoint"""
    print(f"Testing prediction with image: {image_path}")
    try:
        with open(image_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{API_URL}/predict", files=files)
            print(f"Status: {response.status_code}")
            print(f"Response: {response.json()}\n")
            return response.status_code == 200
    except FileNotFoundError:
        print(f"Error: Image file not found: {image_path}\n")
        return False
    except Exception as e:
        print(f"Error: {str(e)}\n")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("SkinGuard API Test Script")
    print("=" * 50)
    print()
    
    # Test health
    if not test_health():
        print("Health check failed. Is the API running?")
        sys.exit(1)
    
    # Test prediction if image path provided
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        test_predict(image_path)
    else:
        print("No image provided. Usage: python test_api.py <path_to_image>")
        print("Example: python test_api.py test_image.jpg")

