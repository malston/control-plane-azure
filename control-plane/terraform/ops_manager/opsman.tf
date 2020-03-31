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

variable "ops_manager_private_ip" {
  default = ""
}

variable "ops_manager_image_uri" {
  default = ""
}

variable "ops_manager_vm_size" {
  default = ""
}

variable "resource_group_name" {
  default = ""
}

variable "subnet_id" {
  default = ""
}

variable "dns_zone_name" {
  default = ""
}

variable "ops_manager_username" {
  default = "admin"
}

variable "ops_manager_password" {
  default = ""
}

variable "ops_manager_decryption_phrase" {
  default = ""
}

# ============== Generators

resource "random_id" "ops_manager_password_generator" {
  byte_length = 16
}

resource "random_id" "ops_manager_decryption_phrase_generator" {
  byte_length = 16
}

# ============== Security Groups

resource "azurerm_network_security_group" "ops_manager_security_group" {
  name                = "${var.env_name}-ops-manager-security-group"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 204
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 205
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# ============== Storage

resource "azurerm_storage_account" "ops_manager_storage_account" {
  name                     = "${var.storage_account_prefix}opsmanager${var.storage_account_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ops_manager_storage_container" {
  name                  = "opsmanagerimage"
  depends_on            = [azurerm_storage_account.ops_manager_storage_account]
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.ops_manager_storage_account.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ops_manager_image" {
  name                   = "opsman.vhd"
  type                   = "page"
  resource_group_name    = var.resource_group_name
  storage_account_name   = "${azurerm_storage_account.ops_manager_storage_account.name}"
  storage_container_name = "${azurerm_storage_container.ops_manager_storage_container.name}"
  source_uri             = "${var.ops_manager_image_uri}"
}

# ============== DNS

resource "azurerm_dns_a_record" "ops_manager_dns" {
  name                = "opsman"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = var.resource_group_name
  ttl                 = "60"
  records             = ["${azurerm_public_ip.ops_manager_public_ip.ip_address}"]
}

# ============== VMs

resource "azurerm_public_ip" "ops_manager_public_ip" {
  name                         = "${var.env_name}-ops-manager-public-ip"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "ops_manager_nic" {
  name                      = "${var.env_name}-ops-manager-nic"
  depends_on                = [azurerm_public_ip.ops_manager_public_ip]
  location                  = var.location
  resource_group_name       = var.resource_group_name
  network_security_group_id = "${azurerm_network_security_group.ops_manager_security_group.id}"

  ip_configuration {
    name                          = "${var.env_name}-ops-manager-ip-config"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.ops_manager_private_ip}"
    public_ip_address_id          = "${azurerm_public_ip.ops_manager_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "ops_manager_vm" {
  name                          = "${var.env_name}-ops-manager-vm"
  depends_on                    = [azurerm_network_interface.ops_manager_nic, azurerm_storage_blob.ops_manager_image]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = ["${azurerm_network_interface.ops_manager_nic.id}"]
  vm_size                       = "${var.ops_manager_vm_size}"
  delete_os_disk_on_termination = "true"

  storage_os_disk {
    name          = "opsman-disk.vhd"
    vhd_uri       = "${azurerm_storage_account.ops_manager_storage_account.primary_blob_endpoint}${azurerm_storage_container.ops_manager_storage_container.name}/opsman-disk.vhd"
    image_uri     = "${azurerm_storage_blob.ops_manager_image.url}"
    caching       = "ReadWrite"
    os_type       = "linux"
    create_option = "FromImage"
    disk_size_gb  = "150"
  }

  os_profile {
    computer_name  = "${var.env_name}-ops-manager"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${tls_private_key.ops_manager.public_key_openssh}"
    }
  }
}

resource "tls_private_key" "ops_manager" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# OUTPUT ==============

output "dns_name" {
  value = "${azurerm_dns_a_record.ops_manager_dns.name}.${azurerm_dns_a_record.ops_manager_dns.zone_name}"
}

output "public_ip" {
  value = "${azurerm_public_ip.ops_manager_public_ip.ip_address}"
}

output "ssh_public_key" {
  sensitive = true
  value     = "${tls_private_key.ops_manager.public_key_openssh}"
}

output "ssh_private_key" {
  sensitive = true
  value     = "${tls_private_key.ops_manager.private_key_pem}"
}

output "username" {
  value = "${var.ops_manager_username}"
}

output "password" {
  value     = "${var.ops_manager_password == "" ? random_id.ops_manager_password_generator.b64 : var.ops_manager_password}"
  sensitive = true
}

output "decryption_phrase" {
  value     = "${var.ops_manager_decryption_phrase == "" ? random_id.ops_manager_decryption_phrase_generator.b64 : var.ops_manager_decryption_phrase}"
  sensitive = true
}
