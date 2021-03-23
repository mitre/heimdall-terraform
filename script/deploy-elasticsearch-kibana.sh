
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-vpc.html
# https://stackoverflow.com/questions/30174114/aws-create-vpc-and-launch-instance
# nnc-aws-rdk-controls-vpc
# Create VPC
# export vpcId=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text`
# echo "VPC ID: $vpcId"

# DNS resolution
# aws ec2 modify-vpc-attribute --vpc-id $vpcId --enable-dns-support "{\"Value\":true}"
# aws ec2 modify-vpc-attribute --vpc-id $vpcId --enable-dns-hostnames "{\"Value\":true}"

# Internet gateway
# export internetGatewayId=`aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text`
# echo "INET GATEWAY ID: $internetGatewayId"
# aws ec2 attach-internet-gateway --internet-gateway-id $internetGatewayId --vpc-id $vpcId

# Subnet
# subnetId=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/24 --query 'Subnet.SubnetId' --output text`
# echo "SUBNET ID: $subnetId"

# Routing Table
# routeTableId=`aws ec2 create-route-table --vpc-id $vpcId --query 'RouteTable.RouteTableId' --output text`
# echo "ROUTE TABLE ID: $routeTableId"
# aws ec2 associate-route-table --route-table-id $routeTableId --subnet-id $subnetId
# aws ec2 create-route --route-table-id $routeTableId --destination-cidr-block 0.0.0.0/0 --gateway-id $internetGatewayId

# Security Group
# Allow 80, 443
# securityGroupId=`aws ec2 create-security-group --group-name nnc-aws-rdk-controls-secgroup --description "security group" --vpc-id $vpcId --query 'GroupId' --output text`
# echo "SECURITY GROUP ID: $securityGroupId"
# aws ec2 authorize-security-group-ingress --group-id $securityGroupId --protocol tcp --port 22 --cidr 0.0.0.0/0
# aws ec2 authorize-security-group-ingress --group-id $securityGroupId --protocol tcp --port 443 --cidr 0.0.0.0/0
# echo "CREATED INGRESS SECURITY GROUP RULES"


# https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instances.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html
# Create key pair
# if [ ! -f "./keys/nnc-aws-rdk-controls-ec2-key.pub" ]
#     ssh-keygen -t rsa -C "nnc-aws-rdk-controls-ec2-key" -f ./keys/nnc-aws-rdk-controls-ec2-key -P ''
# fi
# aws import-key-pair \
#     --key-name nnc-aws-rdk-controls-ec2-key \
#     --public-key-material $(cat ./keys/nnc-aws-rdk-controls-ec2-key.pub)

# EC2 Instance to hop traffic through
# Red Hat Enterprise Linux 8 (HVM), SSD Volume Type - ami-57ecd436
# Ubuntu Server 20.04 LTS (HVM), SSD Volume Type - ami-84556de5
# aws ec2 run-instances \
#     --image-id ami-57ecd436 \
#     --count 1 \
#     --instance-type t2.micro \
#     --key-name MyKeyPair \
#     --security-group-ids $securityGroupId \
#     --subnet-id $subnetId



# consider
# - fine grained access control
# - IAM permissions only for lambda user to push in data
# https://docs.aws.amazon.com/pt_br/cli/latest/reference/es/create-elasticsearch-domain.html
# Create Elasticsearch
aws create-elasticsearch-domain \
--domain-name 'nnc-aws-rdk-controls-es' \
--elasticsearch-version '7.9' \
--elasticsearch-cluster-config 'InstanceType=t3.small.elasticsearch,InstanceCount=1' \
--ebs-options value \
--access-policies value \
--snapshot-options value \
--vpc-options "SubnetIds=$vpcId,SecurityGroupIds=$securityGroupId" \
--encryption-at-rest-options 'Enabled=true' \
--node-to-node-encryption-options 'Enabled=boolean' \
--advanced-options value \
--log-publishing-options value \
--domain-endpoint-options value \
--advanced-security-options value \
--cli-input-json value \
--generate-cli-skeleton value \


echo "ssh -i ./keys/nnc-aws-rdk-controls-ec2-key ec2-user@your-ec2-instance-public-ip -N -L 9200:vpc-your-amazon-es-domain.region.es.amazonaws.com:443"

