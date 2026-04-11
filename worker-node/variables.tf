variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the server"
  type        = string
}

variable "server_type" {
  description = "Server type (e.g., cx22, cx32, cx42, cpx11)"
  type        = string
  default     = "cx22"
}

variable "server_image" {
  description = "OS image for the server"
  type        = string
  default     = "ubuntu-24.04"
}

variable "server_location" {
  description = "Server location (nbg1, fsn1, hel1, ash, hil, sin)"
  type        = string
  default     = "nbg1"
}

variable "network_zone" {
  description = "Network zone matching the server location"
  type        = string
  default     = "eu-central"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "environment" {
  description = "Environment label (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_floating_ip" {
  description = "Whether to create and assign a floating IP"
  type        = bool
  default     = false
}

variable "enable_volume" {
  description = "Whether to create and attach an additional volume"
  type        = bool
  default     = false
}

variable "volume_size" {
  description = "Size of the additional volume in GB"
  type        = number
  default     = 50
}

variable "create_ssh_key" {
  type    = bool
  default = true # Set to true if you want to create a new one
}
