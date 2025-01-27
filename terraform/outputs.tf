
output "storage_account_name" {
  value = azurerm_storage_account.default.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.default.primary_access_key
  sensitive = true
}

output "identity_object_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "github_action_credentials" {
  value = jsonencode({
    clientId       = azuread_application.github_action_sp.client_id
    clientSecret   = azuread_service_principal_password.github_action_sp_password.value
    subscriptionId = var.subscription_id
    tenantId       = var.tenant_id
  })
  sensitive = true
}

output "azure_openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "azure_openai_api_key" {
  value     = azurerm_cognitive_account.openai.primary_access_key
  sensitive = true
}
