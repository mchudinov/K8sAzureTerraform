output "public_ip_inbound_address" {
  value = azurerm_public_ip.inbound.ip_address
}

output "host" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
}

# output "client_key" {
#     value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
# }

# output "client_certificate" {
#     value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
# }

# output "cluster_ca_certificate" {
#     value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
# }

# output "cluster_username" {
#     value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
# }

# output "cluster_password" {
#     value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
# }