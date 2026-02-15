output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.sa.primary_access_key
  sensitive = true
}

output "container_name" {
  value = azurerm_storage_container.sc.name
}
