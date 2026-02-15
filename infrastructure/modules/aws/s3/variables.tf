variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "bucket_name" {
  description = "Base name for the bucket (will be suffixed)"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}
