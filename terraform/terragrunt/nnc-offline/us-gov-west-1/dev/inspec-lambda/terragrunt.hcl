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

  vpc_id        = local.environment_vars.locals.vpc_id
  public_subnet_ids = local.environment_vars.locals.public_subnet_ids
  private_subnet_ids = local.environment_vars.locals.private_subnet_ids

  exec_dockerfile_multi_path  = abspath("../../../../../lambda/InSpec/Dockerfile")
  exec_multi_path  = abspath("../../../../../lambda/InSpec/")
  exec_single_path = abspath("../../../../../../lambda/InSpec/")
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/serverless-inspec-lambda"
}

dependency "random" {
  config_path = "../random"

  mock_outputs = {
    deployment_id = "000"
    rds_password  = "Password123"
  }
}

dependency "saf-tenant-security-groups" {
  config_path = "../saf-tenant-security-groups"

  mock_outputs = {
    SafHTTPCommsSG_id  = "temporary-dummy-sg-id"
    SafEgressOnlySG_id = "temporary-dummy-sg-id"
  }
}

dependency "saf-tenant-endpoints" {
  config_path = "../saf-tenant-endpoints"

  mock_outputs = {
    s3VpcEndpointPrefixListCidr = "0.0.0.0/0"
  }
}

dependency "inspec-s3" {
  config_path = "../inspec-s3"

  mock_outputs = {
    inspec_profiles_bucket_arn = "arn:aws-us-gov:iam::123456789000:service/resource"
    inspec_results_bucket_arn  = "arn:aws-us-gov:iam::123456789000:service/resource"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  subnet_ids          = local.private_subnet_ids
  security_groups     = [
    dependency.saf-tenant-security-groups.outputs.SafHTTPCommsSG_id,
    dependency.saf-tenant-security-groups.outputs.SafEgressOnlySG_id
  ]
  deployment_id       = dependency.random.outputs.deployment_id
  profiles_bucket_arn = dependency.inspec-s3.outputs.inspec_profiles_bucket_arn
  results_bucket_arn  = dependency.inspec-s3.outputs.inspec_results_bucket_arn
}
