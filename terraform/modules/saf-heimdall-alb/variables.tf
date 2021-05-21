variable "your_name" {
  description = "Name of the contact tag for all AWS resources"
  type        = string
  default     = "jwhite"
}

variable "proj_name" {
  description = "Name of the project in which Heimdall is being deployed"
  type        = string
  default     = "nnc"
}

variable "env" {
  type = string
}

variable "deployment_id" {
  type    = string
  default = "000"
}

variable "vpc_id" {
  description = "The ID for the VPC. Default value is a valid CIDR"
  type        = string
}

variable "public_subnet_ids" {
  description = "The public subnet IDs to deploy to"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The private subnet IDs to deploy to"
  type        = list(string)
}

variable "addl_alb_sg_ids" {
  description = "Additional SG to apply to the ALB"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  type = string
}