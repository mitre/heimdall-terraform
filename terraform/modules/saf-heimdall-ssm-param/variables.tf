variable "deployment_id" {
  type    = string
  default = "000"
}

variable "rds_password" {
  description = "Password for the RDS instance."
  type        = string
}