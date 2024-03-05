data "aws_security_groups" "test" {}

resource "aws_instance" "chef_nodes" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
}

