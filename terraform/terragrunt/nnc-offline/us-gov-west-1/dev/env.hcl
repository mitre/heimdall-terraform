# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment = "nncoffline"
  vpc_id = "vpc-093d480a83c754bcf" #Example!
  public_subnet_ids = ["subnet-0820cf6cc76c47ab5","subnet-0e61e626dbd8b5525"] #Example!
  private_subnet_ids = ["subnet-0444c5b06c016bfd2","subnet-01450c10732e919ce"] #Example!
}
