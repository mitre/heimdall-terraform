
locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))

  env        = local.environment_vars.locals.environment
  aws_region = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/saf-heimdall-alb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


# Define any dependencies from other modules 
dependency "random" {
  config_path = "../random"

  mock_outputs = {
    deployment_id = "000"
  }
}

dependency "saf-tenant-net" {
  config_path = "../saf-tenant-net"

  mock_outputs = {
    vpc_id             = "temporary-dummy-id"
    public_subnet_ids  = ["temporary-dummy-public-subnet"]
    private_subnet_ids = ["temporary-dummy-private-subnet"]
  }
}

dependency "saf-tenant-security-groups" {
  config_path = "../saf-tenant-security-groups"

  mock_outputs = {
    SafHTTPCommsSG_id = "temporary-dummy-sg-id"
  }
}

dependency "saf-tenant-endpoints" {
  config_path = "../saf-tenant-endpoints"

  mock_outputs = {
    s3VpcEndpointPrefixListCidr = "0.0.0.0/0"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  env                = local.env
  deployment_id      = dependency.random.outputs.deployment_id
  vpc_id             = dependency.saf-tenant-net.outputs.vpc_id
  public_subnet_ids  = dependency.saf-tenant-net.outputs.public_subnet_ids
  private_subnet_ids = dependency.saf-tenant-net.outputs.private_subnet_ids
  addl_alb_sg_ids    = [dependency.saf-tenant-security-groups.outputs.SafHTTPCommsSG_id]
  aws_region         = local.aws_region
}