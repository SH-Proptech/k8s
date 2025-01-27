
# # Create Public IP for VPN Gateway
# resource "azurerm_public_ip" "vpn_gateway_ip" {
#   name                = "${var.prefix}-vpn-pip"
#   location            = azurerm_resource_group.default.location
#   resource_group_name = azurerm_resource_group.default.name
#   allocation_method   = "Static" # Change from Dynamic to Static
# }

# # Create the VPN Gateway
# resource "azurerm_virtual_network_gateway" "vpn_gateway_gtw" {
#   depends_on = [azurerm_subnet.vpn_gtw_subnet, azurerm_public_ip.vpn_gateway_ip]

#   name                = "${var.prefix}-vpn-gtw"
#   location            = azurerm_resource_group.default.location
#   resource_group_name = azurerm_resource_group.default.name
#   #   dns_forwarding_enabled = true

#   type     = "Vpn"
#   vpn_type = "RouteBased"

#   active_active = false
#   enable_bgp    = false
#   sku           = "VpnGw1" # Set to "Basic" instead of "VpnGw1" or higher

#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.vpn_gateway_ip.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.vpn_gtw_subnet.id
#   }

#   vpn_client_configuration {
#     address_space        = [var.vpn_client_address_space]
#     vpn_client_protocols = ["OpenVPN"]
#     vpn_auth_types       = ["AAD"]

#     aad_tenant   = "https://login.microsoftonline.com/${var.tenant_id}"
#     aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" # Fixed Value - Azure Public: https://learn.microsoft.com/en-gb/azure/vpn-gateway/openvpn-azure-ad-tenant
#     aad_issuer   = "https://sts.windows.net/${var.tenant_id}/"
#   }
# }

# # resource "azurerm_virtual_network_dns_servers" "vpn_dns" {
# #   virtual_network_id = azurerm_virtual_network.vnet.id
# #   dns_servers        = ["168.63.129.16"]
# # }
