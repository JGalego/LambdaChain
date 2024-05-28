# λChain 🔗🦜

## Overview

Run [LangChain.js](https://js.langchain.com/v0.2/docs/introduction/) applications powered by [Amazon Bedrock](https://aws.amazon.com/bedrock/) on [AWS Lambda](https://aws.amazon.com/lambda/) using [function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html) and [response streaming](https://aws.amazon.com/blogs/compute/introducing-aws-lambda-response-streaming/).

<img src="lambdachain.png" width="70%"/>

## Prerequisites

Before proceeding, take some time perform the following prerequisite actions:

1. Make sure these tools are installed and properly configured

	- [Docker](https://docs.docker.com/engine/install/) 🐋
	- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) 🐿️
	- [jq](https://jqlang.github.io/jq/download/) (*optional*)

2. Request model access via [Amazon Bedrock](https://aws.amazon.com/bedrock/)

	> 💡 For more information on how enable model access, please refer to the [Amazon Bedrock User Guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) (Set up > Model access)

## Instructions

0. Set up AWS credentials.

    > 💡 For more information on how to do this, please refer to the [AWS Boto3 documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html) (Developer Guide > Credentials).

    ```bash
    # Option 1: (recommended) AWS CLI
    aws configure

    # Option 2: environment variables
    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...
    export AWS_DEFAULT_REGION=...
    ```

1. Build and deploy the application.

    ```bash
    # 🏗️ Build
    sam build --use-container

    # 🚀 Deploy
    sam deploy --guided

    # ❗ Don't forget to note down the function URL
    export FUNCTION_URL=`sam list stack-outputs --stack-name lambdachain --output json | jq -r '.[] | select(.OutputKey == "LambdaChainFunctionUrl") | .OutputValue'`
    ```

3. Test it out!

    **SAM**

    ```bash
    sam remote invoke --stack-name lambdachain --event '{"body": "{\"message\": \"What is the answer to life, the Universe and everything?\"}"}'
    ```

    **cURL**

    ```bash
    curl --no-buffer \
         --silent \
         --aws-sigv4 "aws:amz:$AWS_DEFAULT_REGION:lambda" \
         --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
         -H "x-amz-security-token: $AWS_SESSION_TOKEN" \
         -H "content-type: application/json" \
         -d '{"message": "What is the answer to life, the Universe and everything?"}' \
         $FUNCTION_URL
    ```

    > ☝️ **Pro Tip:** Pipe the output through `jq -rj .kwargs.content` for a cleaner output