
output "container_instance_ip" {
  value = azurerm_container_group.heimdall.ip_address
}