# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html

FUNCTION_NAME='ConfigToHdf'

# https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html
aws lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --zip-file fileb://lambda/$FUNCTION_NAME/function.zip \
    --cli-connect-timeout 6000
