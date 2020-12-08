# Terraform Grafana Container
Terraform scripts for creating a grafana server

## Features
* Deploy a containerized Grafana instance

## Deploy
You can use this terraform module to deploy Grafana as a docker container into the azure cloud.  It can be 
referenced from within another terraform project as a module.  For example:

```
module "grafana-server" {
  source               = "github.com/chesapeaketechnology/terraform-grafana"
  resource_group_name  = var.resource_group_name
  system_name          = var.cluster_name
  location             = var.location
  environment          = var.environment
  default_tags         = var.default_tags
  grafana_admin_user   = var.grafana_admin_user
  grafana_admin_password = random_password.grafana_admin_password.result
  grafana_db_type      = "postgres"
  grafana_db_host      = module.grafana-data.server_fqdn
  grafana_db_ssl_mode  = "require"
  grafana_db_username  = "${module.grafana-data.administrator_login}@${module.grafana-data.server_name}"
  grafana_db_password  = module.grafana-data.administrator_password
  subnet_cidrs         = [var.subnet_cidr]
}
```


## Changelog

##### [1.0](https://github.com/chesapeaketechnology/terraform-grafana/releases/tag/v1.0) - 2020-12-08
* Updated the grafana docker version to v1.0.

##### [0.1.0]() - 2020-07-24
* First cut of grafana terraform module.

## Contact
* **Les Stroud** - [lstroud](https://github.com/lstroud)  
