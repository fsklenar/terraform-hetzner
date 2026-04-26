##use -> export TF_VAR_hcloud_token="api_token"
#hcloud_token        = "your-api-token-here"   # Get from Hetzner Cloud Console
server_name         = "node01-vm"
server_type         = "cx43"                  # 4 vCPU, 16GB RAM
server_image        = "ubuntu-24.04"
server_location     = "nbg1"                  # Nuremberg
network_zone        = "eu-central"
ssh_public_key_path = "~/.ssh/id_rsa_node.pub"
environment         = "dev"
enable_floating_ip  = false
enable_volume       = false
create_ssh_key      = true

