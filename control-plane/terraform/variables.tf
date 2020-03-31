variable "location" {}

variable "subscription_id" {}

variable "tenant_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "dns_suffix" {}

variable "dns_subdomain" {
  type        = string
  description = "The base subdomain used for PCF. For example, if your dns_subdomain is `cf`, and your dns_suffix is `pivotal.io`, your PCF domain would be `cf.pivotal.io`"
  default     = "pcf"
}

variable "env_name" {
  description = "An arbitrary unique name for namespacing resources."
  type        = string
  default     = "controlplane"
}

variable "cloud_name" {
  description = "The Azure cloud environment to use. Available values at https://www.terraform.io/docs/providers/azurerm/#environment"
  default     = "public"
}

# ============= Network

variable "network_address_space" {
  type    = list
  default = ["10.0.0.0/24"]
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/26"
}

# ============= Opsman

variable "ops_manager_username" {
  type    = string
  default = "admin"
}

variable "ops_manager_password" {
  description = "Password for administrator user. Generated if left blank."
  type        = string
  default     = ""
}

variable "ops_manager_decryption_phrase" {
  description = "Decryption Phrase for Ops Manager Authentication. Generated if left blank."
  type        = string
  default     = ""
}

variable "ops_manager_image_uri" {
  description = "URL to the OpsMan VHD file on Azure. You can find the URL for your region in the Pivnet OpsMan yaml file."
  type        = string
  default     = ""
}

variable "ops_manager_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}
