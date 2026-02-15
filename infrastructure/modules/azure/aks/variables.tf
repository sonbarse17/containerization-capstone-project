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
  type = string
}

variable "subnet_id" {
  description = "The Subnet ID to deploy the AKS nodes into"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes"
  default     = 2
}

variable "vm_size" {
  description = "Size of worker node VMs"
  default     = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  default = "1.27.7"
}
