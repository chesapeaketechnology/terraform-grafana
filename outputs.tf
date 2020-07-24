output "grafana_fqdn" {
  value = azurerm_container_group.grafana.fqdn
}

output "grafana_ip_address" {
  value = azurerm_container_group.grafana.ip_address
}
