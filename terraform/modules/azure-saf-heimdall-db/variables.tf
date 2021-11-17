variable "resource_group_name" {
    type = string
    default = "rg-heimdall-01"
}

variable "resource_group_location" {
    type = string
    default = "usgovvirginia"
}

variable "deployment_id" {
  type    = string
  default = "000"
}

variable "db_password" {
  description = "Password for the RDS instance."
  type        = string
  default     = "Password123"
}

variable "subnet_id" {
  description = "Id of the subnet for the Azure Container Instance."
  type        = string
  default     = ""
}
