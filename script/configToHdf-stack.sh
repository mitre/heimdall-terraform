##
# export HeimdallUrl=''
# export HeimdallApiUser='ConfigToHdf@example.com'
# export HeimdallApiPass=''
# export HeimdallEvalTag='ConfigToHdf'
# export VpcId=''
# export SubnetIdA=''
# export SubnetIdB=''
#

set -e

validate_env() {
    if [[ -z "${SubnetId}" ]]; then
      export SubnetId=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=ConfigToHdfPrivateSubnet --query 'Subnets[0].SubnetId')
      echo "Defaulting \$SubnetId to $SubnetId"
    fi

    if [[ -z "${SecurityGroupId}" ]]; then
      export SecurityGroupId=$(aws ec2 describe-security-groups --filters Name=tag:Name,Values=ConfigToHdfSecurityGroup --query 'SecurityGroups[0].GroupId')
      echo "Defaulting \$SecurityGroupId to $SecurityGroupId"
    fi

    # https://linuxhint.com/bash_loop_list_strings/
    # https://stackoverflow.com/questions/50763087/bash-check-environment-variables-are-set-in-an-array-of-env-vars
    declare -a StringArray=("HeimdallUrl" "HeimdallApiUser" "HeimdallApiPass" "HeimdallEvalTag" "SubnetIdA" "SubnetIdB" "VpcId")
    for expectedVar in ${StringArray[@]}; do
        if [ -z "${!expectedVar+x}" ]; then
            echo "$expectedVar is expected to be set as an environment variable!"
            echo "Set the variable with:"
            echo "    $expectedVar=''"
            exit 1
        fi
    done
}

delete() {
    # DELETE THE STACK:
    aws cloudformation delete-stack --stack-name ConfigToHdfStack
}

stack_update() {
    aws cloudformation package \
      --template-file ./cloud-formation/ConfigToHdf.yaml \
      --s3-bucket config-to-hdf-bucket-il5 \
      --output-template-file ./cloud-formation/packaged-ConfigToHdf.yaml

    # UPDATE THE STACK:
    aws cloudformation update-stack \
      --template-body file://cloud-formation/packaged-ConfigToHdf.yaml \
      --stack-name ConfigToHdfStack \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=HeimdallUrl,ParameterValue=$HeimdallUrl \
                   ParameterKey=HeimdallApiUser,ParameterValue=$HeimdallApiUser \
                   ParameterKey=HeimdallApiPass,ParameterValue=$HeimdallApiPass \
                   ParameterKey=HeimdallEvalTag,ParameterValue=$HeimdallEvalTag \
                   ParameterKey=SubnetIdA,ParameterValue=$SubnetIdA \
                   ParameterKey=SubnetIdB,ParameterValue=$SubnetIdB \
                   ParameterKey=VpcId,ParameterValue=$VpcId
}

update() {
    # PACKAGE THE LAMBDA CODE ZIP AND UPLOAD TO S3:
    ./script/build-lambda.sh
    stack_update
}

create() {
    # CREATE S3 BUCKET FOR LAMBDA CODE STORAGE:
    aws s3 mb s3://config-to-hdf-bucket-il5 || aws s3api head-bucket --bucket config-to-hdf-bucket-il5
    aws s3api put-public-access-block \
       --bucket config-to-hdf-bucket-il5 \
       --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    # PACKAGE THE LAMBDA CODE ZIP AND UPLOAD TO S3:
    ./script/build-lambda.sh
    aws cloudformation package \
      --template-file ./cloud-formation/ConfigToHdf.yaml \
      --s3-bucket config-to-hdf-bucket-il5 \
      --output-template-file ./cloud-formation/packaged-ConfigToHdf.yaml

    # CREATE THE STACK:
    aws cloudformation create-stack \
      --template-body file://cloud-formation/packaged-ConfigToHdf.yaml \
      --stack-name ConfigToHdfStack \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=HeimdallUrl,ParameterValue=$HeimdallUrl \
                   ParameterKey=HeimdallApiUser,ParameterValue=$HeimdallApiUser \
                   ParameterKey=HeimdallApiPass,ParameterValue=$HeimdallApiPass \
                   ParameterKey=HeimdallEvalTag,ParameterValue=$HeimdallEvalTag \
                   ParameterKey=SubnetIdA,ParameterValue=$SubnetIdA \
                   ParameterKey=SubnetIdB,ParameterValue=$SubnetIdB \
                   ParameterKey=VpcId,ParameterValue=$VpcId
}

if [[ "$1" == "create" ]]
then
    validate_env
    echo "Creating configToHdf stack..."
    create
elif [[ "$1" == "stack-update" ]]
then
    validate_env
    echo "Updating configToHdf stack..."
    stack_update
elif [[ "$1" == "update" ]]
then
    validate_env
    echo "Updating configToHdf stack..."
    update
elif [[ "$1" == "delete" ]]
then
    echo "Deleting configToHdf stack..."
    delete
else
    echo "No valid command was provided!\n"
    echo "Valid commands are:"
    echo "    $0 create"
    echo "    $0 update"
    echo "    $0 delete"
    echo "    $0 stack-update"
fi
