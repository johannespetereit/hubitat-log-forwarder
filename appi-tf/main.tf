terraform {
  backend "azurerm" {
  }
}

# the azure provider
provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {
  }
}

resource "azurerm_resource_group" "application_insights" {
  name     = var.appi.resource_group_name
  location = var.appi.location
}
resource "azurerm_application_insights" "application_insights" {
  name                = var.appi.name
  location            = azurerm_resource_group.application_insights.location
  resource_group_name = azurerm_resource_group.application_insights.name
  retention_in_days   = var.appi.retention_in_days
  application_type    = "other"
}




resource "azurerm_application_insights_api_key" "full_permissions" {
  name                    = "tf-test-appinsights-full-permissions-api-key"
  application_insights_id = azurerm_application_insights.example.id
  read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
  write_permissions       = ["annotations"]
}
