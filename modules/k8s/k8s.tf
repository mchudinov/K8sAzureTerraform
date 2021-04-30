resource "random_id" "random" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "law" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.random.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = var.rg_name
    sku                 = var.log_analytics_workspace_sku
    
    tags = var.tags
}

resource "azurerm_log_analytics_solution" "law" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.law.location
    resource_group_name   = var.rg_name
    workspace_resource_id = azurerm_log_analytics_workspace.law.id
    workspace_name        = azurerm_log_analytics_workspace.law.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    depends_on          = [azurerm_log_analytics_workspace.law]
    name                = var.k8s_cluster_name
    location            = var.location
    resource_group_name = var.rg_name
    dns_prefix          = var.k8s_dns_prefix
    node_resource_group = var.rg_node_name  
    kubernetes_version  = var.k8s_version

    network_profile {
        network_plugin = "kubenet"
        outbound_type   = "loadBalancer"
        load_balancer_sku = "standard"        
        load_balancer_profile {
            outbound_ip_address_ids = [ var.ip_outbound_id ]
        }
    }    

    role_based_access_control {
        enabled = true
    }
    
    # https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/
    default_node_pool {
        name            = "default"
        enable_auto_scaling = false
        node_count      = var.k8s_agent_count
        vm_size         = var.k8s_vm_size
    }

    service_principal {
        client_id     = var.service_princial_terraform_id
        client_secret = var.service_princial_terraform_secret
    }

    addon_profile {
        azure_policy {
            enabled     = true
        }

        oms_agent {
            enabled                    = true
            log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
        }
    }
    
    tags = var.tags
}

resource "azurerm_public_ip" "inbound" {
    depends_on          = [azurerm_kubernetes_cluster.k8s]
    name                = var.ip_inbound_name
    resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group    
    location            = var.location
    ip_version          = "IPv4"
    sku                 = "standard"
    allocation_method   = "Static"
    domain_name_label   = var.ip_inbound_domain_name 

    tags = var.tags
}

resource "azurerm_storage_account" "storageaccount" {
    name                     = var.storagename
    resource_group_name      = var.rg_name
    location                 = var.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "cool" 

    tags = var.tags
}
