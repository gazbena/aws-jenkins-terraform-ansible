data "aws_ami" "ami_vpc_master" {
  provider    = aws.region_master
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

data "aws_ami" "ami_vpc_worker" {
  provider    = aws.region_worker
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}


# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master_key" {
  provider   = aws.region_master
  key_name   = "jenkins-master"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker_key" {
  provider   = aws.region_worker
  key_name   = "jenkins-worker"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "jenkins_master" {
  provider                    = aws.region_master
  ami                         = data.aws_ami.ami_vpc_master.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.master_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  tags = {
    Name = "jenkins_master"
  }

  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]
}

resource "aws_instance" "jenkins_workers" {
  count                       = var.workers_count
  provider                    = aws.region_worker
  ami                         = data.aws_ami.ami_vpc_worker.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.worker_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-oregon.id]
  subnet_id                   = aws_subnet.subnet_1_oregon.id

  tags = {
    Name = join("_", ["jenkins_worker", count.index + 1])
  }

  depends_on = [aws_main_route_table_association.set-worker-default-rt-assoc, aws_instance.jenkins_master]

}