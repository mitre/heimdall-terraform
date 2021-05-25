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
  env          = local.environment_vars.locals.environment
  aws_region   = local.region_vars.locals.aws_region
  account_name = local.account_vars.locals.account_name

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
dependency "saf-tenant-net" {
  config_path = "../saf-tenant-net"

  mock_outputs = {
    vpc_id             = "temporary-dummy-id"
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

dependency "saf-heimdall-alb" {
  config_path = "../saf-heimdall-alb"

  mock_outputs = {
    private_alb_address = "http://nonexistentheimdall.aws.gov"
  }
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  deployment_id    = dependency.random.outputs.deployment_id
  env              = local.env
  vpc_id           = dependency.saf-tenant-net.outputs.vpc_id
  subnet_ids       = dependency.saf-tenant-net.outputs.private_subnet_ids

  ConfigToHdf_security_groups       = [dependency.saf-tenant-security-groups.outputs.SafHTTPCommsSG_id]

  aws_region   = local.aws_region
  account_name = local.account_name

  heimdall_url      = "http://${dependency.saf-heimdall-alb.outputs.private_alb_address}"
  heimdall_user     = "configToHdf@example.com"
  heimdall_password = "foobar"
  heimdall_eval_tag = "ConfigToHdf,${local.account_name}"

  function_zip_path = fileexists(local.exec_multi_path) ? local.exec_multi_path : local.exec_single_path
}
