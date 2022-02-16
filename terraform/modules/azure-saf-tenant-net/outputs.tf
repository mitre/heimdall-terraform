output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_public_id" {
  value = azurerm_subnet.public-subnet.id
}

output "subnet_private_id" {
  value = azurerm_subnet.private-subnet.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}
