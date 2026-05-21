resource "random_password" "storage_password" {
  length           = 16
  special          = true
  override_special = ".*"
  upper            = true
  lower            = true
  numeric          = true
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 1
}

output "password" {
  value     = random_password.storage_password.result
  sensitive = true
}

output "storagebox_server" {
  value     = hcloud_storage_box.shared.server
}

output "storagebox_username" {
  value     = hcloud_storage_box.shared.username
}


resource "hcloud_storage_box" "shared" {
  name             = "shared_k8s"
  storage_box_type = "bx11"
  location         = var.server_location
  password         = random_password.storage_password.result


  access_settings = {
    reachable_externally = false
    samba_enabled        = false
    ssh_enabled          = true
    webdav_enabled       = false
    zfs_enabled          = false
  }

  snapshot_plan = {
    max_snapshots = 3
    minute        = 00
    hour          = 23
    day_of_week   = 6
  }

#   ssh_keys = [
#     hcloud_ssh_key.my_key.public_key,
#     file("~/.ssh/id_ed25519.pub"),
#   ]

  ssh_keys = [
    chomp(file(var.ssh_storage_public_key_path))
    #var.create_ssh_key ? hcloud_ssh_key.storage_new[0].public_key : data.hcloud_ssh_key.storage_existing[0].public_key
  ]


#   delete_protection = true
#
#   lifecycle {
#     prevent_destroy = true
#   }
}

