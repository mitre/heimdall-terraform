##
# S3 bucket for storing InSpec profiles
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
resource "aws_s3_bucket" "elb_logging_bucket" {
  bucket = "heimdall-elb-logging-${var.env}-${var.deployment_id}"
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = "heimdall-elb-logging-${var.env}-${var.deployment_id}"
    Environment = var.env
    Owner   = basename(data.aws_caller_identity.current.arn)
    Project = local.name
  }
}

resource "aws_s3_bucket_policy" "elb_logging_bucket_policy" {
  bucket = aws_s3_bucket.elb_logging_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}