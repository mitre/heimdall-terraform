
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# ConfigToHdf Role to Invoke ConfigToHdf Lambda function 
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
#
resource "aws_iam_role" "ConfigToHdfRole" {
  name = "ConfigToHdfRole-${var.deployment_id}"

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
  # inline_policy {
  #   name = "AllowHeimdallPusherInvoke"

  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Action = [
  #           "lambda:InvokeFunction"
  #         ]
  #         Effect   = "Allow"
  #         Resource = var.heimdall_pusher_lambda_arn
  #       }
  #     ]
  #   })
  # }

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
          Resource = "${data.aws_s3_bucket.results_bucket.arn}/*"
        }
      ]
    })
  }

  # Allow READ access to AWS Config
  inline_policy {
    name = "AwsConfigReadAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "config:BatchGet*",
            "config:Describe*",
            "config:Get*",
            "config:List*",
            "config:Select*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

##
# Get bucket data for use elsewhere
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket
#
data "aws_s3_bucket" "results_bucket" {
  bucket = var.results_bucket_id
}

##
# ConfigToHdf Lambda function
#
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#
module "ConfigToHdf" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "ConfigToHdf-${var.deployment_id}"
  description   = "Lambda capable of pulling AWS Config data, mapping to HDF, and pushing results to Heimdall Server API."
  handler       = "lambda_function.lambda_handler"
  runtime       = "ruby2.7"
  create_role   = false
  lambda_role   = aws_iam_role.ConfigToHdfRole.arn
  timeout       = 900

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.ConfigToHdf_security_groups

  create_package         = false
  local_existing_package = var.function_zip_path # "../../../lambda/ConfigToHdf/function.zip"

  environment_variables = {
    results_bucket = var.results_bucket_id
  }
}

##
# Event Rule to Trigger ConfigtoHdf regularly
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
#
# Needs permission to invoke lambda
# 
resource "aws_cloudwatch_event_rule" "ConfigToHdfEventRule" {
  name                = "ConfigToHdfEventRule-${var.deployment_id}"
  description         = "Regularly scheduled run of ConfigToHdf"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "ConfigToHdfEventTarget" {
  arn  = module.ConfigToHdf.lambda_function_arn
  rule = aws_cloudwatch_event_rule.ConfigToHdfEventRule.id
}

resource "aws_lambda_permission" "ConfigToHdfEventRuleLambdaPermission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.ConfigToHdf.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ConfigToHdfEventRule.arn
}
