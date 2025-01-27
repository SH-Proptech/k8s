// Creates users and there role assignments

// Hans Role Assignment
resource "azurerm_role_assignment" "hans_contributor" {
  principal_id         = var.hans_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.default.id
}