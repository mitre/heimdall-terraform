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
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/inspec-ssm"
}

dependency "random" {
  config_path = "../random"

  mock_outputs = {
    deployment_id = "000"
    rds_password  = "Password123"
  }
}

dependency "inspec-s3" {
  config_path = "../inspec-s3"

  mock_outputs = {
    inspec_profiles_bucket_name  = "dummy-bucket-name"
    inspec_results_bucket_name   = "dummy-bucket-name"
    inspec_rhel7_baseline_s3_key = "dummy-s3-key"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  deployment_id                  = dependency.random.outputs.deployment_id
  inspec_s3_bucket_name          = dependency.inspec-s3.outputs.inspec_results_bucket_name
  inspec_rhel7_baseline_s3_key   = dependency.inspec-s3.outputs.inspec_rhel7_baseline_s3_key
}
