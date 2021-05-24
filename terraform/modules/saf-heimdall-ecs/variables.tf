# Project Info ##################################

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

variable "s3VpcEndpointPrefixListCidr" {
  type = string
}

# Heimdall config and Networking ################

variable "heimdall_image" {
  description = "Heimdall image repo url and version. Ex: mitre/heimdall:latest"
  type        = string
  default     = "mitre/heimdall2:release-latest"
}

variable "heimdall_ecr_arn" {
  description = "The ARN of the AWS ECR repository"
  type        = string
}

variable "vpcEndpoint_security_group" {
  description = "The security group to attach to ECR VPC endpoints"
  type        = string
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

# Credentials and Certs #########################

variable "certificate_arn" {
  description = "ARN of the domain certificate for Heimdall. See: https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html"
  type        = string
  default     = "arn:aws-us-gov:acm:us-gov-west-1:060708420889:certificate/4c71d20b-a581-4ee1-a342-c254b74e2126"
}

variable "AmazonECSTaskExecutionRolePolicy_arn" {
  description = "The ARN for the ECS task execution role policy. Change this from the default if working in non standard region (govcloud)"
  type        = string
  default     = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "AmazonRDSDataFullAccess_arn" {
  description = "The ARN for the RDS full access role policy. Change this from the default if working in non standard region (govcloud)"
  type        = string
  default     = "arn:aws-us-gov:iam::aws:policy/AmazonRDSFullAccess"
}

variable "aws_region" {
  description = "AWS region to deploy to."
  type        = string
  default     = "us-gov-west-1"
}

#Refactor Vars
variable "vpc_id" {
  description = "VPC ID to deploy Heimdall into."
  type        = string
}

variable "public_alb_target_group_id" {
  description = "Public ALB Target Group ID for ECS."
  type        = string
}

variable "private_alb_target_group_id" {
  description = "Private ALB Target Group ID for ECS."
  type        = string
}

variable "ecs_security_group_ids" {
  description = "The Security Groups to apply to the ECS instances"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "The private subnet IDs to deploy to"
  type        = list(string)
}

variable "rds_endpoint" {
  type    = string
  default = ""
}

variable "rds_db_name" {
  type    = string
  default = ""
}

variable "rds_user_name" {
  type    = string
  default = ""
}

variable "rds_password" {
  type    = string
  default = ""
}

variable "rds_sg_id" {
  type    = string
  default = ""
}
