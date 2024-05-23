# λChain 🔗🦜

## Overview

Learn how to run [LangChain.js](https://js.langchain.com/v0.2/docs/introduction/) applications powered by [Amazon Bedrock](https://aws.amazon.com/bedrock/) on [AWS Lambda](https://aws.amazon.com/lambda/) using [function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html) and [response streaming](https://aws.amazon.com/blogs/compute/introducing-aws-lambda-response-streaming/).

## Instructions

1. Run `chmod +x setup.sh && ./setup.sh`

2. Save the URL endpoint (`FUNCTION_URL`).

	```bash
	FUNCTION_URL=`aws lambda get-function-url-config --function-name lambdachain --query FunctionUrl --output text`
	```

3. Test it out!

    **cURL**

    ```bash
    curl --no-buffer \
		 --silent \
         --aws-sigv4 "aws:amz:$AWS_DEFAULT_REGION:lambda" \
         --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
         -H "x-amz-security-token: $AWS_SESSION_TOKEN" \
         -H "content-type: application/json" \
         -d '{"message": "What is quantum computing?"}' \
         $FUNCTION_URL | jq -rj .kwargs.content
    ```