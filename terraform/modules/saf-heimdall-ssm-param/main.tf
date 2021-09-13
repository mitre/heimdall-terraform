
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# SSM Key Pair for RDS Password
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
# https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
#
resource "aws_ssm_parameter" "rds_password" {
  name        = "/heimdall${var.deployment_id}/database/password/master"
  description = "Password to the Heimdall RDS database."
  type        = "SecureString"
  value       = var.rds_password

  tags = {
    Name = "${local.name}-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    Project = local.name,
  }
}

