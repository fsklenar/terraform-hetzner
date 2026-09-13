output "server_id" {
  description = "ID of the created server"
  value       = hcloud_server.default.id
}

output "server_name" {
  description = "Name of the server"
  value       = hcloud_server.default.name
}

output "server_ipv4" {
  description = "Public IPv4 address"
  value       = hcloud_server.default.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address"
  value       = hcloud_server.default.ipv6_address
}

output "private_ip" {
  description = "Private IP within the network"
  value       = "10.0.1.10"
}

output "floating_ip" {
  description = "Floating IP address (if enabled)"
  value       = var.enable_floating_ip ? hcloud_floating_ip.default[0].ip_address : null
}

output "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key"
  value       = hcloud_ssh_key.default.fingerprint
}
