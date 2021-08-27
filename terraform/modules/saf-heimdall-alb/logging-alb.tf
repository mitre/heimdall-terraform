##
# S3 bucket for storing InSpec profiles
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
resource "aws_s3_bucket" "elb_logging_bucket" {
  bucket = "heimdall-elb-logging-${var.env}-${var.deployment_id}"
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
    Name        = "heimdall-elb-logging-${var.env}-${var.deployment_id}"
    Environment = var.env
    Owner   = basename(data.aws_caller_identity.current.arn)
    Project = local.name
  }
}

##
# Block all public access
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
#
resource "aws_s3_bucket_public_access_block" "elb_logging_bucket_public_policy" {
  bucket = aws_s3_bucket.elb_logging_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "elb_logging_bucket_policy" {
  bucket = aws_s3_bucket.elb_logging_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}