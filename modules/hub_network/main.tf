

locals {
  rg_name            = "rg-${var.environment_type}-${var.hub_location}-hub-network" // defaults to: rg-dev-eastus-hub-network
  vnet_name          = "vnet-${var.environment_type}-${var.hub_location}-hub"       //defaults to: vnet-dev-eastus-hub
  snet_frontend_name = "snet-${var.environment_type}-hub-frontend-01"               //defaults to: snet-dev-hub-frontend-01
  snet_backend_name  = "snet-${var.environment_type}-hub-backend-01"                //defaults to: snet-dev-hub-backend-01
  nsg_frontend_name  = "nsg-${var.environment_type}-hub-frontend-01"                //defaults to: nsg-dev-hub-frontend-01
  nsg_backend_name   = "nsg-${var.environment_type}-hub-backend-01"                 //defaults to: nsg-dev-hub-backend-01

}

resource "azurerm_resource_group" "hub_networking" {
  name     = local.rg_name
  location = var.hub_location
  tags = var.tags
}

resource "azurerm_virtual_network" "hub_network" {
  name                = local.vnet_name
  location            = azurerm_resource_group.hub_networking.location
  resource_group_name = azurerm_resource_group.hub_networking.name
  address_space       = [var.hub_vnet_address_space]
}


resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_networking.name
  virtual_network_name = azurerm_virtual_network.hub_network.name
  address_prefix       = var.hub_firewall_snet_address_prefix
}

resource "azurerm_subnet" "frontent_subnet" {
  name                 = local.snet_frontend_name
  resource_group_name  = azurerm_resource_group.hub_networking.name
  virtual_network_name = azurerm_virtual_network.hub_network.name
  address_prefix       = var.hub_frontend_snet_address_prefix
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = local.snet_backend_name
  resource_group_name  = azurerm_resource_group.hub_networking.name
  virtual_network_name = azurerm_virtual_network.hub_network.name
  address_prefix       = var.hub_backend_snet_address_prefix
}

resource "azurerm_network_security_group" "frontend_snet_nsg" {
  name                = local.nsg_frontend_name
  location            = azurerm_resource_group.hub_networking.location
  resource_group_name = azurerm_resource_group.hub_networking.name
}

resource "azurerm_network_security_group" "backend_snet_nsg" {
  name                = local.nsg_backend_name
  location            = azurerm_resource_group.hub_networking.location
  resource_group_name = azurerm_resource_group.hub_networking.name
}

resource "azurerm_network_security_rule" "allow_http_inboud_rule" {
  name                        = "allow-http-inboud-rule"
  resource_group_name         = azurerm_resource_group.hub_networking.name
  network_security_group_name = azurerm_network_security_group.frontend_snet_nsg.name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


resource "azurerm_subnet_network_security_group_association" "link_nsg_to_frontend" {
  subnet_id                 = azurerm_subnet.frontent_subnet.id
  network_security_group_id = azurerm_network_security_group.frontend_snet_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "link_nsg_to_backend" {
  subnet_id                 = azurerm_subnet.backend_subnet.id
  network_security_group_id = azurerm_network_security_group.backend_snet_nsg.id
}

