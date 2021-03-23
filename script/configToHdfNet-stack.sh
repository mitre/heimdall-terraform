
set -e

delete() {
    # DELETE THE STACK:
    aws cloudformation delete-stack --stack-name ConfigToHdfNetNetStack
}

update() {
    aws cloudformation update-stack \
      --template-body file://cloud-formation/ConfigToHdfNet.yaml \
      --stack-name ConfigToHdfNetStack
}

create() {
    aws cloudformation create-stack \
      --template-body file://cloud-formation/ConfigToHdfNet.yaml \
      --stack-name ConfigToHdfNetStack
}


if [[ "$1" == "create" ]]
then
    echo "Creating configToHdfNet stack..."
    create
elif [[ "$1" == "update" ]]
then
    echo "Updating configToHdfNet stack..."
    update
elif [[ "$1" == "delete" ]]
then
    echo "Deleting configToHdfNet stack..."
    delete
else
    echo "No valid command was provided!\n"
    echo "Valid commands are:"
    echo "    $0 create"
    echo "    $0 update"
    echo "    $0 delete"
fi
