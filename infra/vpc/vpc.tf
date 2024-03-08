resource "aws_vpc" "puppet_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name    = "puppet-vpc"
    Project = "puppet"
  }
}

resource "aws_internet_gateway" "puppet_ig" {
  vpc_id = aws_vpc.puppet_vpc.id
  tags = {
    Project = "puppet"
  }
}

resource "aws_route_table" "subnet_route" {
  vpc_id = aws_vpc.puppet_vpc.id
  tags = {
    Project = "puppet"
  }
}

resource "aws_route" "ig_route" {
  route_table_id         = aws_route_table.subnet_route.id
  gateway_id             = aws_internet_gateway.puppet_ig.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "route_subnet" {
  route_table_id = aws_route_table.subnet_route.id
  subnet_id      = aws_subnet.puppet_nodes.id
}

resource "aws_subnet" "puppet_nodes" {
  vpc_id     = aws_vpc.puppet_vpc.id
  cidr_block = "10.0.0.0/28"
  tags = {
    Name    = "nodes"
    Project = "puppet"
  }
}
