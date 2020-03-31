variable "env_name" {
  default = ""
}

variable "location" {
  default = ""
}

variable "resource_group_name" {
  default = ""
}

variable "concourse_password" {
  default = ""
}

variable "dns_zone_name" {
  default = ""
}

# ============== Generators

resource "random_id" "concourse_password_generator" {
  byte_length = 16
}

# ============== DNS

resource "azurerm_dns_a_record" "plane_dns" {
  name                = "plane"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = "60"
  records             = ["${azurerm_public_ip.plane.ip_address}"]
}

resource "azurerm_dns_a_record" "uaa_dns" {
  name                = "uaa"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = "60"
  records             = ["${azurerm_public_ip.uaa.ip_address}"]
}

resource "azurerm_dns_a_record" "credhub_dns" {
  name                = "credhub"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = "60"
  records             = ["${azurerm_public_ip.credhub.ip_address}"]
}

# ============== LB

resource "azurerm_public_ip" "plane" {
  name                         = "${var.env_name}-plane-lb"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_public_ip" "tsa" {
  name                         = "${var.env_name}-tsa-lb"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_public_ip" "uaa" {
  name                         = "${var.env_name}-uaa-lb"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_public_ip" "credhub" {
  name                         = "${var.env_name}-credhub-lb"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_lb" "plane" {
  name                = "${var.env_name}-plane-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.env_name}-plane-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.plane.id
  }
}

resource "azurerm_lb" "credhub" {
  name                = "${var.env_name}-credhub-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.env_name}-credhub-frontend-ip-configuration"
    public_ip_address_id = "${azurerm_public_ip.credhub.id}"
  }
}

resource "azurerm_lb" "uaa" {
  name                = "${var.env_name}-uaa-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.env_name}-uaa-frontend-ip-configuration"
    public_ip_address_id = "${azurerm_public_ip.uaa.id}"
  }
}

resource "azurerm_lb" "tsa" {
  name                = "${var.env_name}-tsa-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.env_name}-tsa-frontend-ip-configuration"
    public_ip_address_id = "${azurerm_public_ip.tsa.id}"
  }
}

resource "azurerm_lb_rule" "plane-https" {
  name                = "${var.env_name}-plane-https"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.plane.id}"

  frontend_ip_configuration_name = "${var.env_name}-plane-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 443
  backend_port                   = 443

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.plane.id}"
  probe_id                = "${azurerm_lb_probe.plane-https.id}"
}

resource "azurerm_lb_probe" "plane-https" {
  name                = "${var.env_name}-plane-https"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.plane.id}"
  protocol            = "TCP"
  port                = 443
}

resource "azurerm_lb_rule" "plane-http" {
  name                = "${var.env_name}-plane-http"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.plane.id}"

  frontend_ip_configuration_name = "${var.env_name}-plane-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.plane.id}"
  probe_id                = "${azurerm_lb_probe.plane-http.id}"
}

resource "azurerm_lb_probe" "plane-http" {
  name                = "${var.env_name}-plane-http"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.plane.id}"
  protocol            = "TCP"
  port                = 80
}

resource "azurerm_lb_rule" "uaa" {
  name                = "${var.env_name}-uaa"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.uaa.id}"

  frontend_ip_configuration_name = "${var.env_name}-uaa-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 8443
  backend_port                   = 8443

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.uaa.id}"
  probe_id                = "${azurerm_lb_probe.uaa.id}"
}

resource "azurerm_lb_probe" "uaa" {
  name                = "${var.env_name}-uaa"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.uaa.id}"
  protocol            = "TCP"
  port                = 8443
}

resource "azurerm_lb_rule" "tsa" {
  name                = "${var.env_name}-tsa"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.tsa.id}"

  frontend_ip_configuration_name = "${var.env_name}-tsa-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 2222
  backend_port                   = 2222

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.tsa.id}"
  probe_id                = "${azurerm_lb_probe.tsa.id}"
}

resource "azurerm_lb_probe" "tsa" {
  name                = "${var.env_name}-tsa"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.tsa.id}"
  protocol            = "TCP"
  port                = 2222
}

resource "azurerm_lb_rule" "credhub" {
  name                = "${var.env_name}-credhub"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.credhub.id}"

  frontend_ip_configuration_name = "${var.env_name}-credhub-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 8844
  backend_port                   = 8844

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.credhub.id}"
  probe_id                = "${azurerm_lb_probe.credhub.id}"
}

