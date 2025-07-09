variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-app-config-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "appconfigdemo"
  
  validation {
    condition     = length(var.prefix) <= 15 && can(regex("^[a-z0-9]+$", var.prefix))
    error_message = "Prefix must be 15 characters or less and contain only lowercase letters and numbers."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "App Config Demo"
    ManagedBy   = "Terraform"
  }
}
