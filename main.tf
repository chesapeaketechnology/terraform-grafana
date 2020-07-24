terraform {
  required_version = "~> 0.12"
  experiments      = [variable_validation]
}

provider "azurerm" {
  version = "~> 2.0"
  features {}
  disable_terraform_partner_id = true
}

data "azurerm_resource_group" "grafana_resource_group" {
  name = var.resource_group_name
}


data "azurerm_virtual_network" "grafana_net" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name
}

# Create subnet for use with containers
resource "azurerm_subnet" "grafana_subnet" {
  name                 = "grafana_subnet"
  resource_group_name  = data.azurerm_resource_group.grafana_resource_group.name
  virtual_network_name = data.azurerm_virtual_network.grafana_net.name
  address_prefixes     = var.subnet_cidrs

  delegation {
    name = "grafana_subnet_delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "grafana_net_profile" {
  name                = join("-", [var.system_name, var.environment, "gf-net-profile"])
  location            = data.azurerm_resource_group.grafana_resource_group.location
  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name

  container_network_interface {
    name = "container_nic"

    ip_configuration {
      name = "container_ip_config"
      subnet_id = azurerm_subnet.grafana_subnet.id
    }
  }
}

# Create a Container Group
resource "azurerm_container_group" "grafana" {
  name                = join("-", [var.system_name, var.environment, "grafana"])
  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name
  location            = data.azurerm_resource_group.grafana_resource_group.location
  ip_address_type     = "public"
  dns_name_label      = "gf-label"
  os_type             = "Linux"

  tags = var.default_tags

  # Grafana Server
  container {
    name   = "grafana-server"
    image  = "lstroud/grafana:latest"
    cpu    = "1.0"
    memory = "2.0"

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
    }
  }
}

//# Create nginx public IP address
//resource "azurerm_public_ip" "grafana_ip" {
//  name                = join("-", ["pip", var.cluster_name, var.environment, "grafana"])
//  location            = data.azurerm_resource_group.grafana_resource_group.location
//  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name
//  allocation_method   = "Static"
//  domain_name_label   = join("-", [var.cluster_name, var.environment, "grafana"])
//
//  tags = merge(
//  var.default_tags,
//  map("name", "grafana")
//  )
//}

//# Create Network Security Group and rule
//resource "azurerm_network_security_group" "grafana_nsg" {
//  name                = join("-", ["nsg", var.cluster_name, var.environment, "grafana"])
//  location            = data.azurerm_resource_group.grafana_resource_group.location
//  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name
//
//  tags = var.default_tags
//
//  security_rule {
//    name                       = "SSH"
//    priority                   = 1001
//    direction                  = "Inbound"
//    access                     = "Allow"
//    protocol                   = "Tcp"
//    source_port_range          = "*"
//    destination_port_range     = "22"
//    source_address_prefix      = "*"
//    destination_address_prefix = "*"
//  }
//
//  security_rule {
//    name                       = "HTTP"
//    priority                   = 2001
//    direction                  = "Inbound"
//    access                     = "Allow"
//    protocol                   = "Tcp"
//    source_port_range          = "*"
//    destination_port_range     = "80"
//    source_address_prefix      = "*"
//    destination_address_prefix = "*"
//  }
//
//  security_rule {
//    name                       = "HTTP3000"
//    priority                   = 2002
//    direction                  = "Inbound"
//    access                     = "Allow"
//    protocol                   = "Tcp"
//    source_port_range          = "*"
//    destination_port_range     = "3000"
//    source_address_prefix      = "*"
//    destination_address_prefix = "*"
//  }
//
//  security_rule {
//    name                       = "HTTPS"
//    priority                   = 3001
//    direction                  = "Inbound"
//    access                     = "Allow"
//    protocol                   = "Tcp"
//    source_port_range          = "*"
//    destination_port_range     = "443"
//    source_address_prefix      = "*"
//    destination_address_prefix = "*"
//  }
//
//  security_rule {
//    name                       = "POSTGRES"
//    priority                   = 4001
//    direction                  = "Inbound"
//    access                     = "Allow"
//    protocol                   = "Tcp"
//    source_port_range          = "*"
//    destination_port_range     = "5432"
//    source_address_prefix      = "*"
//    destination_address_prefix = "*"
//  }
//}
//
//resource "azurerm_subnet_network_security_group_association" "grafana_subnet_nsg" {
//  subnet_id                 = azurerm_public_ip.grafana_ip.id
//  network_security_group_id = azurerm_network_security_group.grafana_nsg.id
//}