resource "azurerm_lb_probe" "credhub" {
  name                = "${var.env_name}-credhub"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.credhub.id}"
  protocol            = "TCP"
  port                = 8844
}

# ============== Network Security Group

resource "azurerm_network_security_group" "plane_security_group" {
  name                = "${var.env_name}-plane-security-group"
  location            = "${var.location}"
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_network_security_group" "credhub_security_group" {
  name                = "${var.env_name}-credhub-security-group"
  location            = "${var.location}"
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_network_security_group" "tsa_security_group" {
  name                = "${var.env_name}-tsa-security-group"
  location            = "${var.location}"
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_network_security_group" "uaa_security_group" {
  name                = "${var.env_name}-uaa-security-group"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_network_security_rule" "plane-http" {
  name                        = "${var.env_name}-plane-http"
  priority                    = 209
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${azurerm_network_security_group.plane_security_group.name}"
}

resource "azurerm_network_security_rule" "plane-https" {
  name                        = "${var.env_name}-plane-https"
  priority                    = 208
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${azurerm_network_security_group.plane_security_group.name}"
}

resource "azurerm_network_security_rule" "credhub" {
  name                        = "${var.env_name}-credhub"
  priority                    = 207
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8844"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${azurerm_network_security_group.credhub_security_group.name}"
}

resource "azurerm_network_security_rule" "tsa" {
  name                        = "${var.env_name}-tsa"
  priority                    = 207
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2222"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${azurerm_network_security_group.tsa_security_group.name}"
}

resource "azurerm_network_security_rule" "uaa" {
  name                        = "${var.env_name}-uaa"
  priority                    = 206
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${azurerm_network_security_group.uaa_security_group.name}"
}

resource "azurerm_lb_backend_address_pool" "plane" {
  name                = "${var.env_name}-plane-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.plane.id}"
}

resource "azurerm_lb_backend_address_pool" "credhub" {
  name                = "${var.env_name}-credhub-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.credhub.id}"
}

resource "azurerm_lb_backend_address_pool" "uaa" {
  name                = "${var.env_name}-uaa-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.uaa.id}"
}

resource "azurerm_lb_backend_address_pool" "tsa" {
  name                = "${var.env_name}-tsa-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = "${azurerm_lb.tsa.id}"
}

# ============== Outputs

output "plane_target_pool" {
  value = "${azurerm_lb_backend_address_pool.plane.name}"
}

output "uaa_target_pool" {
  value = "${azurerm_lb_backend_address_pool.uaa.name}"
}

output "credhub_target_pool" {
  value = "${azurerm_lb_backend_address_pool.credhub.name}"
}

output "plane_security_group_name" {
  value = "${azurerm_network_security_group.plane_security_group.name}"
}

output "uaa_security_group_name" {
  value = "${azurerm_network_security_group.uaa_security_group.name}"
}

output "credhub_security_group_name" {
  value = "${azurerm_network_security_group.credhub_security_group.name}"
}

output "tsa_security_group_name" {
  value = "${azurerm_network_security_group.tsa_security_group.name}"
}

output "plane_lb_name" {
  value = "${azurerm_lb.plane.name}"
}

output "uaa_lb_name" {
  value = "${azurerm_lb.uaa.name}"
}

output "credhub_lb_name" {
  value = "${azurerm_lb.credhub.name}"
}

output "plane_lb_ip" {
  value = "${azurerm_public_ip.plane.ip_address}"
}

output "credhub_lb_ip" {
  value = "${azurerm_public_ip.credhub.ip_address}"
}

output "uaa_lb_ip" {
  value = "${azurerm_public_ip.uaa.ip_address}"
}

output "password" {
  value     = "${var.concourse_password == "" ? random_id.concourse_password_generator.b64 : var.concourse_password}"
  sensitive = true
}

output "plane_dns_name" {
  value = "${azurerm_dns_a_record.plane_dns.name}.${azurerm_dns_a_record.plane_dns.zone_name}"
}

output "uaa_dns_name" {
  value = "${azurerm_dns_a_record.uaa_dns.name}.${azurerm_dns_a_record.uaa_dns.zone_name}"
}

output "credhub_dns_name" {
  value = "${azurerm_dns_a_record.credhub_dns.name}.${azurerm_dns_a_record.credhub_dns.zone_name}"
}

