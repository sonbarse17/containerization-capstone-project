variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "retention_in_days" {
  description = "Days to retain logs"
  type        = number
  default     = 30
}
