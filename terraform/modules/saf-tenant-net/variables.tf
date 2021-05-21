
variable "env" {
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR"
  type        = string
  default     = "172.18.0.0/16"
}

variable "aws_region" {
  type    = string
  default = "us-gov-west-1"
}

variable "deployment_id" {
  type    = string
  default = "000"
}