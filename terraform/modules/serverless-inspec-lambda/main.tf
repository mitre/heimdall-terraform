
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
    "arn:aws-us-gov:iam::aws:policy/service-role/AWSConfigRole"
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

  # Allow SSM access for starting sessions and SSM parameters
  inline_policy {
    name = "SsmParamAndSessionAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
            "ssm:StartSession"
          ]
          Effect   = "Allow"
          Resource = "arn:aws-us-gov:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/inspec/*"
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
    name = "AllowHeimdallPassKmsKeyDecrypt"

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
}