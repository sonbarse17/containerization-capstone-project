resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}${var.environment}acr" # Alphanumeric only
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true

  tags = {
    Environment = var.environment
  }
}
