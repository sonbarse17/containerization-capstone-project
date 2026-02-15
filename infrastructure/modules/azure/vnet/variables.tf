variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the VNet into"
  type        = string
}

variable "vnet_address_space" {
  description = "The CIDR block for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "The CIDR block for the AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
