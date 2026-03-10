#!/bin/bash
proxydomain=proxy.linuxadmin.eu

#Terraform
cd $HOME/IaC/terraform/terraform-hetzner/haproxy-vm/
terraform apply -auto-approve

#wait until server start
sleep 30

#Prompt to check cloudflare DNS
echo "Current DNS record => "`host $proxydomain`
read -e -p "Have you checked DNS record for $proxydomain?(Y/n) " choice
[[ "$choice" == [Yy]* ]] && echo "Correct, continue with installation" || exit 1


#Ansible basic init
ssh-keygen -f '/home/feri/.ssh/known_hosts' -R '$proxydomain'
cd $HOME/IaC/ansible/cloud-vps
ssh-keyscan -H $proxydomain >> ~/.ssh/known_hosts
ansible-playbook 01-initial-setup.yaml -u root
ansible-playbook haproxy.yaml

#Wireguard installation
cd $HOME/IaC/ansible/wireguard
ansible-playbook -i inventory/hosts.yml wireguard.yml

#K8s master update
cd $HOME/IaC/ansible/salaserver/k8s-vms
ansible-playbook 02-vm-kube-config.yaml -u root