//# Generate random text for a unique storage account name
//resource "random_id" "grafana_randomStorageId" {
//  keepers = {
//    # Generate a new ID only when a new resource group is defined
//    resource_group = data.azurerm_resource_group.grafana_resource_group.name
//  }
//  byte_length = 8
//}
//
//# Create storage account for grafana data
//resource "azurerm_storage_account" "grafana_storage" {
//  name                     = "stdiag${random_id.grafana_randomStorageId.hex}"
//  resource_group_name      = data.azurerm_resource_group.grafana_resource_group.name
//  location                 = data.azurerm_resource_group.grafana_resource_group.location
//  account_tier             = "Standard"
//  account_replication_type = "LRS"
//
//  tags = var.default_tags
//}

# Create an Azure File Share for the Grafana data
//resource "azurerm_storage_share" "grafana" {
//  name                 = join("-", [var.cluster_name, var.environment, "grafana-file-share"])
//  storage_account_name = azurerm_storage_account.grafana_storage.name
//  quota                = 10
//}
//
//# Create an Azure File Share for the Grafana DB Data
//resource "azurerm_storage_share" "grafanadb" {
//  name                 = join("-", [var.cluster_name, var.environment, "grafana-postgres-file-share"])
//  storage_account_name = azurerm_storage_account.grafana_storage.name
//  quota                = 10
//}



//resource "azurerm_subnet" "grafana_frontend" {
//  name                 = "grafana_frontend"
//  resource_group_name  = data.azurerm_resource_group.grafana_resource_group.name
//  virtual_network_name = data.azurerm_virtual_network.grafana_net.name
//  address_prefixes     = ["10.0.11.0/24"]
//}



#Use an application gateway to bridge public to private subnet
//resource "azurerm_application_gateway" "network" {
//  name                = join("-", ["agw", var.cluster_name, var.environment, "grafana"])
//  resource_group_name = data.azurerm_resource_group.grafana_resource_group.name
//  location            = data.azurerm_resource_group.grafana_resource_group.location
//
//  sku {
//    name     = "Standard_Small"
//    tier     = "Standard_v2"
//    capacity = 2
//  }
//
//  gateway_ip_configuration {
//    name      = join("-", ["agw", var.cluster_name, var.environment, "grafana.ipconf"])
//    subnet_id = azurerm_subnet.grafana_frontend.id
//  }
//
//  frontend_port {
//    name = join("-", ["agw", var.cluster_name, var.environment, "grafana", "http"])
//    port = 80
//  }
//
//  frontend_ip_configuration {
//    name                 = local.frontend_ip_configuration_name
//    public_ip_address_id = azurerm_public_ip.example.id
//  }
//
//  backend_address_pool {
//    name = local.backend_address_pool_name
//  }
//
//  backend_http_settings {
//    name                  = local.http_setting_name
//    cookie_based_affinity = "Disabled"
//    path                  = "/path1/"
//    port                  = 80
//    protocol              = "Http"
//    request_timeout       = 60
//  }
//
//  http_listener {
//    name                           = local.listener_name
//    frontend_ip_configuration_name = local.frontend_ip_configuration_name
//    frontend_port_name             = local.frontend_port_name
//    protocol                       = "Http"
//  }
//
//  request_routing_rule {
//    name                       = local.request_routing_rule_name
//    rule_type                  = "Basic"
//    http_listener_name         = local.listener_name
//    backend_address_pool_name  = local.backend_address_pool_name
//    backend_http_settings_name = local.http_setting_name
//  }
//}


