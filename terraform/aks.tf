# Create cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}_aks"
  dns_prefix          = "${var.prefix}aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  sku_tier            = "Free"

  default_node_pool {
    name                        = "${var.prefix}pool"
    node_count                  = var.node_count
    vm_size                     = var.vm_size
    temporary_name_for_rotation = "${var.prefix}tmp"
    # vnet_subnet_id              = azurerm_subnet.aks_subnet.id

    upgrade_settings {
      max_surge = "20%"
    }
  }

  storage_profile {
    blob_driver_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    service_cidr        = var.aks_internal_address_space # Choose a CIDR range that does not overlap with your subnet
  }
}

# Create Azure Storage
resource "azurerm_storage_account" "default" {
  name                     = "${var.prefix}sa"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"
  access_tier              = "Cool"

  lifecycle {
    prevent_destroy = true
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

# Create ACR
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_role_assignment" "acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Create Storage
resource "azurerm_storage_container" "blob" {
  name                  = "${var.prefix}-blob"
  storage_account_name  = azurerm_storage_account.default.name
  container_access_type = "private"
}

// This is not needed I think
resource "azurerm_role_assignment" "aks_storage_contributor" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.default.id
}

// This is needed for managed storage
resource "azurerm_role_assignment" "aks_storage_acc_contributor" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "Storage Account Contributor"
  scope                = azurerm_storage_account.default.id
}

// This is needed for our custom storage account
resource "azurerm_role_assignment" "aks_propsa_storage_acc_contributor" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Storage Account Contributor"
  scope                = azurerm_storage_account.default.id
}
