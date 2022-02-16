

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

variable "subnet_id" {
    type = string
    default = "000"
}

variable "container_instance_ip" {
    type = string
    default = "0.0.0.0"
}