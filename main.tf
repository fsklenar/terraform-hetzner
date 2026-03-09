terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60"
    }
  }
  required_version = ">= 1.14"

  # Hetzner Object Storage is S3-compatible — use the S3 backend.
  # Credentials are supplied via environment variables or a partial config file
  # (terraform init -backend-config=backend.hcl) because backend blocks
  # do not support Terraform variable references.
  #
  # Required env vars (or entries in backend.hcl):
  #   AWS_ACCESS_KEY_ID     = <Hetzner Object Storage Access Key>
  #   AWS_SECRET_ACCESS_KEY = <Hetzner Object Storage Secret Key>
  #
  # Create the bucket in the Hetzner Console before running terraform init.
  backend "s3" {
    bucket = "terraform-state-fsk-vm-hetzner"          # name of your Hetzner Object Storage bucket
    key    = "terraform.tfstate"        # path to the state file inside the bucket

    endpoints = {
      s3 = "https://nbg1.your-objectstorage.com"
    }

    region = "nbg1"   # must be set but is not validated by Hetzner

    # Hetzner Object Storage does not use AWS-style path/checksum features
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# SSH Key
resource "hcloud_ssh_key" "default" {
  name       = "${var.server_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# Firewall
resource "hcloud_firewall" "default" {
  name = "${var.server_name}-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "46.34.224.0/19",
      "37.139.8.159/32"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "51820"
    source_ips = [
      "0.0.0.0/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# # Private Network
# resource "hcloud_network" "default" {
#   name     = "${var.server_name}-network"
#   ip_range = "10.0.0.0/16"
# }

# resource "hcloud_network_subnet" "default" {
#   network_id   = hcloud_network.default.id
#   type         = "cloud"
#   network_zone = var.network_zone
#   ip_range     = "10.0.1.0/24"
# }

# Virtual Server
resource "hcloud_server" "default" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.default.id]

  firewall_ids = [hcloud_firewall.default.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

#   network {
#     network_id = hcloud_network.default.id
#     ip         = "10.0.1.10"
#   }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y
    echo "Server setup complete" > /tmp/setup.log
  EOF

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

#   depends_on = [hcloud_network_subnet.default]
}

# Optional: Floating IP
resource "hcloud_floating_ip" "default" {
  count     = var.enable_floating_ip ? 1 : 0
  type      = "ipv4"
  server_id = hcloud_server.default.id
  name      = "${var.server_name}-floating-ip"
}

resource "hcloud_floating_ip_assignment" "default" {
  count          = var.enable_floating_ip ? 1 : 0
  floating_ip_id = hcloud_floating_ip.default[0].id
  server_id      = hcloud_server.default.id
}

# Optional: Volume
resource "hcloud_volume" "default" {
  count     = var.enable_volume ? 1 : 0
  name      = "${var.server_name}-volume"
  size      = var.volume_size
  server_id = hcloud_server.default.id
  automount = true
  format    = "ext4"
}

# #Write IPv4 into file - for ansible as host to use later
# resource "local_file" "ip_file" {
#   content  = "wg_server_host: ${hcloud_server.default.ipv4_address}"
#   filename = "${path.module}/wg_hostname.yml"
# }
