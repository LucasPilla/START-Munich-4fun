# 1. Use the AWS Lambda base image for Python 3.11
FROM public.ecr.aws/lambda/python:3.11

# 2. Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# 3. Install the specified packages
RUN pip install -r requirements.txt

# 4. Copy Python source files from src/ to Lambda task root
COPY src/*.py ${LAMBDA_TASK_ROOT}/

# 5. Copy models directory
COPY models/ ${LAMBDA_TASK_ROOT}/models/

# 6. Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.lambda_handler" ]