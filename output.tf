output "public_ip_inbound_address" {
  value = module.k8s.public_ip_inbound_address
}

output "host" {
    value = module.k8s.host
}

output "fqdn" {
  value = module.k8s.fqdn
}