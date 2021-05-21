# Set common variables for the aws account. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  account_name = "nnc-master"
  account_id   = "060708420889"
  vpc_cidr     = "172.18.0.0/16"
  # permissions_boundary currently unused but may need in the future
  # permissions_boundary = "arn:aws-us-gov:iam::235856440647:policy/developer_boundary"
}