# locals {
#   prefix = "private"
# }

# resource "azurerm_private_dns_zone" "aks_private_dns" {
#   name                = "privatelink.northeurope.azmk8s.io" # Use the private link zone for AKS
#   resource_group_name = azurerm_resource_group.default.name
# }

# resource "azurerm_user_assigned_identity" "aks" {
#   name                = "myManagedIdentity"
#   resource_group_name = azurerm_resource_group.default.name
#   location            = var.location
# }

# resource "azurerm_role_assignment" "dns_contributor" {
#   scope                = azurerm_private_dns_zone.aks_private_dns.id
#   role_definition_name = "Private DNS Zone Contributor"
#   principal_id         = azurerm_user_assigned_identity.aks.principal_id
# }

# resource "azurerm_role_assignment" "network_contributor" {
#   scope                = azurerm_virtual_network.vnet.id
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.aks.principal_id
# }

# resource "azurerm_kubernetes_cluster" "private_aks" {
#   name                    = "${local.prefix}_aks"
#   dns_prefix              = "${local.prefix}aks"
#   location                = var.location
#   resource_group_name     = azurerm_resource_group.default.name
#   sku_tier                = "Free"
#   private_cluster_enabled = true
#   private_dns_zone_id     = azurerm_private_dns_zone.aks_private_dns.id # Add this line

#   default_node_pool {
#     name                        = "${local.prefix}pool"
#     node_count                  = var.node_count
#     vm_size                     = var.vm_size
#     temporary_name_for_rotation = "${local.prefix}tmp"
#     vnet_subnet_id              = azurerm_subnet.aks_subnet.id

#     upgrade_settings {
#       max_surge = "20%"
#     }
#   }

#   storage_profile {
#     blob_driver_enabled = true
#   }

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.aks.id]
#   }

#   network_profile {
#     network_plugin      = "azure"
#     network_plugin_mode = "overlay"
#     network_data_plane  = "cilium"
#     service_cidr        = "10.4.0.0/24" # Choose a CIDR range that does not overlap with your subnet
#     dns_service_ip      = "10.4.0.10"
#   }
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns_link" {
#   name                  = "${local.prefix}-dns-link"
#   resource_group_name   = azurerm_resource_group.default.name
#   private_dns_zone_name = azurerm_private_dns_zone.aks_private_dns.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
#   registration_enabled  = false
# }

# resource "azurerm_private_endpoint" "aks_private_endpoint" {
#   name                = "${local.prefix}-aks-private-endpoint"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.default.name
#   subnet_id           = azurerm_subnet.aks_subnet.id

#   private_service_connection {
#     name                           = "${local.prefix}-aks-connection"
#     private_connection_resource_id = azurerm_kubernetes_cluster.private_aks.id
#     is_manual_connection           = false
#     subresource_names              = ["management"]
#   }
# }

# output "private_aks" {
#   description = "Kube admin config"
#   value       = azurerm_kubernetes_cluster.private_aks
#   sensitive   = true
# }
