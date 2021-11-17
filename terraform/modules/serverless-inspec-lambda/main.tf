
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
#
data "aws_region" "current" {}

##
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
#
data "aws_caller_identity" "current" {}

##
# The KMS key used by serverless InSpec to access SSM Parameters and Other encrypted items
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
#
resource "aws_kms_key" "inspec-kms-key" {
  description             = "The KMS key used by serverless InSpec to access SSM Parameters and Other encrypted items"
  deletion_window_in_days = 10

  tags = {
    Name = "inspec-kms-key"
  }
}

##
# InSpec Role to Invoke InSpec Lambda function 
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
#
resource "aws_iam_role" "InSpecRole" {
  name = "InSpecRole-${var.deployment_id}"

  # Allow execution of the lambda function
  # User: is not authorized to perform: iam:ListPolicies on resource: policy path /
  # Should NOT have AWS Config Write access
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
  ]

  # Allow assume role permission for lambda
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Allow logs:DescribeMetricFilters for aws:// profiles
  inline_policy {
    name = "LogsDescribeMetricFilters"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:DescribeMetricFilters"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
  
  # Allow iam:ListPolicies for CIS Baseline
  inline_policy {
    name = "IamListPoliciesAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "iam:ListPolicies"
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Allow logs:DescribeMetricFilters for CIS Baseline
  inline_policy {
    name = "DescribeMetricFiltersAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "logs:DescribeMetricFilters"
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Allow Policy and ACL access for CIS Baseline
  # https://docs.chef.io/inspec/resources/aws_s3_bucket/#be_public
  inline_policy {
    name = "S3PolicyAndAclAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetBucketPolicyStatus",
            "s3:GetBucketAcl",
            "s3:GetBucketPolicy"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Allow S3 read access to InSpec profile bucket
  inline_policy {
    name = "S3ProfileAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetObject"
          ]
          Effect   = "Allow"
          Resource = "${var.profiles_bucket_arn}/*"
        }
      ]
    })
  }

  # Allow S3 write access to InSpec results bucket
  inline_policy {
    name = "S3ResultsAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:PutObject"
          ]
          Effect   = "Allow"
          Resource = "${var.results_bucket_arn}/*"
        }
      ]
    })
  }

  # Allow SSM DescribeInstanceInformation for awsssm:// transports
  inline_policy {
    name = "SsmDescribeInstanceInformationAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:DescribeInstanceInformation"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Allow SSM SendCommand for awsssm:// transports
  inline_policy {
    name = "SsmSendCommandAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:SendCommand"
          ]
          Effect   = "Allow"
          # Consider locking this down further to only instances that need to be scanned with awsssm://
          Resource = [
              "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
              "arn:aws:ssm:${data.aws_region.current.name}::document/AWS-RunPowerShellScript",
              "arn:aws:ssm:${data.aws_region.current.name}::document/AWS-RunShellScript"
          ]
        }
      ]
    })
  }

  # Allow SSM SendCommand for awsssm:// transports
  inline_policy {
    name = "SsmGetCommandInvocationAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "ssm:GetCommandInvocation"
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Allow SSM access for starting sessions 
  inline_policy {
    name = "SsmSessionAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "ssm:StartSession"
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  # Allow SSM parameters acccess for /inspec/*
  inline_policy {
    name = "SsmParamAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "ssm:GetParameter"
          Effect   = "Allow"
          Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/inspec/*"
        }
      ]
    })
  }

  # Allow EC2 get password data for fetching WinRM credentials
  # inline_policy {
  #   name = "EC2GetPasswordDataAccess"

  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Action = [
  #           "ec2:GetPasswordData"
  #         ]
  #         Effect   = "Allow"
  #         Resource = "*" # consider locking this down to a specific groups of machines
  #       }
  #     ]
  #   })
  # }

  inline_policy {
    name = "AllowInSpecKmsKeyDecrypt"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "kms:Decrypt"
          ]
          Effect   = "Allow"
          Resource = aws_kms_key.inspec-kms-key.arn
        }
      ]
    })
  }
}

##
# InSpec Lambda function
#
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#
module "serverless-inspec-lambda" {
  source = "github.com/mitre/serverless-inspec-lambda"
  subnet_ids      = var.subnet_ids
  security_groups = var.security_groups
  lambda_role_arn = aws_iam_role.InSpecRole.arn
  lambda_name     = "serverless-inspec-lambda-${var.deployment_id}"
  image_version   = "0.15.7"
}