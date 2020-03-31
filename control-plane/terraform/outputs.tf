# ============== Network

output "dns_servers" {
  value = "168.63.129.16,8.8.8.8"
}

output "reserved_ip_ranges" {
  value = "${cidrhost(var.subnet_cidr, 1)}-${cidrhost(var.subnet_cidr, 9)}"
}

output "network" {
  value = "${module.infra.network_name}"
}

output "subnetwork" {
  value = "${module.infra.subnet_name}"
}

output "dns_managed_zone" {
  value = "${module.infra.dns_zone_name}"
}

output "internal_cidr" {
  value = "${var.subnet_cidr}"
}

output "internal_gw" {
  value = "${module.infra.subnet_gateway}"
}

# ============== OpsManager

output "ops_manager_dns" {
  value = "${replace(module.ops_manager.dns_name, "/\\.$/", "")}"
}

output "ops_manager_ip" {
  value = "${module.ops_manager.public_ip}"
}

output "ops_manager_ssh_private_key" {
  sensitive = true
  value     = "${module.ops_manager.ssh_private_key}"
}

output "ops_manager_ssh_public_key" {
  sensitive = true
  value     = "${module.ops_manager.ssh_public_key}"
}

output "ops_manager_username" {
  value = "${module.ops_manager.username}"
}

output "ops_manager_password" {
  value     = "${module.ops_manager.password}"
  sensitive = true
}

output "ops_manager_decryption_phrase" {
  value     = "${module.ops_manager.decryption_phrase}"
  sensitive = true
}

# ============== Concourse

output "plane_dns" {
  value = "${replace(module.concourse.plane_dns_name, "/\\.$/", "")}"
}

output "credhub_dns" {
  value = "${replace(module.concourse.credhub_dns_name, "/\\.$/", "")}"
}

output "uaa_dns" {
  value = "${replace(module.concourse.uaa_dns_name, "/\\.$/", "")}"
}

output "concourse_password" {
  value     = "${module.concourse.password}"
  sensitive = true
}

output "plane_target_pool" {
  value = "${module.concourse.plane_target_pool}"
}

output "plane_lb_name" {
  value = "${module.concourse.plane_lb_name}"
}

output "uaa_lb_name" {
  value = "${module.concourse.uaa_lb_name}"
}

output "credhub_lb_name" {
  value = "${module.concourse.credhub_lb_name}"
}

output "plane_lb_ip" {
  value = "${module.concourse.plane_lb_ip}"
}

# ============== Azure

output "location" {
  value = "${var.location}"
}

output "availability_zone_name" {
  value = "'null'"
}

output "subscription_id" {
  value = "${var.subscription_id}"
}

output "tenant_id" {
  value = "${var.tenant_id}"
}

output "client_id" {
  value = "${var.client_id}"
}

output "client_secret" {
  value = "${var.client_secret}"
  sensitive = true
}

output "bosh_root_storage_account" {
  value = "${module.infra.bosh_root_storage_account}"
}

output "plane_security_group_name" {
  value = "${module.concourse.plane_security_group_name}"
}

output "uaa_security_group_name" {
  value = "${module.concourse.uaa_security_group_name}"
}

output "credhub_security_group_name" {
  value = "${module.concourse.credhub_security_group_name}"
}

output "resource_group_name" {
  value = "${module.infra.resource_group_name}"
}
