##use -> export TF_VAR_hcloud_token="api_token"
#hcloud_token        = "your-api-token-here"   # Get from Hetzner Cloud Console
server_name         = "proxy-vm"
server_type         = "cx23"                  # 2 vCPU, 4GB RAM
server_image        = "ubuntu-24.04"
server_location     = "nbg1"                  # Nuremberg
network_zone        = "eu-central"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
environment         = "dev"
enable_floating_ip  = false
enable_volume       = false

