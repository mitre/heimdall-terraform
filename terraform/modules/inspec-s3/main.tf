
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

  # S3 managed encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "inspec-profiles-bucket-${var.env}-${var.deployment_id}"
    Environment = var.env
  }
}

##
# Block all public access
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
#
resource "aws_s3_bucket_public_access_block" "inspec_profiles_bucket_public_policy" {
  bucket = aws_s3_bucket.inspec_profiles_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

##
# S3 Bucket for storing InSpec results
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
resource "aws_s3_bucket" "inspec_results_bucket" {
  bucket = "inspec-results-bucket-${var.env}-${var.deployment_id}"
  acl    = "private"

  # S3 managed encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "inspec-results-bucket-${var.env}-${var.deployment_id}"
    Environment = var.env
  }
}

##
# Block all public access
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
#
resource "aws_s3_bucket_public_access_block" "inspec_results_bucket_public_policy" {
  bucket = aws_s3_bucket.inspec_results_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}