provider "azurerm" {
  features {}
  version = "~> 2.0"
}

locals {
  tags = {
    environment_type = var.environment_type
    project_name     = "Azure Enterprise"
  }
}

module "hub_network" {
  source                           = "./modules/hub_network/"
  environment_type                 = var.environment_type
  hub_location                     = var.hub_location
  hub_vnet_address_space           = var.hub_vnet_address_space
  hub_firewall_snet_address_prefix = var.hub_firewall_snet_address_prefix
  hub_frontend_snet_address_prefix = var.hub_frontend_snet_address_prefix
  hub_backend_snet_address_prefix  = var.hub_backend_snet_address_prefix
  tags                             = local.tags
}

module "spoke_network" {
  source                             = "./modules/spoke_network/"
  spoke_ref_id                       = var.spoke_ref_id
  environment_type                   = var.environment_type
  spoke_location                     = var.spoke_location
  spoke_vnet_address_space           = var.spoke_vnet_address_space
  spoke_frontend_snet_address_prefix = var.spoke_frontend_snet_address_prefix
  spoke_backend_snet_address_prefix  = var.spoke_backend_snet_address_prefix
  hub_vnet_name                      = module.hub_network.vnet_hub_name
  hub_rg_name                        = module.hub_network.rg_hub_name
  hub_vnet_id                        = module.hub_network.vnet_hub_id
  tags                               = local.tags
}

module "hub_firewall" {
  source           = "./modules/hub_firewall/"
  environment_type = var.environment_type
  hub_location     = var.hub_location
  rg_name          = module.hub_network.rg_hub_name
  snet_firewall_id = module.hub_network.snet_firewall_id
  tags             = local.tags
}
