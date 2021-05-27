
variable "deployment_id" {
  type    = string
  default = "000"
}

variable "env" {
  type = string
}

variable "vpc_id" {
  description = "The ID for the VPC. Default value is a valid CIDR"
  type        = string
}

variable "subnet_ids" {
  description = "The private subnet IDs to deploy to"
  type        = list(string)
}

variable "function_zip_path" {
  description = "The absolute path to the zipped function"
  type        = string
}

variable "ConfigToHdf_security_groups" {
  description = "The security groups to attach to ConfigToHdf lambda"
  type        = list(string)
}

variable "aws_region" {
  type    = string
  default = "us-gov-west-1"
}

variable "account_name" {
  type    = string
  default = "missing-account-name"
}

variable "heimdall_pusher_lambda_arn" {
  description = "The ARN of the HeimdallPusher lambda function"
  type        = string
}

variable "results_bucket_id" {
  description = "The id/name for the InSpec results S3 bucket."
  type        = string
}