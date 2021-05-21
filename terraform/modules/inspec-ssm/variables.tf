
variable "deployment_id" {
  type    = string
  default = "000"
}

variable "inspec_s3_bucket_name" {
  type = string
}

variable "inspec_rhel7_baseline_s3_key" {
  type  = string
}

variable "inspec_rhel7_baseline_schedule" {
  type    = string
  default = "cron(0/30 * * * ? *)"
}