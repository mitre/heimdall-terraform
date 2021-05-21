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

variable "aws_region" {
  type = string
}

variable "deployment_id" {
  type    = string
  default = "000"
}

variable "rds_password" {
  description = "Password for the RDS instance."
  type        = string
  default     = "Password123"
}

variable "display_db_pass" {
  description = "Shouold terraform output the generated heimdall database password to stdout?"
  type        = bool
  default     = true
}

variable "include_special_db_pass" {
  description = "Whether or not to include special characters in the db passcode. This requires URI encoding, so the default is false"
  type        = bool
  default     = true
}

variable "allocated_storage" {
  description = "Initial size of database for Heimdall in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum size of database for Heimdall in GiB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type for RDS storage, best to leave this as default gp2, see: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#Concepts.Storage"
  type        = string
  default     = "gp2"
}

variable "instance_class" {
  description = "Size and type of instance to run RDS. See: https://aws.amazon.com/rds/instance-types/"
  type        = string
  default     = "db.t2.micro"
}

variable "deletion_protection" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted."
  type        = bool
  default     = false
}