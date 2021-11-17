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

# Heimdall config and Networking ################

variable "heimdall_image" {
  description = "Heimdall image repo url and version. Ex: mitre/heimdall:latest"
  type        = string
  default     = "mitre/heimdall2:release-latest"
}

variable "RAILS_SERVE_STATIC_FILES" {
  description = "Whether rails serves static files in its deployment. Default true"
  type        = bool
  default     = true
}

variable "RAILS_ENV" {
  description = "Environment tag for rails deployment. Default production"
  type        = string
  default     = "production"
}

variable "HEIMDALL_RELATIVE_URL_ROOT" {
  description = "Relative root url for heimdall deployment location. Default empty"
  type        = string
  default     = ""
}

variable "DISABLE_SPRING" {
  description = "Disable springboot in Heimdall deployment? Default false"
  type        = bool
  default     = false
}

variable "RAILS_LOG_TO_STDOUT" {
  description = "Display rails logs to stdout for viewing in AWS cloudwatch/ECS logs? Default true"
  type        = bool
  default     = true
}

variable "db_endpoint" {
  type    = string
  default = ""
}

variable "db_name" {
  type    = string
  default = "heimdall-db"
}

variable "db_user_name" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  description = "Password for the DB instance."
  type        = string
  default     = "Password123"
}

variable "subnet_id" {
  description = "Id of the subnet for the Azure Container Instance."
  type        = string
  default = ""
}