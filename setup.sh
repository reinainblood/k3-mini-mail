#!/bin/bash
set -e

echo "Starting mail server deployment..."
# Check python version on server
echo "installing dependencies"
ansible-galaxy collection install kubernetes.core
pip3 install kubernetes

pip3 install jsonpatch openshift pyyaml
# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    python3 -m pip install --user ansible
fi


# Simple check to verify inventory is usable
if ! ansible all --list-hosts -i ansible/inventory/hosts.yml &>/dev/null; then
    echo "Error reading inventory file. Please check ansible/inventory/hosts.yml configuration"
    exit 1
fi

# Check if domain has been configured
if ! grep -q {domain} ansible/group_vars/all.yml; then
    echo "Please configure your domain in ansible/group_vars/all.yml"
    exit 1
fi

# Run ansible playbook
cd ansible
ansible-playbook -i inventory/hosts.yml site.yml

echo "Deployment complete!"
echo "Please configure your DNS records as specified in the README"

