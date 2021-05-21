
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

############################
# Config Rule Dependencies #
############################

##
# Configuration Recorder for the environment
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder
#
# resource "aws_config_configuration_recorder" "config_recorder" {
#   name     = "AwsConfigRecorder"
#   role_arn = aws_iam_role.config_iam_role.arn
# }

# resource "aws_iam_role" "config_iam_role" {
#   name = "AwsServiceRoleForConfig"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "config.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy" "aws_config_put_policy" {
#   name = "aws_config_put_policy"
#   role = aws_iam_role.config_iam_role.id

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#       {
#           "Action": "config:Put*",
#           "Effect": "Allow",
#           "Resource": "*"

#       }
#   ]
# }
# POLICY
# }

########################
# Managed Config Rules #
########################

resource "aws_config_config_rule" "cloud-trail-encryption-enabled" {
  name             = "cloud-trail-encryption-enabled"
  description      = "Checks whether AWS CloudTrail is configured to use the server side encryption (SSE) AWS Key Management Service (AWS KMS) customer master key (CMK) encryption. The rule is compliant if the KmsKeyId is defined."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "CloudTrail"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "guardduty-non-archived-findings" {
  name             = "guardduty-non-archived-findings"
  description      = "Checks whether Amazon GuardDuty has findings that are non archived. The rule is NON_COMPLIANT if Amazon GuardDuty has non archived low/medium/high severity findings older than the specified number in the daysLowSev/daysMediumSev/daysHighSev parameter."
  input_parameters = "{ \"daysLowSev\": \"30\", \"daysMediumSev\": \"7\", \"daysHighSev\": \"1\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "GuardDuty"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_NON_ARCHIVED_FINDINGS"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "cloudwatch-alarm-action-check" {
  name             = "cloudwatch-alarm-action-check"
  description      = "Checks whether CloudWatch alarms have at least one alarm action, one INSUFFICIENT_DATA action, or one OK action enabled. Optionally, checks whether any of the actions matches one of the specified ARNs."
  input_parameters = "{ \"alarmActionRequired\": \"true\",\"insufficientDataActionRequired\": \"true\",\"okActionRequired\": \"false\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "CloudWatch"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_ALARM_ACTION_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "emr-master-no-public-ip" {
  name             = "emr-master-no-public-ip"
  description      = "Checks whether Amazon Elastic MapReduce (EMR) clusters' master nodes have public IPs. The rule is NON_COMPLIANT if the master node has a public IP."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EMR"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EMR_MASTER_NO_PUBLIC_IP"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "lambda-function-public-access-prohibited" {
  name             = "lambda-function-public-access-prohibited"
  description      = "Checks whether the Lambda function policy prohibits public access."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Lambda"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "LAMBDA_FUNCTION_PUBLIC_ACCESS_PROHIBITED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-account-level-public-access-blocks" {
  name             = "s3-account-level-public-access-blocks"
  description      = "Checks whether the required public access block settings are configured from account level. The rule is NON_COMPLIANT when the public access block settings are not configured from account level."
  input_parameters = "{ \"IgnorePublicAcls\": \"true\", \"BlockPublicPolicy\": \"true\", \"BlockPublicAcls\": \"true\", \"RestrictPublicBuckets\": \"true\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "vpc-default-security-group-closed" {
  name             = "vpc-default-security-group-closed"
  description      = "Checks that the default security group of any Amazon Virtual Private Cloud (VPC) does not allow inbound or outbound traffic. The rule is non-compliant if the default security group has one or more inbound or outbound traffic."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-password-policy" {
  name             = "iam-password-policy"
  description      = "Checks whether the account password policy for IAM users meets the specified requirements indicated in the parameters. This rule is NON_COMPLIANT if the account password policy does not meet the specified requirements."
  input_parameters = "{ \"RequireUppercaseCharacters\": \"true\", \"RequireLowercaseCharacters\": \"true\", \"RequireSymbols\": \"true\", \"RequireNumbers\": \"true\", \"MinimumPasswordLength\": \"14\", \"PasswordReusePrevention\": \"24\", \"MaxPasswordAge\": \"90\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "cmk-backing-key-rotation-enabled" {
  name             = "cmk-backing-key-rotation-enabled"
  description      = "Checks that key rotation is enabled for each key and matches to the key ID of the customer created customer master key (CMK). The rule is compliant, if the key rotation is enabled for specific key object."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "KMS"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CMK_BACKING_KEY_ROTATION_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "internet-gateway-authorized-vpc-only" {
  name             = "internet-gateway-authorized-vpc-only"
  description      = "Checks that Internet gateways (IGWs) are only attached to an authorized Amazon Virtual Private Cloud (VPCs). The rule is NON_COMPLIANT if IGWs are not attached to an authorized VPC."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IGW"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "INTERNET_GATEWAY_AUTHORIZED_VPC_ONLY"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "elasticsearch-node-to-node-encryption-check" {
  name             = "elasticsearch-node-to-node-encryption-check"
  description      = "Check that Amazon ElasticSearch Service nodes are encrypted end to end. The rule is NON_COMPLIANT if the node-to-node encryption is disabled on the domain."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Elasticsearch"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ELASTICSEARCH_NODE_TO_NODE_ENCRYPTION_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "ec2-instance-managed-by-systems-manager" {
  name             = "ec2-instance-managed-by-systems-manager"
  description      = "Checks whether the Amazon EC2 instances in your account are managed by AWS Systems Manager."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "lambda-inside-vpc" {
  name             = "lambda-inside-vpc"
  description      = "Checks whether an AWS Lambda function is in an Amazon Virtual Private Cloud. The rule is NON_COMPLIANT if the Lambda function is not in a VPC."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Lambda"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "LAMBDA_INSIDE_VPC"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "rds-instance-public-access-check" {
  name             = "rds-instance-public-access-check"
  description      = "Checks whether the Amazon Relational Database Service (RDS) instances are not publicly accessible. The rule is non-compliant if the publiclyAccessible field is true in the instance configuration item."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "RDS"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "ec2-managedinstance-association-compliance-status-check" {
  name             = "ec2-managedinstance-association-compliance-status-check"
  description      = "Checks whether the compliance status of the AWS Systems Manager association compliance is COMPLIANT or NON_COMPLIANT after the association execution on the instance. The rule is compliant if the field status is COMPLIANT."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EC2_MANAGEDINSTANCE_ASSOCIATION_COMPLIANCE_STATUS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "elasticsearch-in-vpc-only" {
  name             = "elasticsearch-in-vpc-only"
  description      = "Checks whether Amazon Elasticsearch Service domains are in Amazon Virtual Private Cloud (VPC). The rule is NON_COMPLIANT if ElasticSearch Service domain endpoint is public."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Elasticsearch"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ELASTICSEARCH_IN_VPC_ONLY"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "rds-logging-enabled" {
  name             = "rds-logging-enabled"
  description      = "Checks that respective logs of Amazon Relational Database Service (Amazon RDS) are enabled. The rule is NON_COMPLIANT if any log types are not enabled."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "RDS"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "ec2-instance-detailed-monitoring-enabled" {
  name             = "ec2-instance-detailed-monitoring-enabled"
  description      = "Checks whether detailed monitoring is enabled for EC2 instances."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-user-group-membership-check" {
  name             = "iam-user-group-membership-check"
  description      = "Checks whether IAM users are members of at least one IAM group."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_GROUP_MEMBERSHIP_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "elb-tls-https-listeners-only" {
  name             = "elb-tls-https-listeners-only"
  description      = "Checks whether your Classic Load Balancer's listeners are configured with SSL or HTTPS"
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Elastic Load Balancer"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ELB_TLS_HTTPS_LISTENERS_ONLY"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "ec2-managedinstance-patch-compliance-status-check" {
  name             = "ec2-managedinstance-patch-compliance-status-check"
  description      = "Checks whether the compliance status of the AWS Systems Manager patch compliance is COMPLIANT or NON_COMPLIANT after the patch installation on the instance. The rule is compliant if the field status is COMPLIANT."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EC2_MANAGEDINSTANCE_PATCH_COMPLIANCE_STATUS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-user-unused-credentials-check" {
  name             = "iam-user-unused-credentials-check"
  description      = "Checks whether your AWS Identity and Access Management (IAM) users have passwords or active access keys that have not been used within the specified number of days you provided."
  input_parameters = "{ \"maxCredentialUsageAge\": \"90\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "restricted-ssh" {
  name             = "restricted-ssh"
  description      = "Checks whether security groups that are in use disallow unrestricted incoming SSH traffic."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "ebs-snapshot-public-restorable-check" {
  name             = "ebs-snapshot-public-restorable-check"
  description      = "Checks whether Amazon Elastic Block Store (Amazon EBS) snapshots are not publicly restorable. The rule is NON_COMPLIANT if one or more snapshots with RestorableByUserIds field are set to all, that is, Amazon EBS snapshots are public."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Elastic Block Store"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EBS_SNAPSHOT_PUBLIC_RESTORABLE_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "elb-acm-certificate-required" {
  name             = "elb-acm-certificate-required"
  description      = "This rule checks whether the Elastic Load Balancer(s) uses SSL certificates provided by AWS Certificate Manager. You must use an SSL or HTTPS listener with your Elastic Load Balancer to use this rule."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Elastic Load Blancer"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ELB_ACM_CERTIFICATE_REQUIRED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "emr-kerberos-enabled" {
  name             = "emr-kerberos-enabled"
  description      = "The rule is NON_COMPLIANT if a security configuration is not attached to the cluster or the security configuration does not satisfy the specified rule parameters."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EMR"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "EMR_KERBEROS_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "acm-certificate-expiration-check" {
  name             = "acm-certificate-expiration-check"
  description      = "Checks whether ACM Certificates in your account are marked for expiration within the specified number of days. Certificates provided by ACM are automatically renewed. ACM does not automatically renew certificates that you import."
  input_parameters = "{ \"daysToExpiration\": \"14\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "AWS Certificate Manager"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "guardduty-enabled-centralized" {
  name             = "guardduty-enabled-centralized"
  description      = "Checks whether GuardDuty is enabled. You can optionally verify that the results are centralized in a specific AWS Account."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "GuardDuty"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "redshift-require-tls-ssl" {
  name             = "redshift-require-tls-ssl"
  description      = "Checks whether Amazon Redshift clusters require TLS/SSL encryption to connect to SQL clients. The rule is NON_COMPLIANT if any Amazon Redshift cluster has parameter require_SSL not set to true."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Redshift"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "REDSHIFT_REQUIRE_TLS_SSL"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "cloud-trail-cloud-watch-logs-enabled" {
  name             = "cloud-trail-cloud-watch-logs-enabled"
  description      = "Checks whether AWS CloudTrail trails are configured to send logs to Amazon CloudWatch logs. The trail is non-compliant if the CloudWatchLogsLogGroupArn property of the trail is empty."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "CloudTrail : CloudWatch"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "alb-http-to-https-redirection-check" {
  name             = "alb-http-to-https-redirection-check"
  description      = "Checks whether HTTP to HTTPS redirection is configured on all HTTP listeners of Application Load Balancers. The rule is NON_COMPLIANT if one or more HTTP listeners of Application Load Balancer do not have HTTP to HTTPS redirection configured."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Application Load Balancer"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ALB_HTTP_TO_HTTPS_REDIRECTION_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-bucket-policy-grantee-check" {
  name             = "s3-bucket-policy-grantee-check"
  description      = "Checks that the access granted by the Amazon S3 bucket is restricted to any of the AWS principals, federated users, service principals, IP addresses, or VPCs that you provide. The rule is COMPLIANT if a bucket policy is not present."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_POLICY_GRANTEE_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "kms-cmk-not-scheduled-for-deletion" {
  name             = "kms-cmk-not-scheduled-for-deletion"
  description      = "Checks whether customer master keys (CMKs) are not scheduled for deletion in AWS Key Management Service (KMS). The rule is NON_COMPLAINT if CMKs are scheduled for deletion."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "KMS"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "KMS_CMK_NOT_SCHEDULED_FOR_DELETION"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "securityhub-enabled" {
  name             = "securityhub-enabled"
  description      = "Checks that AWS Security Hub is enabled for an AWS Account. The rule is NON_COMPLIANT if AWS Security Hub is not enabled."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Security Hub"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "SECURITYHUB_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "redshift-cluster-configuration-check" {
  name             = "redshift-cluster-configuration-check"
  description      = "Checks whether Amazon Redshift clusters have the specified settings."
  input_parameters = "{ \"clusterDbEncrypted\": \"true\", \"loggingEnabled\": \"true\", \"nodeTypes\": \"dc1.large\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Redshift"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "REDSHIFT_CLUSTER_CONFIGURATION_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "rds-snapshots-public-prohibited" {
  name             = "rds-snapshots-public-prohibited"
  description      = "AC-03_RDS_Snapshots_Public_Prohibited"
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "RDS"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "RDS_SNAPSHOTS_PUBLIC_PROHIBITED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "redshift-cluster-public-access-check" {
  name             = "redshift-cluster-public-access-check"
  description      = "Checks whether Amazon Redshift clusters are not publicly accessible. The rule is NON_COMPLIANT if the publicly accessible field is true in the cluster configuration item."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Redshift"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "REDSHIFT_CLUSTER_PUBLIC_ACCESS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "alb-http-drop-invalid-header-enabled" {
  name             = "alb-http-drop-invalid-header-enabled"
  description      = "Checks if rule evaluates AWS Application Load Balancers (ALB) to ensure they are configured to drop http headers. The rule is NON_COMPLIANT if the value of routing.http.drop_invalid_header_fields.enabled is set to false."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Application Load Balancer"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ALB_HTTP_DROP_INVALID_HEADER_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-user-no-policies-check" {
  name             = "iam-user-no-policies-check"
  description      = "Checks that none of your IAM users have policies attached. IAM users must inherit permissions from IAM groups or roles."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "dms-replication-not-public" {
  name             = "dms-replication-not-public"
  description      = "Checks whether AWS Database Migration Service replication instances are public. The rule is NON_COMPLIANT if PubliclyAccessible field is True."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Database Migration Service"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "DMS_REPLICATION_NOT_PUBLIC"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-bucket-public-write-prohibited" {
  name             = "s3-bucket-public-write-prohibited"
  description      = "Checks that your Amazon S3 buckets do not allow public write access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "cloudtrail-s3-dataevents-enabled" {
  name             = "cloudtrail-s3-dataevents-enabled"
  description      = "Checks whether at least one AWS CloudTrail trail is logging Amazon S3 data events for all S3 buckets. The rule is NON_COMPLIANT if trails log data events for S3 buckets is not configured."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CLOUDTRAIL_S3_DATAEVENTS_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "sagemaker-notebook-no-direct-internet-access" {
  name             = "sagemaker-notebook-no-direct-internet-access"
  description      = "Checks whether direct internet access is disabled for an Amazon SageMaker notebook instance. The rule is NON_COMPLIANT if Amazon SageMaker notebook instances are internet-enabled."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Sagemaker"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "SAGEMAKER_NOTEBOOK_NO_DIRECT_INTERNET_ACCESS"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "restricted-common-ports" {
  name             = "restricted-common-ports"
  description      = "Checks whether security groups that are in use disallow unrestricted incoming TCP traffic to the specified ports."
  input_parameters = "{ \"blockedPort1\": \"20\", \"blockedPort2\": \"21\", \"blockedPort3\": \"3389\", \"blockedPort4\": \"3306\", \"blockedPort5\": \"4333\" }"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-group-has-users-check" {
  name             = "iam-group-has-users-check"
  description      = "Checks whether IAM groups have at least one IAM user."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_GROUP_HAS_USERS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-bucket-public-read-prohibited" {
  name             = "s3-bucket-public-read-prohibited"
  description      = "Checks that your Amazon S3 buckets do not allow public read access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-root-access-key-check" {
  name             = "iam-root-access-key-check"
  description      = "Checks whether the root user access key is available. The rule is compliant if the user access key does not exist."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "vpc-sg-open-only-to-authorized-ports" {
  name             = "vpc-sg-open-only-to-authorized-ports"
  description      = "Checks whether any security groups with inbound 0.0.0.0/0 have TCP or UDP ports accessible. The rule is NON_COMPLIANT when a security group with inbound 0.0.0.0/0 has a port accessible which is not specified in the rule parameters."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "cloudwatch-log-group-encrypted" {
  name             = "cloudwatch-log-group-encrypted"
  description      = "Checks whether a log group in Amazon CloudWatch Logs is encrypted. The rule is NON_COMPLIANT if CloudWatch Logs has log group without encryption enabled."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "CloudWatch"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_LOG_GROUP_ENCRYPTED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-bucket-logging-enabled" {
  name             = "s3-bucket-logging-enabled"
  description      = "Checks whether logging is enabled for your S3 buckets."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LOGGING_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "iam-policy-no-statements-with-admin-access" {
  name             = "iam-policy-no-statements-with-admin-access"
  description      = "Checks whether the default version of AWS Identity and Access Management (IAM) policies do not have administrator access. If any statement has \"Effect\": \"Allow\" with \"Action\": \"*\" over \"Resource\": \"*\", the rule is non-compliant."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "IAM"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-bucket-ssl-requests-only" {
  name             = "s3-bucket-ssl-requests-only"
  description      = "Checks whether S3 buckets have policies that require requests to use Secure Socket Layer (SSL)."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "S3"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "secretsmanager-scheduled-rotation-success-check" {
  name             = "secretsmanager-scheduled-rotation-success-check"
  description      = "Checks whether AWS Secrets Manager secret rotation has rotated successfully as per the rotation schedule. The rule returns NON_COMPLIANT if RotationOccurringAsScheduled is false."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "Secrets Manager"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "SECRETSMANAGER_SCHEDULED_ROTATION_SUCCESS_CHECK"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "multi-region-cloudtrail-enabled" {
  name             = "multi-region-cloudtrail-enabled"
  description      = "Checks that there is at least one multi-region AWS CloudTrail. The rule is non-compliant if the trails do not match input parameters"
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "CloudTrail"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "access-keys-rotated" {
  name             = "access-keys-rotated"
  description      = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is non-compliant if the access keys have not been rotated for more than maxAccessKeyAge number of days."
  input_parameters = "{ \"maxAccessKeyAge\": \"90\"}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "AccessKeys"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "cloudtrail-enabled" {
  name             = "cloudtrail-enabled"
  description      = "Checks whether AWS CloudTrail is enabled in your AWS account."
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "CloudTrail"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "ec2-instances-in-vpc" {
  name             = "ec2-instances-in-vpc"
  description      = "EC2_Instances_In_VPC"
  input_parameters = "{}"
  tags = {
    TestType            = "AWS Managed"
    CloudResource       = "EC2"
    Category            = "Not Inherited"
    Responsibility      = "USNORTHCOM"
    ValidationSteps     = "-"
    USNORTHCOMValidated = "-"
  }

  source {
    owner             = "AWS"
    source_identifier = "INSTANCES_IN_VPC"
  }

  # depends_on = [aws_config_configuration_recorder.config_recorder]
}



#######################
# Custom Config Rules #
#######################
