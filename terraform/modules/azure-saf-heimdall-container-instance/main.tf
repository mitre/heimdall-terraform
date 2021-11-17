##
# Create Azure Container Group
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group
#
resource "azurerm_container_group" "heimdall" {
  name                = "heimdall2"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
  ip_address_type     = "private"
  #dns_name_label      = "nnc-heimdall"
  os_type             = "Linux"
  network_profile_id  = azurerm_network_profile.containergroup_profile.id

  container {
    name   = "heimdall2"
    image  = "${var.heimdall_image}"
    cpu    = "1"
    memory = "4"

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      "RAILS_SERVE_STATIC_FILES"   = "${var.RAILS_SERVE_STATIC_FILES}",
      "RAILS_ENV"                  = "${var.RAILS_ENV}",
      "HEIMDALL_RELATIVE_URL_ROOT" = "${var.HEIMDALL_RELATIVE_URL_ROOT}",
      "DISABLE_SPRING"             = "${var.DISABLE_SPRING}",
      "RAILS_LOG_TO_STDOUT"        = "${var.RAILS_LOG_TO_STDOUT}",
      "DATABASE_NAME"              = "postgres",
      "DATABASE_USERNAME"          = "${var.db_user_name}@${var.db_endpoint}",
      "DATABASE_HOST"              = "${var.db_endpoint}",
      "DATABASE_PORT"              = "5432",
      "DATABASE_SSL"               = "true",
      "NODE_ENV"                   = "production"
    }

    secure_environment_variables = {
      "DATABASE_PASSWORD" = "Password123", #"${var.db_password}",
      "JWT_SECRET"        = "eba1d0bbfdce4b099e7d09c27a369c66640ad2876ff84774aa0bd1eb3808dc3f38cc8a790ff72fb1a91a5ba1818c231b30837e8e8a953424494bd9c562039b0f",
      "JWT_EXPIRE_TIME"   = "1d"
    }

  }

  tags = {
    environment = "terraform"
  }
}

##
# Create Network Profile for Container Group
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/azurerm_network_profile
#
resource "azurerm_network_profile" "containergroup_profile" {
  name                = "heimdall-profile"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"

  container_network_interface {
    name = "heimdall-nic"

    ip_configuration {
      name      = "heimdallipconfig"
      subnet_id = "${var.subnet_id}"
    }
  }
}