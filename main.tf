terraform {
  required_version = "~> 0.12"
  experiments      = [variable_validation]
}

provider "azurerm" {
  version = "~> 2.18.0"
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration = true
}

data "azurerm_resource_group" "grafana_resource_group" {
  name = var.resource_group_name
}

# Create a Container Group
resource "azurerm_container_group" "grafana" {
  name                = join("-", [var.system_name, var.environment, "grafana"])
  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name
  location            = data.azurerm_resource_group.grafana_resource_group.location
  ip_address_type     = "private"
  network_profile_id  = var.network_profile_id
  os_type             = "Linux"
  restart_policy      = "OnFailure"

  tags = var.default_tags

  # Grafana Server
  container {
    name   = "grafana-server"
    image  = "chesapeaketechnology/grafana:v0.9.1"
    cpu    = "4.0"
    memory = "8.0"

    ports {
      port     = 3000
      protocol = "TCP"
    }
    environment_variables = {
      GF_DATABASE_TYPE=var.grafana_db_type
      GF_DATABASE_HOST=var.grafana_db_host
      GF_DATABASE_NAME=var.grafana_db_name
      GF_DATABASE_USER=var.grafana_db_username
      GF_DATABASE_PASSWORD=var.grafana_db_password
      GF_DATABASE_MAX_IDLE_CONN=var.grafana_db_max_idle_conn
      GF_DATABASE_MAX_OPEN_CONN=var.grafana_db_max_open_conn
      GF_DATABASE_CONN_MAX_LIFETIME=var.grafana_db_max_conn_lifetime
      GF_DATABASE_SSL_MODE=var.grafana_db_ssl_mode
      GF_SERVER_HTTP_PORT=var.grafana_port
      GF_SECURITY_ADMIN_USER=var.grafana_admin_user
      GF_SECURITY_ADMIN_PASSWORD=var.grafana_admin_password
      DS_DATABASE_TYPE=var.datasci_db_type
      DS_DATABASE_HOST=var.datasci_db_host
      DS_DATABASE_NAME=var.datasci_db_name
      DS_DATABASE_USER=var.datasci_db_username
      DS_DATABASE_PASSWORD=var.datasci_db_password
      DS_PROMETHEUS_HOST=var.prometheus_server
    }
  }
}
