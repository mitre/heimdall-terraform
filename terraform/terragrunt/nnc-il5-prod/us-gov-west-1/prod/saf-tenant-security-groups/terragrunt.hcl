
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../..//terraform/modules/saf-tenant-security-groups"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  vpc_id = "vpc-01a2fdc59b149673d"
}