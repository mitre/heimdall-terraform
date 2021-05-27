
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
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
      IMAGE_TAG      = file("${var.function_path}/.version")
    }
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

  # Allow invoking the HeimdallPusher lambda
  inline_policy {
    name = "AllowHeimdallPusherInvoke"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "lambda:InvokeFunction"
          ]
          Effect   = "Allow"
          Resource = var.heimdall_pusher_lambda_arn
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
  memory_size   = 1024

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_groups

  create_package = false
  image_uri      = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/mitre/serverless-inspec:${file("${var.function_path}/.version")}"
  package_type   = "Image"

  environment_variables = {
    HOME = "/tmp"
  }
}
