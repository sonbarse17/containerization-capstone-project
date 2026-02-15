resource "azurerm_storage_account" "sa" {
  name                     = replace("${var.project_name}${var.environment}data", "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_storage_container" "sc" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
