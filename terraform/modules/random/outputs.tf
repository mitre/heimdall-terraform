output "deployment_id" {
  value = random_string.deployment_id.result
}

output "rds_password" {
  value = random_password.rds_password.result
  sensitive = true
}