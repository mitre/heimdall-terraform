
variable "aws_region" {
  description = "The deployment AWS region."
  type        = string
}

variable "deployment_id" {
  description = "The randomized deployment ID."
  type        = string
}

variable "vpc_id" {
  description = "VPC the endpoints will be located in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets that endpoints will be assigned to."
  type        = list(string)
}

variable "security_groups" {
  description = "Security Groups to assign to endpoints."
  type        = list(string)
}
