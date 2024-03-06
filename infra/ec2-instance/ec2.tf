data "aws_security_groups" "test" {}

resource "aws_instance" "chef_nodes" {
  count                  = 2
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.chef_nodes.id
  vpc_security_group_ids = [aws_security_group.chef_security_group.id]
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    Name    = count.index == 1 ? "chef-workstation" : "chef-client"
    Project = "chef"
  }
}

data "aws_vpc" "chef_vpc" {
  filter {
    name   = "tag:Name"
    values = ["chef-vpc"]
  }
}

resource "aws_subnet" "chef_nodes" {
  vpc_id     = data.aws_vpc.chef_vpc.id
  cidr_block = "10.0.0.0/28"
  tags = {
    Name    = "nodes"
    Project = "chef"
  }
}

resource "aws_security_group" "chef_security_group" {
  name        = "Chef nodes sg"
  description = "Allow minimum chef communication"
  vpc_id      = data.aws_vpc.chef_vpc.id

  tags = {
    Project = "chef"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.chef_security_group.id
  cidr_ipv4         = data.aws_vpc.chef_vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.chef_security_group.id
  cidr_ipv4         = data.aws_vpc.chef_vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.chef_security_group.id
  cidr_ipv4         = data.aws_vpc.chef_vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_key_pair" "key_pair" {
  key_name   = "chef-key"
  public_key = var.public_key

  tags = {
    Project = "chef"
  }
}