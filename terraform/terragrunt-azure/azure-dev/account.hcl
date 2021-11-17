# Set common variables for the aws account. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  account_name = "nnc-azure-dev"
  subscription_id = "d81abeb0-80db-432b-b6f9-bfed4ac3189b"
  environment = "usgovernment"
}