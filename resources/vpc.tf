resource "aws_vpc" "t75-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
     Name = "t75-vcp"
  }
}

resource "aws_subnet" "t75-vpc_subnet1" {
  vpc_id     = aws_vpc.t75-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
     Name = "t75-vpc_subnet1",
    "kubernetes.io/cluster/t75-eks-cluster" = "shared",
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "t75-vpc_subnet2" {
  vpc_id     = aws_vpc.t75-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
     Name = "t75-vpc_subnet2",
    "kubernetes.io/cluster/t75-eks-cluster" = "shared",
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_internet_gateway" "t75-igw" {
 vpc_id = aws_vpc.t75-vpc.id
 
 tags = {
   Name = "t75-igw"
 }
}

resource "aws_route_table" "t75-route_table" {
 vpc_id = aws_vpc.t75-vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.t75-igw.id
 }
 
 tags = {
   Name = "t75-route_table"
 }
}

resource "aws_route_table_association" "t75-route_table_association-sn1" {
  subnet_id      = aws_subnet.t75-vpc_subnet1.id
  route_table_id = aws_route_table.t75-route_table.id
}

resource "aws_route_table_association" "t75-route_table_association-sn2" {
  subnet_id      = aws_subnet.t75-vpc_subnet2.id
  route_table_id = aws_route_table.t75-route_table.id
}