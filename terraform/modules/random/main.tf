
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# Random String to Tag Deployment Resources
#
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
#
resource "random_string" "deployment_id" {
  length  = var.random_string_length
  special = false
  upper   = false
}

##
# Random Password for RDS
#
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
#
resource "random_password" "rds_password" {
  length  = var.random_string_length
  special = true
  upper   = true
  lower   = true
}