variable "resource_group_name" {
  type        = string
  description = "Azure resource group in which to deploy"
}

variable "network_profile_id" {
  type        = string
  description = "Name of the network profile in which to create the container"
}

variable "location" {
  type        = string
  description = "Region to provision resources in"
}

variable "system_name" {
  type        = string
  description = "Name of the higher level system to which this server belongs"
}

variable "environment" {
  type        = string
  description = "Current environment to provision within (dev, prod, etc)"
}

variable "grafana_db_type" {
  type        = string
  description = "The database type being used for grafana data. Must be 'postgres' or 'mysql'."
  validation {
    condition     = var.grafana_db_type == "postgres" || var.grafana_db_type == "mysql"
    error_message = "Sorry, but only 'postgres' and 'mysql' are supported."
  }
}

variable "grafana_db_name" {
  type        = string
  description = "The database name."
  default     = "grafana"
}

variable "grafana_db_ssl_mode" {
  type        = string
  description = "The ssl mode for connetions to the database. Valid values are 'disable', 'require', & 'verify-full' for Postgres and 'true', 'false', & 'skip-verify' for MySql."

  validation {
    condition     = var.grafana_db_ssl_mode == "disable" || var.grafana_db_ssl_mode == "require" || var.grafana_db_ssl_mode == "verify-full" || var.grafana_db_ssl_mode == "true" || var.grafana_db_ssl_mode == "false" || var.grafana_db_ssl_mode == "skip-verify"
    error_message = "Sorry, but valid values are 'disable', 'require', & 'verify-full' for Postgres and 'true', 'false', & 'skip-verify' for MySql."
  }
}

variable "grafana_db_host" {
  type        = string
  description = "The hostname for the postgresql data store where Grafana's settings will be stored"
}

variable "grafana_db_username" {
  type        = string
  description = "The user name for logging into the Grafana data store"
}

variable "grafana_db_password" {
  type        = string
  description = "The credentials for logging into the Grafana data store"
}

variable "grafana_db_max_idle_conn" {
  type        = number
  description = "Maximum idle connections to database."
  default = 2
}

variable "grafana_db_max_open_conn" {
  type        = number
  description = "Maximum open connections to database."
  default = 0
}

variable "grafana_db_max_conn_lifetime" {
  type        = number
  description = "Maximum amount of time a connection can be reused in seconds."
  default = 14400
}

variable "grafana_admin_user" {
  type        = string
  description = "The administrative user for logging into the Grafana UI"
}

variable "grafana_admin_password" {
  type        = string
  description = "The administrative user password for logging into the Grafana UI"
}

variable "grafana_port" {
  type = number
  description = "The port on which Grafana should be accessed."
  default=3000
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}


variable "datasci_db_type" {
  type        = string
  description = "The database type being used for data science data. Must be 'postgres' or 'mysql'."
  validation {
    condition     = var.datasci_db_type == "postgres" || var.datasci_db_type == "mysql"
    error_message = "Sorry, but only 'postgres' and 'mysql' are supported."
  }
}

variable "datasci_db_name" {
  type        = string
  description = "The database name."
  default     = "grafana"
}

variable "datasci_db_ssl_mode" {
  type        = string
  description = "The ssl mode for connections to the database. Valid values are 'disable', 'require', & 'verify-full' for Postgres and 'true', 'false', & 'skip-verify' for MySql."

  validation {
    condition     = var.datasci_db_ssl_mode == "disable" || var.datasci_db_ssl_mode == "require" || var.datasci_db_ssl_mode == "verify-full" || var.datasci_db_ssl_mode == "true" || var.datasci_db_ssl_mode == "false" || var.datasci_db_ssl_mode == "skip-verify"
    error_message = "Sorry, but valid values are 'disable', 'require', & 'verify-full' for Postgres and 'true', 'false', & 'skip-verify' for MySql."
  }
}

variable "datasci_db_host" {
  type        = string
  description = "The hostname for the postgresql data source where data science data is accessed"
}

variable "datasci_db_username" {
  type        = string
  description = "The user name for logging into the data science data source"
}

variable "datasci_db_password" {
  type        = string
  description = "The credentials for logging into the data science data source"
}

variable "prometheus_server" {
  type        = string
  description = "The host/IP address of Prometheus server"
}

variable "consul_server" {
  type        = string
  description = "The host/IP address of a Consul server"
}

variable "consul_account_name" {
  type        = string
  description = "The consul share storage account name"
}

variable "consul_account_key" {
  type        = string
  description = "The consul share storage account key"
}