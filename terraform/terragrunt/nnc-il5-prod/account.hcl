# Set common variables for the aws account. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  account_name = "nnc-il5-vdms"
  account_id   = "597124939031"
  vpc_cidr     = "10.0.20.0/22"
  # permissions_boundary currently unused but may need in the future
  # permissions_boundary = "arn:aws-us-gov:iam::235856440647:policy/developer_boundary"
}