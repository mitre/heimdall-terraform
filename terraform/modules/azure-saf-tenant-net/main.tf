##
# Create Resource Group
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_resource_group
#
resource "azurerm_resource_group" "rg" {
  name     = "rg-heimdall-${var.deployment_id}"
  location = "usgovvirginia"
  tags = {
    environment = "terraform"
  }
}

##
# Create Virtual Network
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_virtual_network
#
resource "azurerm_virtual_network" "vnet" {
  name                = "saf-heimdall-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "terraform"
  }

  depends_on = [
    azurerm_resource_group.rg,
  ]

}

##
# Create Public Subnet
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_subnet
#
resource "azurerm_subnet" "public-subnet" {
  name                 = "saf-public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

##
# Create Private Subnet
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_subnet
#
resource "azurerm_subnet" "private-subnet" {
  name                 = "saf-private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
  delegation {
    name = "heimdall-service"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }

  depends_on = [
    azurerm_resource_group.rg,
  ]
}

##
# Create Network Security Group
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_network_security_group
#
resource "azurerm_network_security_group" "heimdall-sg" {
  name                = "heimdall-sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "from-gateway-subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [22, 443, 5432, 3000]
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = azurerm_subnet.private-subnet.address_prefixes[0]
  }

  security_rule {
    name                       = "DenyAllInBound-Override"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "to-internet"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [80, 443, 5432]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllOutBound-Override"
    priority                   = 900
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

##
# Create Security Group Association
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_subnet_network_security_group_association
#
resource "azurerm_subnet_network_security_group_association" "heimdall-sn-nsg" {
  subnet_id                 = azurerm_subnet.private-subnet.id
  network_security_group_id = azurerm_network_security_group.heimdall-sg.id
}
