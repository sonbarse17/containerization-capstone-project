variable "environment" {
  type = string
}

variable "project_name" {
  type    = string
  default = "taskflow"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "node_count" {
  default = 2
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}
