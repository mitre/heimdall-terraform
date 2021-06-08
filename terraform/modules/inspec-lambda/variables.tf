
variable "env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "deployment_id" {
  description = "The deployment AWS region."
  type        = string
}

variable "profiles_bucket_arn" {
  description = "The ARN for the InSpec profile S3 bucket."
  type        = string
}

variable "results_bucket_arn" {
  description = "The ARN for the InSpec results S3 bucket."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet ids to deploy the lambda to."
  type        = list(string)
}

variable "security_groups" {
  description = "The security groups to assign to the lambda."
  type        = list(string)
}

variable "function_path" {
  description = "The local file path to the lambda."
  type        = string
}

variable "heimdall_pusher_lambda_arn" {
  description = "The arn for the heimdall_pusher_lambda function"
  type = string
}
