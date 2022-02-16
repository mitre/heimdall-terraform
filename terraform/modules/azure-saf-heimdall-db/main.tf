
##
# Create Postgresql Server
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
#
resource "azurerm_postgresql_server" "heimdall_db" {
  name                = "heimdall-db" #need to come back and not hard code this.. pull from variable
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  administrator_login          = "postgres"
  administrator_login_password = "Password123" #"${var.db_password}"

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  #public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = {
    environment = "terraform"
  }
}

##
# Create Virtual Network Rule for Subnet
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_virtual_network_rule
#
resource "azurerm_postgresql_virtual_network_rule" "heimdall_db_nr" {
  name                                 = "heimdall-db-nr"
  resource_group_name                  = "${var.resource_group_name}"
  server_name                          = azurerm_postgresql_server.heimdall_db.name
  subnet_id                            = "${var.subnet_id}"
  ignore_missing_vnet_service_endpoint = false
}