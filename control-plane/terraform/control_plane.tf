provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  environment     = var.cloud_name
}

terraform {
  required_version = "> 0.12.0"
}

locals {
  # ensure prefix is <= 10 chars
  storage_account_prefix = "${substr("${var.env_name}", 0, min(10, length(var.env_name)))}"
}

resource "random_string" "storage_account_suffix" {
  length = 4
  upper = false
  special = false
}

module "infra" {
  source = "./infra"

  env_name              = var.env_name
  location              = var.location
  dns_subdomain         = var.dns_subdomain
  dns_suffix            = var.dns_suffix
  network_address_space = var.network_address_space
  subnet_cidr           = var.subnet_cidr

  storage_account_prefix = "${local.storage_account_prefix}"
  storage_account_suffix = "${random_string.storage_account_suffix.result}"
}

module "ops_manager" {
  source = "./ops_manager"

  env_name       = var.env_name
  location       = var.location

  ops_manager_image_uri  = var.ops_manager_image_uri
  ops_manager_vm_size    = var.ops_manager_vm_size
  ops_manager_private_ip = "${cidrhost(var.subnet_cidr, 4)}"

  resource_group_name = "${module.infra.resource_group_name}"
  dns_zone_name       = "${module.infra.dns_zone_name}"
  subnet_id           = "${module.infra.subnet_id}"

  storage_account_prefix = "${local.storage_account_prefix}"
  storage_account_suffix = "${random_string.storage_account_suffix.result}"
}

module "concourse" {
  source = "./concourse"

  env_name            = var.env_name
  location            = var.location
  resource_group_name = "${module.infra.resource_group_name}"
  dns_zone_name       = "${module.infra.dns_zone_name}"
}
