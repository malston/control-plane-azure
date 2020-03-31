variable "env_name" {
  default = ""
}

variable "storage_account_prefix" {
  default = ""
}

variable "storage_account_suffix" {
  default = ""
}

variable "location" {
  default = ""
}

variable "dns_subdomain" {
  default = ""
}

variable "dns_suffix" {
  default = ""
}

variable "network_address_space" {
  type    = list
  default = []
}

variable "subnet_cidr" {
  default = ""
}

# ============== Resource Group

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.env_name}"
  location = "${var.location}"
}

# ============= Networking

resource "azurerm_virtual_network" "controlplane_virtual_network" {
  name                = "${var.env_name}-controlplane-virtual-network"
  depends_on          = [azurerm_resource_group.resource_group]
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  address_space       = "${var.network_address_space}"
  location            = "${var.location}"
}

resource "azurerm_subnet" "controlplane_subnet" {
  name                      = "${var.env_name}-controlplane-subnet"
  depends_on                = [azurerm_resource_group.resource_group]
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name      = "${azurerm_virtual_network.controlplane_virtual_network.name}"
  address_prefix            = "${var.subnet_cidr}"
}

# ============= DNS

locals {
  dns_subdomain = "${var.env_name}"
}

resource "azurerm_dns_zone" "env_dns_zone" {
  name                = "${var.dns_subdomain != "" ? var.dns_subdomain : local.dns_subdomain}.${var.dns_suffix}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

# ============= Outputs

output "dns_zone_name" {
  value = "${azurerm_dns_zone.env_dns_zone.name}"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.resource_group.name}"
}

output "network_name" {
  value = "${azurerm_virtual_network.controlplane_virtual_network.name}"
}

output "subnet_id" {
  value = "${azurerm_subnet.controlplane_subnet.id}"
}

output "subnet_name" {
  value = "${azurerm_subnet.controlplane_subnet.name}"
}

output "subnet_gateway" {
  value = "${cidrhost(azurerm_subnet.controlplane_subnet.address_prefix, 1)}"
}
