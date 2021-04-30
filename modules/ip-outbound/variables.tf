variable "ip_outbound_name" {
  description = "Name of outbound IP address."
  type        = string
}

variable "location" {
    description = "Azure region for infrastructure components."
    type        = string
}

variable "rg_name" {
  description = "Name for the resource group."  
  type     = string
}

variable "tags" {
  type = map(string)
  default = {}
}