
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# Create RDS Parameter Group
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Parameters
#
resource "aws_db_parameter_group" "heimdall_pg" {
  name   = "${local.name}-heimdall-pg-${var.deployment_id}"
  family = "postgres12"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "0"
  }

  tags = {
    Name = "${local.name}-heimdall-db-param-group-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    Project = local.name,
  }
}

##
# Create RDS Subnet Group
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
#
resource "aws_db_subnet_group" "heimdall_subg" {
  name       = "${local.name}-heimdall-subnet-group-${var.deployment_id}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${local.name}-heimdall-db-sn-group-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    Project = local.name,
  }
}

##
# Create RDS
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
#
resource "aws_db_instance" "heimdall_db" {
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  storage_type                    = var.storage_type
  engine                          = "postgres"
  engine_version                  = "12.3"
  instance_class                  = var.instance_class
  name                            = "${local.name}_postgres_${var.deployment_id}"
  username                        = "postgres"
  password                        = var.rds_password
  parameter_group_name            = aws_db_parameter_group.heimdall_pg.name
  db_subnet_group_name            = aws_db_subnet_group.heimdall_subg.id
  skip_final_snapshot             = true
  deletion_protection             = var.deletion_protection
  vpc_security_group_ids          = ["${aws_security_group.SafRdsSG.id}"]
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.rds_encryption_key.arn
  multi_az                        = true
  monitoring_role_arn             = aws_iam_role.rds_cloudwatch_role.arn
  monitoring_interval             = 30
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name = "${local.name}-heimdall-rds-db-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    Project = local.name,
  }
}

##
##
# Security group that enables communication betewwn
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
#
resource "aws_security_group" "SafRdsSG" {
  name        = "SafRdsSG-${var.deployment_id}"
  description = "Allow port 5432 communication with own SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SafRdsSG-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    Project = local.name,
  }
}

##
# Ingress SG rule that allows 5432 communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafRdsIngressRule" {
  description = "Ingress SG rule that allows 5432 communication with own SG"

  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id = aws_security_group.SafRdsSG.id
  self              = true
}

##
# Egress SG rule that allows 5432 communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafRdsEgressRule" {
  description = "Egress SG rule that allows 5432 communication with own SG"

  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id = aws_security_group.SafRdsSG.id
  self              = true
}

##
# KMS Key for RDS Snapshot Encryptions
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
#
resource "aws_kms_key" "rds_encryption_key" {
  description             = "KMS key to encrypt RDS snapshots"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    Name = "SafRdsKMS-${var.deployment_id}"
  }
}

##
# IAM Role for RDS Cloudwatch Logs
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
#
resource "aws_iam_role" "rds_cloudwatch_role" { #This is hard coded for us govcloud now..
  name                = "${local.name}_cloudwatch_role_${var.deployment_id}"
  managed_policy_arns = [data.aws_iam_policy.rds_enhanced_monitoring_policy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "rds_enhanced_monitoring_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
