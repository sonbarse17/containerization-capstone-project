output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "cluster_principal_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
