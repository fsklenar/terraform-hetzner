#!/bin/bash
if [ -f ~/.bash_functions ]; then
  source ~/.bash_functions
fi
source .secret
vmdomain="worker-node.linuxadmin.eu"
tffolder="worker-node"

#Terraform
cd $HOME/IaC/terraform/terraform-hetzner/${tffolder}/
terraform apply -auto-approve
sleep 5
dns_content=$(terraform output "server_ipv4")

#wait until server start
sleep 30

#Update DNS record
cd $HOME/IaC/ansible/cloud-vps/
ssh-keygen -f '$HOME/.ssh/known_hosts' -R '$vmdomain'
ssh-keyscan -H $vmdomain >> ~/.ssh/known_hosts
cf_api_token=$(kubectl get secret -n cert-manager cloudflare-api-token -o jsonpath='{.data.cloudflare-api-token}')
ansible-playbook common/dns.yaml -e "dns_content=${dns_content} cf_api_token=${cf_api_token} target_hosts=cloud-vps-node01"

#wait for DNS record refresh
echo "Waiting for DNS record refresh..."
sleep 90

#Ansible basic init
cd $HOME/IaC/ansible/cloud-vps/common
echo "VMDOMAIN=${vmdomain}"
ssh-keygen -f '$HOME/.ssh/known_hosts' -R '${vmdomain}'
ssh-keyscan -H $vmdomain >> ~/.ssh/known_hosts
ansible-playbook 01-initial-setup.yaml -u root -e "target_hosts=cloud-vps-node01"

#server reboot
cd $HOME/IaC/ansible/cloud-vps/
ansible-playbook common/reboot.yaml -e "target_hosts=cloud-vps-node01"

#docker install
cd $HOME/IaC/ansible/cloud-vps/common/
ansible-playbook docker-install.yaml -e "target_hosts=cloud-vps-node01"

#TailScale k8s
ansible-playbook tailscale-setup.yaml -e "target_hosts=k8smaster tailscale_client_id=${CLIENT_ID} tailscale_client_secret=${CLIENT_SECRET}"

#TailScale worker-node
ansible-playbook tailscale-setup.yaml -e "target_hosts=cloud-vps-node01 tailscale_client_id=${CLIENT_ID} tailscale_client_secret=${CLIENT_SECRET}"

#install k8s node packages
cd $HOME/IaC/ansible/salaserver/k8s-vms/
ansible-playbook 01-vm-initial-setup.yaml -e "target_hosts=cloud-vps-node01"
ansible-playbook 02-vm-kube-config.yaml -e "target_hosts=cloud-vps-node01"

#complete installation
cd $HOME/IaC/ansible/cloud-vps/vms/worker-node
ansible-playbook worker-node.yaml -e "target_hosts=cloud-vps-node01"
