
locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/azure-saf-heimdall-db"
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

dependency "saf-tenant-net" {
  config_path = "../saf-tenant-net"

  mock_outputs = {
    vnet_id             = "temporary-dummy-id"
    subnet_private_id = "temporary-dummy-private-subnet"
    resource_group_name = ""
    resource_group_location = ""
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  #env           = local.env
  deployment_id = dependency.random.outputs.deployment_id
  db_passworld = dependency.random.outputs.rds_password
  vnet_id        = dependency.saf-tenant-net.outputs.vnet_id
  subnet_id                 = dependency.saf-tenant-net.outputs.subnet_private_id
  resource_group_location    = dependency.saf-tenant-net.outputs.resource_group_location
  resource_group_name = dependency.saf-tenant-net.outputs.resource_group_name
}