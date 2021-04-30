output "ip_outbound_id" {
  value = azurerm_public_ip.outbound.id
}

output "ip_outbound_address" {
  value = azurerm_public_ip.outbound.ip_address
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "location" {
  value = azurerm_resource_group.rg.location
}