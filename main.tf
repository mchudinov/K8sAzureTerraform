terraform {
  required_version = "~> 0.15.0"
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.49.0"
    }
  }
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.     
  features {}
}

resource "random_id" "random" {
    byte_length = 8
}

module "ip-outbound" {
  source = "./modules/ip-outbound"
  location = var.azure_region
  rg_name = var.rg_name
  ip_outbound_name = "ip-outbound-${var.deployment_name}"
  
  tags = {
    Source = "terraform"
    ApplicationName = var.deployment_name
  }
}

module "k8s" {
  source = "./modules/k8s"
  depends_on = [module.ip-outbound]

  location = module.ip-outbound.location
  rg_name = module.ip-outbound.rg_name
  service_princial_terraform_id = var.service_princial_terraform_id
  service_princial_terraform_secret = var.service_princial_terraform_secret
  ip_outbound_id = module.ip-outbound.ip_outbound_id
  rg_node_name = "rg-node-${var.deployment_name}"        
  k8s_dns_prefix = var.k8s_cluster_name
  k8s_cluster_name = var.k8s_cluster_name
  log_analytics_workspace_name = "log-k8s-${var.deployment_name}"
  ip_inbound_domain_name = var.deployment_name
  ip_inbound_name = "ip-inbound-${var.deployment_name}"
  storagename = "st${random_id.random.dec}"
  k8s_agent_count = var.k8s_agent_count
  k8s_version = var.k8s_version
  k8s_vm_size = var.k8s_vm_size 
  log_analytics_workspace_location = module.ip-outbound.location
  log_analytics_workspace_sku = "PerGB2018"

  tags = {
    Source = "terraform"
    ApplicationName = var.deployment_name
  }
}

# Varaibles passed from environment variables from deployment script
variable "service_princial_terraform_id" {}
variable "service_princial_terraform_secret" {}
variable "k8s_agent_count" {}
variable "deployment_name" {}
variable "rg_name" {}
variable "k8s_cluster_name" {}
variable "azure_region" {}
variable "k8s_version" {}
variable "k8s_vm_size" {}