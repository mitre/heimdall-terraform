output "db_endpoint" {
  value = azurerm_postgresql_server.heimdall_db.fqdn
}

output "db_user_name" {
  value = azurerm_postgresql_server.heimdall_db.administrator_login
}

output "db_password" {
  value     = azurerm_postgresql_server.heimdall_db.administrator_login_password
  sensitive = true
}

output "db_name" {
  value = azurerm_postgresql_server.heimdall_db.name
}