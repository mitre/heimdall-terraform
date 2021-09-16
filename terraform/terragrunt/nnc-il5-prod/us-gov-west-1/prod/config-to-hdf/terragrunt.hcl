# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))

  # Extract out common variables for reuse
  env                = local.environment_vars.locals.environment
  aws_region         = local.region_vars.locals.aws_region
  vpc_id             = local.environment_vars.locals.vpc_id
  public_subnet_ids  = local.environment_vars.locals.public_subnet_ids
  private_subnet_ids = local.environment_vars.locals.private_subnet_ids
  account_name       = local.account_vars.locals.account_name

  exec_multi_path  = abspath("../../../../../lambda/ConfigToHdf/function.zip")
  exec_single_path = abspath("../../../../../../lambda/ConfigToHdf/function.zip")
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/config-to-hdf"
}

dependency "random" {
  config_path = "../random"

  mock_outputs = {
    deployment_id = "000"
    rds_password  = "Password123"
  }
}

# Define any dependencies from other modules 
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

dependency "saf-heimdall-alb" {
  config_path = "../saf-heimdall-alb"

  mock_outputs = {
    private_alb_address = "http://nonexistentheimdall.aws.gov"
  }
}

dependency "inspec-s3" {
  config_path = "../inspec-s3"

  mock_outputs = {
    inspec_results_bucket_name = "dummy_bucket_name"
  }
}

dependency "heimdall-pusher" {
  config_path = "../heimdall-pusher"

  mock_outputs = {
    function_arn = "arn:aws-us-gov:iam::123456789000:service/resource"
  }
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  deployment_id    = dependency.random.outputs.deployment_id
  env              = local.env
  vpc_id           = local.vpc_id
  subnet_ids       = local.private_subnet_ids

  ConfigToHdf_security_groups       = [dependency.saf-tenant-security-groups.outputs.SafHTTPCommsSG_id]

  aws_region   = local.aws_region
  account_name = local.account_name

  heimdall_pusher_lambda_arn = dependency.heimdall-pusher.outputs.function_arn

  function_zip_path = fileexists(local.exec_multi_path) ? local.exec_multi_path : local.exec_single_path

  results_bucket_id = dependency.inspec-s3.outputs.inspec_results_bucket_name
}
