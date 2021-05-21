
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}


##
# SSM association for RHEL7 baseline STIG
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association
#
# https://aws.amazon.com/getting-started/hands-on/remotely-run-commands-ec2-instance-systems-manager/
# - Managed instances require the `AmazonEC2RoleforSSM` policy assigned to the IAM role
#
# https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-prereqs.html
#
# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-rhel.html
# - Managed instances require the SSM agent software to be installed (region must be set correctly)
#     sudo yum install -y https://s3.us-gov-west-1.amazonaws.com/amazon-ssm-us-gov-west-1/latest/linux_amd64/amazon-ssm-agent.rpm
#     sudo systemctl enable amazon-ssm-agent
#     sudo systemctl start amazon-ssm-agent
# - Managed instances require HTTPS access to SSM (either through public internet or through a VPC endpoint)
#
# NOTE:
# It appears that running InSpec via SSM and outputting to and S3 bucket does not output files that are 
# digestable by heimdall. It appears that it only exports the stdout and stderr from running the InSpec profile.
resource "aws_ssm_association" "rhel7-stig-baseline-SSM" {
  name             = "AWS-RunInspecChecks-${var.deployment_id}"
  association_name = "AWS-RunInspecChecks-${var.deployment_id}"

  schedule_expression = var.inspec_rhel7_baseline_schedule

  parameters = {
    sourceType = "[\"S3\"]"
    sourceInfo = "[\"{ \"path\": \"${var.inspec_rhel7_baseline_s3_key}\" }\"]"
  }

  targets {
    key    = "tag:rhel7-stig-baseline"
    values = ["true"]
  }

  output_location {
    s3_bucket_name = var.inspec_s3_bucket_name
    s3_key_prefix = "rhel7-stig-baseline/"
  }
}
