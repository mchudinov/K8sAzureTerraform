variable "service_princial_terraform_id" {
    description = "Azure App ID of the Terraform app"
    type        = string
}

variable "service_princial_terraform_secret" {}

variable "rg_name" {
  description = "Name for the resource group."  
  type     = string
}

variable "rg_node_name" {
    description = "Name of outbound IP address."
    type        = string
}

variable "ip_outbound_id" {
    description = "Id of outbound IP address."
    type        = string
}

variable "k8s_agent_count" {
    description = "Number of nodes in Kubernetes cluster"
    type        = number
}

variable "k8s_version" {
    description = "Kubernetes cluster version"
    type        = string
}

variable "k8s_vm_size" {
    description = "Kubernetes node size"
    type        = string
}

variable "k8s_dns_prefix" {
    description = "DNS prefix for k8s nodes."
    type        = string
}

variable "k8s_cluster_name" {
    description = "DNS name for k8s cluster."
    type        = string
}

variable "log_analytics_workspace_name" {
    description = "Name for log analytics."
    type        = string
}

variable "ip_inbound_domain_name" {
    description = "DNS name for inbound IP."
    type        = string
}

variable "storagename" {
    description = "Name for storage Azure resource."
    type        = string
}

variable "ip_inbound_name" {
    description = "Name for inbound IP Azure resource."
    type        = string
}

variable "location" {
    description = "Azure region for infrastructure components."
    type        = string
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
    description = "Azure region for log analytics"
    type        = string
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
    description = "Log analytics sku"
    type        = string
}

variable "tags" {
  type = map(string)
  default = {}
}