data "aws_vpc" "puppet_vpc" {
  filter {
    name   = "tag:Name"
    values = ["puppet-vpc"]
  }
}

data "aws_subnet" "puppet_nodes" {
  filter {
    name   = "tag:Name"
    values = ["nodes"]
  }
}

resource "aws_instance" "puppet_master" {
  ami                         = "ami-07d9b9ddc6cd8dd30"
  instance_type               = "t2.medium"
  subnet_id                   = data.aws_subnet.puppet_nodes.id
  vpc_security_group_ids      = [aws_security_group.puppet_security_group.id]
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "puppet-master"
    Project = "puppet"
  }
}

resource "aws_instance" "puppet_agents" {
  count                       = 2
  ami                         = "ami-07d9b9ddc6cd8dd30"
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.puppet_nodes.id
  vpc_security_group_ids      = [aws_security_group.puppet_security_group.id]
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "puppet-agents"
    Project = "puppet"
  }
}

resource "aws_security_group" "puppet_security_group" {
  name        = "puppet nodes sg"
  description = "Allow minimum puppet communication"
  vpc_id      = data.aws_vpc.puppet_vpc.id

  tags = {
    Project = "puppet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.puppet_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_puppet_port" {
  security_group_id = aws_security_group.puppet_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8140
  ip_protocol       = "tcp"
  to_port           = 8140
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.puppet_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  security_group_id = aws_security_group.puppet_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_response" {
  security_group_id = aws_security_group.puppet_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "puppet-key"
  public_key = tls_private_key.puppet_key.public_key_openssh

  tags = {
    Project = "puppet"
  }
}

resource "tls_private_key" "puppet_key" {
  algorithm = "ED25519"
}

resource "local_file" "puppet_key_file" {
  content         = tls_private_key.puppet_key.private_key_openssh
  file_permission = "0600"
  filename        = var.private_key_path
}