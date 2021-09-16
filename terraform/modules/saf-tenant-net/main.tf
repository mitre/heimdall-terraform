
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

#
# Network
#
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name}-${var.deployment_id}"
  cidr = var.vpc_cidr

  azs                   = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets        = local.public_subnet_cidrs
  public_subnet_suffix  = "public-saf-tenant-subnet"
  private_subnets       = local.private_subnet_cidrs
  private_subnet_suffix = "private-saf-tenant-subnet"


#Disabled for nnc-offline test
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Prevent creation of EIPs for NAT gateways
  reuse_nat_ips = false

  
  tags = {
    Name = "${local.name}-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    Project = local.name,
  }
}

