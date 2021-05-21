
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}


##
# S3 bucket for storing InSpec profiles
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
resource "aws_s3_bucket" "inspec_profiles_bucket" {
  bucket = "inspec-profiles-bucket-${var.env}-${var.deployment_id}"
  acl    = "private"

  tags = {
    Name        = "inspec-profiles-bucket-${var.env}-${var.deployment_id}"
    Environment = var.env
  }
}

##
# S3 Bucket for storing InSpec results
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
resource "aws_s3_bucket" "inspec_results_bucket" {
  bucket = "inspec-results-bucket-${var.env}-${var.deployment_id}"
  acl    = "private"

  tags = {
    Name        = "inspec-results-bucket-${var.env}-${var.deployment_id}"
    Environment = var.env
  }
}