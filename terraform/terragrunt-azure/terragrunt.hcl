# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  azure_region   = local.region_vars.locals.azure_region
  account_name = local.account_vars.locals.account_name
  subscription_id = local.account_vars.locals.subscription_id
  environment = local.account_vars.locals.environment
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
#remote_state {
#  backend = "s3"
#  config = {
#    encrypt        = true
#    bucket         = "saf-${local.account_name}-${local.aws_region}-tf-states"
#    key            = "${path_relative_to_include()}/terraform.tfstate"
#    region         = local.aws_region
#    dynamodb_table = "saf-${local.account_name}-${local.aws_region}-state-locks"
#  }
  # generate = {
  #   path      = "backend.tf"
  #   if_exists = "overwrite_terragrunt"
  # }
#}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
#  client_id       = "<REPLACE_WITH_APP_ID>"
#  client_secret   = "<REPLACE_WITH_PASSWORD>"
#  tenant_id       = "<REPLACE_WITH_TENANT_ID>"
  environment     = "${local.environment}"
}
EOF
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.environment_vars.locals,
)