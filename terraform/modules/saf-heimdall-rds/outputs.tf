output "rds_endpoint" {
  value = aws_db_instance.heimdall_db.endpoint
}

output "rds_user_name" {
  value = aws_db_instance.heimdall_db.username
}

output "rds_password" {
  value     = aws_db_instance.heimdall_db.password
  sensitive = true
}

output "rds_db_name" {
  value = aws_db_instance.heimdall_db.name
}

output "rds_sg_id" {
  value = aws_security_group.SafRdsSG.id
}