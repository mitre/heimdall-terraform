
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
  source = "../../../../../..//terraform/modules/saf-heimdall-rds"
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
    rds_password  = "Password123"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  env           = local.env
  deployment_id = dependency.random.outputs.deployment_id
  rds_passworld = dependency.random.outputs.rds_password
  vpc_id        = "vpc-01a2fdc59b149673d"
  subnet_ids    = ["subnet-062bf9f006ace2094","subnet-0003c65ebe8ce2124"]
  aws_region    = local.aws_region
  #Dev Config Inputs
  instance_class        = "db.t2.large" #encryption at rest is not supported for db.t2.micro
  deletion_protection   = true
  allocated_storage     = 60
  max_allocated_storage = 200
}