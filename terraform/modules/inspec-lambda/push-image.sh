set -xe

##
# ENV validation
#
if [ -z "$AWS_REGION" ]; then
    echo '$AWS_REGION is a required ENV variable!'
    exit 1
fi

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo '$AWS_ACCOUNT_ID is a required ENV variable!'
    exit 1
fi

if [ -z "$IMAGE_FILE" ]; then
    echo '$IMAGE_FILE is a required ENV variable!'
    exit 1
fi

if [ -z "$REPO_NAME" ]; then
    echo '$REPO_NAME is a required ENV variable!'
    exit 1
fi

if [ -z "$IMAGE_TAG" ]; then
    echo '$IMAGE_TAG is a required ENV variable!'
    exit 1
fi

echo "AWS_REGION=$'AWS_REGION' AWS_ACCOUNT_ID=$AWS_'ACCOUNT_ID' IMAGE_FILE=$'IMAGE_FILE' REPO_NAME='$REPO_NAME' IMAGE_TAG='$IMAGE_TAG'"

##
# Ensure the image file exists
#
if [ ! -f $IMAGE_FILE ]; then
    echo '$IMAGE_FILE file does not exist!'
    echo 'Run `./pull-image.sh` to get the file set up.'
    exit 1
fi

##
# Variable creation
#
IMAGE_IDENTIFIER="$REPO_NAME:$IMAGE_TAG"
IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_IDENTIFIER"
echo $IMAGE_IDENTIFIER
echo $IMAGE

##
# Log in to the AWS ECR registry
#
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecr/get-login-password.html
#
aws ecr get-login-password \
    --region $AWS_REGION \
| docker login \
    --username AWS \
    --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker load --input $IMAGE_FILE

docker tag $IMAGE_IDENTIFIER $IMAGE


##
# Check the SHA of the local and remote images. Don't push if they are the same
#
LOCAL_SHA=$(docker images --no-trunc --quiet $IMAGE_IDENTIFIER | grep -oh 'sha256:[0-9,a-z]*')
REMOTE_SHA=$(aws ecr describe-images --repository-name $REPO_NAME --image-ids imageTag=$IMAGE_TAG --query 'imageDetails[0].imageDigest'| grep -oh 'sha256:[0-9,a-z]*' || echo 'image doesnt exist')
echo "LOCAL SHA:  $LOCAL_SHA"
echo "REMOTE SHA: $REMOTE_SHA"
if [ "$LOCAL_SHA" != "$REMOTE_SHA" ]; then
    docker push $IMAGE
    sleep 60
else
    echo 'LOCAL AND REMOTE SHA values are identical. Skipping docker push.'
fi
