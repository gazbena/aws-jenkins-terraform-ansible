#!/bin/sh

set -eux

ansible-galaxy install -r ansible-requirements.yaml

echo "Generating SSH keypair using Ansible (ansible/gen_ssh_key.yaml)"
ansible-playbook ansible/gen_ssh_key.yaml

echo "Initializing Terraform..."
terraform init

echo "Applying Terraform resources (terraform apply)..."
terraform apply --auto-approve

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yaml ansible/install_jenkins.yaml

terraform output