terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# resource group
module "rg" {
  source = "../../modules/azure/resource_group"

  environment  = var.environment
  project_name = var.project_name
  location     = var.location
}

# vnet
module "vnet" {
  source = "../../modules/azure/vnet"

  environment         = var.environment
  project_name        = var.project_name
  location            = module.rg.location
  resource_group_name = module.rg.resource_group_name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_prefix   = var.aks_subnet_prefix
}

# acr
module "acr" {
  source = "../../modules/azure/acr"

  environment         = var.environment
  project_name        = var.project_name
  location            = module.rg.location
  resource_group_name = module.rg.resource_group_name
}

# aks
module "aks" {
  source = "../../modules/azure/aks"

  environment         = var.environment
  project_name        = var.project_name
  location            = module.rg.location
  resource_group_name = module.rg.resource_group_name
  subnet_id           = module.vnet.aks_subnet_id
  node_count          = var.node_count
  vm_size             = var.vm_size
}

# role assignments
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.cluster_principal_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true
}

# key vault
module "kv" {
  source = "../../modules/azure/keyvault"

  environment         = var.environment
  project_name        = var.project_name
  location            = module.rg.location
  resource_group_name = module.rg.resource_group_name
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = module.kv.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.aks.cluster_principal_id

  secret_permissions = [
    "Get",
  ]
}

# storage
module "storage" {
  source = "../../modules/azure/storage"

  environment         = var.environment
  project_name        = var.project_name
  location            = module.rg.location
  resource_group_name = module.rg.resource_group_name
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "configure_kubectl" {
  value = "az aks get-credentials --resource-group ${module.rg.resource_group_name} --name ${module.aks.cluster_name}"
}
