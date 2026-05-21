output "controlplane_name" {
  description = "Name of the Control plane node"
  value       = hcloud_server.controlplane.name
}

output "controlplane_ipv4" {
  description = "Public IPv4 address - Control plane"
  value       = hcloud_server.controlplane.ipv4_address
}

# output "worker01_ipv4" {
#   description = "Public IPv4 address - Worker01"
#   value       = hcloud_server.wn01.ipv4_address
# }
#
# output "worker02_ipv4" {
#   description = "Public IPv4 address - Worker02"
#   value       = hcloud_server.wn02.ipv4_address
# }
#
# output "worker03_ipv4" {
#   description = "Public IPv4 address - Worker03"
#   value       = hcloud_server.wn03.ipv4_address
# }


# output "controlplane_ipv6" {
#   description = "Public IPv6 address"
#   value       = hcloud_server.controlplane.ipv6_address
# }

# output "private_ip" {
#   description = "Private IP within the network"
#   value       = "10.0.1.10"
# }

# output "floating_ip" {
#   description = "Floating IP address (if enabled)"
#   value       = var.enable_floating_ip ? hcloud_floating_ip.default[0].ip_address : null
# }

# output "ssh_key_fingerprint" {
#   description = "Fingerprint of the SSH key"
#   value       = hcloud_ssh_key.default.fingerprint
# }
