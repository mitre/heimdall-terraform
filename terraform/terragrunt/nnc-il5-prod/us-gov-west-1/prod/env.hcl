# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment = "prod"
  vpc_id = "vpc-01a2fdc59b149673d"
  public_subnet_ids = ["subnet-02744fc6e1d1e10b3","subnet-013ebd52c1d4b2f4f"]
  private_subnet_ids = ["subnet-062bf9f006ace2094","subnet-0003c65ebe8ce2124"]
}
