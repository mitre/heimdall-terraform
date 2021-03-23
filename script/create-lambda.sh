set -e

ROLE_NAME='Config-to-HDF-Pusher-Role'
RULE_NAME='Config-to-HDF-Pusher-Rule'
EVENT_NAME='Config-to-HDF-Pusher-Event'
FUNCTION_NAME='Config-to-HDF-Pusher'
HEIMDALL_PASS_SECRET_NAME='Config-to-HDF-Pusher-HEIMDALL_API_PASS'

validate_args() {
    if [ -z ${HEIMDALL_URL} ]; then
        echo "Missing environment variable HEIMDALL_URL"
        exit 1;
    fi

    if [ -z ${HEIMDALL_API_USER} ]; then
        echo "Missing environment variable HEIMDALL_API_USER"
        exit 1;
    fi

    if [ -z ${HEIMDALL_API_PASS} ]; then
        echo "Missing environment variable HEIMDALL_API_PASS"
        exit 1;
    fi

    if [ -z ${HEIMDALL_EVAL_TAG} ]; then
        echo "Missing environment variable HEIMDALL_EVAL_TAG"
        exit 1;
    fi
}

echo 'Validating args...'
validate_args
echo 'Validated args.\n\n'

##
# Create the role if does not exist, then capture role ARN
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/wait/role-exists.html
echo 'Ensuring lambda role exists...'
aws iam wait role-exists --role-name $ROLE_NAME
roleExists=$?
if [ $roleExists -ne 0 ]; then
    echo "Role does not yet exist. Creating..."
    aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://roles/LambdaAllowAssumeRole.json
fi
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam put-role-policy --role-name $ROLE_NAME --policy-name AllowAWSConfigRead --policy-document file://roles/AllowAWSConfigRead.json
roleArn=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text)
echo 'Ensured lambda role exists.\n\n'

##
# Create the lambda function
#
# https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html
echo 'Creating lambda function...'
aws lambda create-function \
    --function-name $FUNCTION_NAME \
    --memory-size 128 \
    --no-publish \
    --handler 'lambda_function.lambda_handler' \
    --runtime 'ruby2.7' \
    --role $roleArn \
    --timeout '300' \
    --environment "Variables={HEIMDALL_URL=$HEIMDALL_URL,HEIMDALL_API_USER=$HEIMDALL_API_USER,HEIMDALL_PASS_SECRET_NAME=$HEIMDALL_PASS_SECRET_NAME,HEIMDALL_EVAL_TAG=$HEIMDALL_EVAL_TAG}" \
    --zip-file fileb://lambda/$FUNCTION_NAME/function.zip \
    --cli-connect-timeout 6000
    # --vpc-config 'SubnetIds=...,SecurityGroupIds=...' \
lambdaArn=$(aws lambda get-function --function-name $FUNCTION_NAME --query 'Configuration.FunctionArn' --output text)
echo 'Created lambda function...\n\n'

##
# Create EventBridge Rule for lambda schedule
#
# https://docs.aws.amazon.com/eventbridge/latest/userguide/run-lambda-schedule.html
echo 'Creating EventBridge rule...'
aws events put-rule \
    --name $RULE_NAME \
    --schedule-expression 'rate(24 hours)'
echo 'Created EventBridge rule.\n\n'

echo 'Adding permission to EventBridge rule...'
aws lambda add-permission \
    --function-name $FUNCTION_NAME \
    --statement-id $EVENT_NAME \
    --action 'lambda:InvokeFunction' \
    --principal events.amazonaws.com \
    --source-arn $lambdaArn
echo 'Added permission to EventBridge rule.\n\n'

echo 'Adding lambda targer to EventBridge rule...'
aws events put-targets --rule $RULE_NAME --targets "Id"="1","Arn"="$lambdaArn"
echo 'Added target to EventBridge rule.\n\n'

## 
# Create the AWS Secret in SecretsManager that stores the Heimdall Password
#
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/secretsmanager/put-resource-policy.html
aws secretsmanager create-secret \
    --name $HEIMDALL_PASS_SECRET_NAME \
    --description 'The password for a Heimdall server account used in the Config-to-HDF-Pusher lambda.' \
    --secret-string $HEIMDALL_API_PASS
secretArn=$(aws secretsmanager describe-secret --secret-id $HEIMDALL_PASS_SECRET_NAME --query 'ARN' --output text)

##
# Allow the lambda role to access this specific secret
#
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/put-role-policy.html
policy=$(cat <<-END
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "$secretArn"
    }
}
END
)
aws iam put-role-policy \
    --role-name $ROLE_NAME \
    --policy-name "Allow-$(echo HEIMDALL_PASS_SECRET_NAME)-Access" \
    --policy-document $policy

