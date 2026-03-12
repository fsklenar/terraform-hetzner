#!/bin/bash
if [ -f ~/.bash_functions ]; then
  source ~/.bash_functions
fi
source .secret
proxydomain=proxy.linuxadmin.eu

#Terraform
cd $HOME/IaC/terraform/terraform-hetzner/haproxy-vm/
terraform apply -auto-approve
sleep 5
dns_content=$(terraform output "server_ipv4")

# #wait until server start
# sleep 30

#Update DNS record
cd $HOME/IaC/ansible/cloud-vps/haproxy
ssh-keygen -f '$HOME/.ssh/known_hosts' -R '$proxydomain'
ssh-keyscan -H $proxydomain >> ~/.ssh/known_hosts
ansible-playbook haproxy-dns.yaml -e dns_content=$dns_content

#wait for DNS record refresh
echo "Waiting for DNS record refresh..."
sleep 90

# #Prompt to check cloudflare DNS
# echo "Current DNS record => "`host $proxydomain`
# read -e -p "Have you checked DNS record for $proxydomain?(Y/n) " choice
# [[ "$choice" == [Yy]* ]] && echo "Correct, continue with installation" || exit 1


#Ansible basic init
cd $HOME/IaC/ansible/cloud-vps/common
ssh-keygen -f '$HOME/.ssh/known_hosts' -R '$proxydomain'
ssh-keyscan -H $proxydomain >> ~/.ssh/known_hosts
ansible-playbook 01-initial-setup.yaml -u root


#Wireguard installation
cd $HOME/IaC/ansible/wireguard
ansible-playbook -i inventory/hosts.yml wireguard.yml

#Get SSL certificate from k8s cluster for the domain
sslcert=$(kubectl get secret -n kube-system proxy-linuxadmin-eu-tls-secret -o jsonpath='{.data.tls\.crt}')
sslkey=$(kubectl get secret -n kube-system proxy-linuxadmin-eu-tls-secret -o jsonpath='{.data.tls\.key}')

#HAProxy installation
cd $HOME/IaC/ansible/cloud-vps/haproxy
ansible-playbook haproxy.yaml  -e sslcert="$sslcert" -e sslkey="$sslkey"

#HAProxy reboot
cd $HOME/IaC/ansible/cloud-vps/haproxy
ansible-playbook haproxy-reboot.yaml


#K8s master update
cd $HOME/IaC/ansible/salaserver/k8s-vms
ansible-playbook 02-vm-kube-config.yaml -u root
