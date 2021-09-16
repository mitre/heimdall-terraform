
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}


##
# Heimdall Pusher Lambda function
#
# https://github.com/mitre/serverless-heimdall-pusher-lambda
#
module "serverless-heimdall-pusher-lambda" {
  source = "github.com/mitre/serverless-heimdall-pusher-lambda"
  heimdall_url      = var.heimdall_url
  heimdall_user     = var.heimdall_user
  heimdall_password = var.heimdall_password
  results_bucket_id = var.results_bucket_id
  subnet_ids        = var.subnet_ids
  security_groups   = var.security_groups
  lambda_name       = "HeimdallPusher-${var.deployment_id}"
}

