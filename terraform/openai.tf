resource "azurerm_resource_group" "oa-rg" {
  name     = "oa_rg"
  location = "francecentral"
}

resource "azurerm_cognitive_account" "openai" {
  name                = "openai"
  location            = azurerm_resource_group.oa-rg.location
  resource_group_name = azurerm_resource_group.oa-rg.name
  kind                = "OpenAI" # Specify OpenAI kind
  sku_name            = "S0"     # Choose appropriate pricing tier (e.g., S0)

  # Set any required tags
  tags = {
    environment = "development"
  }
}

resource "azurerm_cognitive_deployment" "openai_gpt_4" {
  name                 = "openai-gpt-4"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "0613"
  }

  sku {
    name = "Standard" # The SKU (pricing tier) for this deployment
  }
}

resource "azurerm_cognitive_deployment" "openai_gpt_3" {
  name                 = "openai-gpt-3"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format = "OpenAI"
    name   = "gpt-35-turbo"
  }

  sku {
    name = "Standard" # The SKU (pricing tier) for this deployment
  }
}
