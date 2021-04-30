# Locals block for hardcoded names. 
resource "azurerm_resource_group" "rg" {
    name     = var.rg_name
    location = var.location

    tags = var.tags
}

resource "azurerm_public_ip" "outbound" {
    name                = var.ip_outbound_name
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    ip_version          = "IPv4"
    sku                 = "standard"
    allocation_method   = "Static"

    tags = var.tags
}