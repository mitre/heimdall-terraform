
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

variable "security_groups" {
  description = "The security groups to attach to lambda"
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

variable "heimdall_url" {
  description = "The url to the Heimdall server in http://... format"
  type        = string
}

variable "heimdall_user" {
  description = "The Heimdall user's email used to log in"
  type        = string
}

variable "heimdall_password" {
  description = "The Heimdall user's password used to log in"
  type        = string
  sensitive   = true
}

variable "results_bucket_id" {
  description = "The S3 bucket id/name where results will be placed and processed"
  type        = string
}
