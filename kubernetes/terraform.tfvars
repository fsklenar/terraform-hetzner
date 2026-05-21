##use -> export TF_VAR_hcloud_token="api_token"
cluster_name              = "hetzner_k8s"
controlplane_name         = "cp01"
workernode01_name         = "worker01"
workernode02_name         = "worker02"
workernode03_name         = "worker03"
workernode_servertype_01  = "ccx23"
controlplane_servertype   = "ccx23"
server_image        = "ubuntu-24.04"
server_location     = "fsn1"
network_zone        = "eu-central"
ssh_public_key_path = "~/.ssh/id_rsa_node.pub"
environment         = "dev"
enable_floating_ip  = false
enable_volume       = false
create_ssh_key      = true

