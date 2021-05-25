
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# S3 bucket for storing versions of the InSpec lambda
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
resource "aws_s3_bucket" "inspec_lambda_code_bucket" {
  bucket = "inspec-lambda-code-bucket-${var.env}-${var.deployment_id}"
  acl    = "private"

  tags = {
    Name        = "inspec-lambda-code-bucket-${var.env}-${var.deployment_id}"
    Environment = var.env
  }
}

# Elastic Container Registry for SAF deployment
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
#
resource "aws_ecr_repository" "mitre_serverless_inspec" {
  name                 = "mitre/serverless-inspec"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "push_image" {
  depends_on = [
    aws_ecr_repository.mitre_serverless_inspec,
  ]

  # Ensures this script always runs
  triggers = {
    always_run = timestamp()
  }

  # https://www.terraform.io/docs/language/resources/provisioners/local-exec.html
  provisioner "local-exec" {
    command = "./push-image.sh"

    environment = {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = var.account_id
      IMAGE_FILE     = "serverless-inspec.tar"
      REPO_NAME      = "mitre/serverless-inspec"
      IMAGE_TAG      = "latest"
    }
  }
}

##
# S3 zip file uploaded from local zip that contains the lambda package
# 
#
#
# resource "aws_s3_bucket_object" "InSpecZip" {
#   bucket = aws_s3_bucket.inspec_lambda_code_bucket.id
#   key    = "${filemd5(var.function_zip_path)}.zip"
#   source = var.function_zip_path
# }


##
# InSpec Role to Invoke InSpec Lambda function 
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
#
resource "aws_iam_role" "InSpecRole" {
  name = "InSpecRole-${var.deployment_id}"

  # Allow execution of the lambda function
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
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
          Resource = var.profileBucketArn
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
          Resource = "*" # consider locking this down to a subpath
        }
      ]
    })
  }

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
          Resource = "*" # consider locking this down to specific key(s)
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
module "InSpec" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "InSpec-${var.deployment_id}"
  description   = "Lambda capable of performing InSpec scans."
  handler       = "lambda_function.lambda_handler"
  runtime       = "ruby2.7"
  create_role   = false
  lambda_role   = aws_iam_role.InSpecRole.arn
  timeout       = 900

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_groups

  create_package = false
  image_uri    = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/mitre/serverless-inspec:latest"
  package_type = "Image"

  environment_variables = {
    HOME = "/tmp"
  }
}
