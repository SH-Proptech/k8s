// Creates the GitHub Action Service Principal & Application

// CI/CD Service Principal  (App Registration)
resource "azuread_application" "github_action_sp" {
  display_name = "github-action-sp"
}

// Create a Service Principal for the Application
resource "azuread_service_principal" "github_action_sp" {
  client_id = azuread_application.github_action_sp.client_id
}

// Create a Client Secret for the Service Principal
resource "azuread_service_principal_password" "github_action_sp_password" {
  service_principal_id = azuread_service_principal.github_action_sp.id
  end_date_relative    = "8760h" # 1 year
}

// Assign Role (e.g., Contributor) to the Service Principal
resource "azurerm_role_assignment" "github_action_sp_role" {
  principal_id         = azuread_service_principal.github_action_sp.id
  role_definition_name = "Contributor"                           # Role can be changed based on need
  scope                = "/subscriptions/${var.subscription_id}" # Your subscription ID
}