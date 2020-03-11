

locals {
  rg_name            = "rg-${var.environment_type}-${var.spoke_location}-spoke-${var.spoke_ref_id}"   // defaults to: rg-dev-eastus-spoke-network
  vnet_name          = "vnet-${var.environment_type}-${var.spoke_location}-spoke-${var.spoke_ref_id}" //defaults to: vnet-dev-eastus-spoke
  snet_frontend_name = "snet-${var.environment_type}-spoke-${var.spoke_ref_id}-frontend-01"           //defaults to: snet-dev-spoke-01-frontend-01
  snet_backend_name  = "snet-${var.environment_type}-spoke-${var.spoke_ref_id}-backend-01"            //defaults to: snet-dev-spoke-01-backend-01
  nsg_frontend_name  = "nsg-${var.environment_type}-spoke-${var.spoke_ref_id}-frontend-01"            //defaults to: nsg-dev-spoke-01-frontend-01
  nsg_backend_name   = "nsg-${var.environment_type}-spoke-${var.spoke_ref_id}-backend-01"             //defaults to: nsg-dev-spoke-01-backend-01

}

resource "azurerm_resource_group" "rg_spoke_networking" {
  name     = local.rg_name
  location = var.spoke_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke_network" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg_spoke_networking.location
  resource_group_name = azurerm_resource_group.rg_spoke_networking.name
  address_space       = [var.spoke_vnet_address_space]
}


resource "azurerm_subnet" "frontent_subnet" {
  name                 = local.snet_frontend_name
  resource_group_name  = azurerm_resource_group.rg_spoke_networking.name
  virtual_network_name = azurerm_virtual_network.spoke_network.name
  address_prefix       = var.spoke_frontend_snet_address_prefix
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = local.snet_backend_name
  resource_group_name  = azurerm_resource_group.rg_spoke_networking.name
  virtual_network_name = azurerm_virtual_network.spoke_network.name
  address_prefix       = var.spoke_backend_snet_address_prefix
}

resource "azurerm_network_security_group" "frontend_snet_nsg" {
  name                = local.nsg_frontend_name
  location            = azurerm_resource_group.rg_spoke_networking.location
  resource_group_name = azurerm_resource_group.rg_spoke_networking.name
}

resource "azurerm_network_security_group" "backend_snet_nsg" {
  name                = local.nsg_backend_name
  location            = azurerm_resource_group.rg_spoke_networking.location
  resource_group_name = azurerm_resource_group.rg_spoke_networking.name
}

resource "azurerm_network_security_rule" "allow_http_inboud_rule" {
  name                        = "allow-http-inboud-rule"
  resource_group_name         = azurerm_resource_group.rg_spoke_networking.name
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


resource "azurerm_virtual_network_peering" "spoke_to_hub_peering" {
  name                         = "spoke${var.spoke_ref_id}-to-hub_peering"
  resource_group_name          = azurerm_resource_group.rg_spoke_networking.name
  virtual_network_name         = azurerm_virtual_network.spoke_network.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_peering" {
  name                         = "hub-to-spoke${var.spoke_ref_id}-peering"
  resource_group_name          = var.hub_rg_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_network.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}
