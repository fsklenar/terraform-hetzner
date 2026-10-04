#!/bin/bash
if [ -f ~/.bash_functions ]; then
  source ~/.bash_functions
fi
source .secret
vmdomain="linuxadmin.sk"
tffolder="linuxadmin-vm"
ansfolder="vms/linuxadmin-vm"

#Terraform
cd $HOME/IaC/terraform/terraform-hetzner/${tffolder}/
terraform apply -auto-approve
sleep 5
dns_content=$(terraform output "server_ipv4")

# #wait until server start
sleep 30

#Update DNS record
# cd $HOME/IaC/ansible/cloud-vps/
# ssh-keygen -f '$HOME/.ssh/known_hosts' -R '$vmdomain'
# ssh-keyscan -H $vmdomain >> ~/.ssh/known_hosts
# ansible-playbook common/dns.yaml -e dns_content=$dns_content -e cf_api_token="$cf_api_token" -e "@vms/${tffolder}/vars.yaml"
#
# # Wait for DNS record refresh
# echo "Waiting for DNS record refresh..."
#
# while true; do
#     current_ip="\"$(host "$vmdomain" | awk '/has address/ {print $NF; exit}')\""
#
#     echo "Current DNS: $current_ip | Expected: $dns_content"
#
#     if [[ "$current_ip" == "$dns_content" ]]; then
#         echo "DNS record refreshed successfully."
#         break
#     fi
#
#     sleep 10
# done

#Ansible basic init
cd $HOME/IaC/ansible/cloud-vps/common
ssh-keygen -f '$HOME/.ssh/known_hosts' -R '$vmdomain'
ssh-keyscan -H $vmdomain >> ~/.ssh/known_hosts
ansible-playbook 01-initial-setup.yaml -u root

#use podman
cd $HOME/IaC/ansible/cloud-vps/${ansfolder}
ansible-playbook linuxadmin.yaml


