## Deploying Jenkins controller and agents nodes in AWS behind an ALB using Terraform and Ansible
This repo is a project to automate the installation of jenkins controller and agents in different VPCs (with VPC peering), behind an Application Load Balancer. It uses Terraform to provision the infrastructure and Ansible to configure the EC2 instances (install jenkins and set up agents).
Ansible dynamic inventory is automatically setup with Terraform Ansible Provider after terraform apply (see `ansible.tf` file to see how it is setup).
The project has been highly inspired by this [lab](https://www.pluralsight.com/cloud-guru/labs/aws/deploying-jenkins-master-and-worker-nodes-in-aws-behind-an-alb-using-terraform-and-ansible), but this one uses Ansible provider for terraform instead of local-exec command.


### Prerequisites
- An AWS account and a user with admin access
- AWS CLI, Terraform, python3 and Ansible installed
- AWS access key and secret access key set up (e.g. `aws configure`)


- If you want to add an s3 backend to store Terraform state file:
  1. Create an s3 bucket:
`aws s3api create-bucket --bucket <bucket-name>`
  2. In `providers.tf` file, uncomment the backend "s3" block and change the bucket name to the one you specified in the first step:
  ```
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "<bucket-name>"
  }
### Usage
- Clone the repo.
- If you want to add multiple agents, change the `worker_count` in `terraform.tfvars` file to the number of agents you want.
- If you want Jenkins controller to be only accessible by your IP, change the `external_ip` variable in `terraform.tfvars` file to your public IP, otherwise, it will be accessible to all internet.
- Make deploy.sh executable: `chmod +x deploy.sh`.
- Execute the deployment script: `./deploy.sh`.
- The script outputs the DNS of the ALB. Copy the address and paste it to your local browser (Jenkins user is 'admin', password is 'password').

### Clean up project
- Run `terraform destroy --auto-approve`

### What does the deployment script do?
1. Installs ansible-galaxy plugin requirements (see `ansible-requirements.yaml`).
2. Generates SSH keypair using an Ansible playbook (see `ansible/gen_ssh_key.yaml`).
3. Provisions the infrastructure using Terraform.
4. Runs the ansible playbook that sets up Jenkins controller and agents.
5. Outputs the DNS for the ALB to access Jenkins.

### Future Improvements
- Set up my own Jenkins preconfigured installation directory (jenkins home) instead of using the [one from the lab](https://github.com/ACloudGuru-Resources/content-terraform-jenkins-updated).
- Change deprecated Jenkins plugins (epecially the cloudbees credentials plugin).
- Organize terraform project using modules.
- Write a script that:
  1. Installs terraform, python3, ansible and awscli for the user
  2. Configures aws access key and secret access key
  3. Creates an s3 bucket for the terraform backend
- Setup agents for different workloads (e.g. one with docker and kubectl installed, one with only Linux etc...).


