
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# S3 VPC Endpoint for ECR access
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
#
resource "aws_vpc_endpoint" "s3VpcEndpoint" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = {
    Name = "s3VpcEndpoint-${var.deployment_id}"
  }
}

##
# Prefix list data fetch for usage in adding Egress rule to the HTTP comms SG
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/prefix_list
#
data "aws_prefix_list" "s3VpcEndpointPrefixList" {
  prefix_list_id = aws_vpc_endpoint.s3VpcEndpoint.prefix_list_id
}

##
# ConfigToHdf AWS SSM VPC Endpoint for accessing password SSM parameter
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
#
resource "aws_vpc_endpoint" "ConfigToHdfSsmVpcEndpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_groups

  private_dns_enabled = true

  tags = {
    Name = "ConfigToHdfSsmVpcEndpoint-${var.deployment_id}"
  }
}

##
# ConfigToHdf AWS Config VPC Endpoint
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
#
resource "aws_vpc_endpoint" "ConfigToHdfConfigVpcEndpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.config"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_groups

  private_dns_enabled = true

  tags = {
    Name = "ConfigToHdfConfigVpcEndpoint-${var.deployment_id}"
  }
}

##
# Cloud Watch VPC Endpoint
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
#
resource "aws_vpc_endpoint" "CloudWatchVpcEndpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids
  security_group_ids = [var.security_groups]

  private_dns_enabled = true

  tags = {
    Name = "ConfigToHdfSsmVpcEndpoint-${var.deployment_id}"
  }
}

##
# ECR DKR VPC Endpoint
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
#
resource "aws_vpc_endpoint" "EcrDkrVpcEndpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids
  security_group_ids = [var.security_groups]

  private_dns_enabled = true

  tags = {
    Name = "EcrDkrVpcEndpoint-${var.deployment_id}"
  }
}

##
# ECR API VPC Endpoint
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
#
resource "aws_vpc_endpoint" "EcrApiVpcEndpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids
  security_group_ids = [var.security_groups]

  private_dns_enabled = true

  tags = {
    Name = "EcrApiVpcEndpoint-${var.deployment_id}"
  }
}