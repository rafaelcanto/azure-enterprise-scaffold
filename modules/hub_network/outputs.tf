output "snet_firewall_id" {
  value = azurerm_subnet.firewall_subnet.id
}

output "vnet_hub_id" {
  value = azurerm_virtual_network.hub_network.id
}

output "vnet_hub_name" {
  value = azurerm_virtual_network.hub_network.name
}

output "rg_hub_name" {
  value = azurerm_resource_group.hub_networking.name
}
