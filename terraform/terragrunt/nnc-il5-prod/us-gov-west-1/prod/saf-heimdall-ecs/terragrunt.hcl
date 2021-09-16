
locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))

  env                = local.environment_vars.locals.environment
  aws_region         = local.region_vars.locals.aws_region
  vpc_id             = local.environment_vars.locals.vpc_id
  public_subnet_ids  = local.environment_vars.locals.public_subnet_ids
  private_subnet_ids = local.environment_vars.locals.private_subnet_ids
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/saf-heimdall-ecs"
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

dependency "saf-heimdall-rds" {
  config_path = "../saf-heimdall-rds"

  mock_outputs = {
    rds_endpoint  = "temporary-dummy-id"
    rds_db_name   = "temporary-dummy-name"
    rds_user_name = "temporary-dummy-user-name"
    rds_password  = "temporary-dummy-password"
    rds_sg_id     = "temporary-dummy-id"
  }
}

dependency "saf-heimdall-alb" {
  config_path = "../saf-heimdall-alb"

  mock_outputs = {
    public_alb_target_group_id  = "arn:aws-us-gov:iam::123456789000:service/resource"
    private_alb_target_group_id = "arn:aws-us-gov:iam::123456789000:service/resource"
    SafHeimdallContainerCommsSG = "temporary-dummy-id"
  }
}

dependency "saf-heimdall-ecr" {
  config_path = "../saf-heimdall-ecr"

  mock_outputs = {
    heimdall_image   = "dummy-image-url"
    heimdall_ecr_arn = "arn:aws-us-gov:iam::123456789000:service/resource"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  env              = local.env
  deployment_id    = dependency.random.outputs.deployment_id
  vpc_id           = local.vpc_id
  subnet_ids       = local.private_subnet_ids # This used to be the public nets but DEV and IL6 are set to private
  aws_region       = local.aws_region
  heimdall_image   = dependency.saf-heimdall-ecr.outputs.heimdall_image
  heimdall_ecr_arn = dependency.saf-heimdall-ecr.outputs.heimdall_ecr_arn
  rds_endpoint     = dependency.saf-heimdall-rds.outputs.rds_endpoint
  rds_db_name      = dependency.saf-heimdall-rds.outputs.rds_db_name
  rds_user_name    = dependency.saf-heimdall-rds.outputs.rds_user_name
  rds_password     = dependency.saf-heimdall-rds.outputs.rds_password

  s3VpcEndpointPrefixListCidr = dependency.saf-tenant-endpoints.outputs.s3VpcEndpointPrefixListCidr

  ecs_security_group_ids = [
    dependency.saf-heimdall-rds.outputs.rds_sg_id,
    dependency.saf-heimdall-alb.outputs.SafHeimdallContainerCommsSG,
    dependency.saf-tenant-security-groups.outputs.SafHTTPCommsSG_id
  ]

  vpcEndpoint_security_group = dependency.saf-tenant-security-groups.outputs.SafHTTPCommsSG_id

  public_alb_target_group_id  = dependency.saf-heimdall-alb.outputs.public_alb_target_group_id
  private_alb_target_group_id = dependency.saf-heimdall-alb.outputs.private_alb_target_group_id

}