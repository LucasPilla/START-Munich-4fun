"""
AWS Lambda handler for SkinGuard API
"""
from mangum import Mangum
from main import app

# Create handler for Lambda
handler = Mangum(app, lifespan="off")

