
locals {
  firewall_name = "fw-${var.environment_type}-${var.hub_location}-hub-firewall" //defaults to: fw-dev-eastus-hub-firewall
  pip_name      = "pip-fw-${var.environment_type}-${var.hub_location}-01"
}



resource "azurerm_firewall" "hub_firewall" {
  name                = local.firewall_name
  location            = var.hub_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                 = "fw-ip-configuration"
    subnet_id            = var.snet_firewall_id
    public_ip_address_id = azurerm_public_ip.pip_firewall.id
  }
}


resource "azurerm_public_ip" "pip_firewall" {
  name                = local.pip_name
  location            = var.hub_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
