resource "ansible_host" "workers_host" {
  count  = var.workers_count
  name   = aws_instance.jenkins_workers[count.index].public_dns
  groups = ["jenkins_agents"]
  variables = {
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
    instance_private_ip = aws_instance.jenkins_workers[count.index].private_ip
  }
}

resource "ansible_host" "master_host" {
  name   = aws_instance.jenkins_master.public_dns
  groups = ["jenkins_controller"]
  variables = {
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
    instance_private_ip = aws_instance.jenkins_master.private_ip
  }
}