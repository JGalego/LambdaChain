#!/bin/bash

# Initial checks
if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  read -e -i "us-east-1" -p "AWS Region: " AWS_DEFAULT_REGION
fi

# Get account ID
AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`

# Build image
docker build --rm -t lambdachain:latest .

# Login to registry
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS \
                                                                         --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Create new repository
aws ecr create-repository --repository-name lambdachain \
                          --image-scanning-configuration scanOnPush=true \
                          --image-tag-mutability MUTABLE

# Tag and push image
docker tag lambdachain:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/lambdachain:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/lambdachain:latest

# Create IAM role
aws iam create-role --role-name lambdachain \
                    --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

aws iam create-policy --policy-name LambdaChainBedrock \
                      --policy-document '{"Version": "2012-10-17", "Statement": [{"Sid": "1", "Effect": "Allow", "Action": ["bedrock:*"], "Resource": ["*"]}]}'

aws iam attach-role-policy --role-name lambdachain \
                           --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

aws iam attach-role-policy --role-name lambdachain \
                           --policy-arn arn:aws:iam::aws:policy/LambdaChainBedrock

# Create Lambda function
aws lambda create-function --function-name lambdachain \
                           --description "Run LangChain.js apps powered by Amazon Bedrock on AWS Lambda" \
                           --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/lambdachain \
                           --package-type Image \
                           --code ImageUri=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/lambdachain:latest \
                           --timeout 300 \
                           --memory-size 10240 \
                           --publish

# Create URL endpoint to the function
aws lambda create-function-url-config --function-name lambdachain \
                                      --auth-type AWS_IAM \
                                      --invoke-mode RESPONSE_STREAM

# Update function image
aws lambda update-function-code --function-name lambdachain \
								--image-uri "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/lambdachain:latest"

# Get function URL
aws lambda get-function-url-config --function-name lambdachain \
                                   --query FunctionUrl \
                                   --output text
