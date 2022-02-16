

##
# Create Public Ip
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_public_ip
#
resource "azurerm_public_ip" "heimdall-ip" {
  name                = "heimdall-pip"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

##
# Create Heimdall Application Gateway
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_application_gateway
#
resource "azurerm_application_gateway" "heimdall-ag" {
  name                = "heimdall-appgateway"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "heimdall-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "heimdall-frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "heimdall-frontend-config"
    public_ip_address_id = azurerm_public_ip.heimdall-ip.id
  }

  backend_address_pool {
    name = "heimdall-backend-address-pool"
  }

  backend_http_settings {
    name                  = "heimdall-backend-http-name"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "heimdall-http-listener"
    frontend_ip_configuration_name = "heimdall-frontend-config"
    frontend_port_name             = "heimdall-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "heimdall-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "heimdall-http-listener"
    backend_address_pool_name  = "heimdall-backend-address-pool"
    backend_http_settings_name = "heimdall-backend-http-name"
  }
}