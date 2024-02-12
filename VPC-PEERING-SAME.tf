## Author : ARUNKUMAAR R
## Description : Creating VPC Peering in AWS
## Date : 12/02/24
## Language : HCL   

############# Creating VPC1 ##########
resource "aws_vpc" "vpc1" {
  cidr_block           = "172.17.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc1"
  }
}

############# Creating VPC2 ##########
resource "aws_vpc" "vpc2" {
  cidr_block           = "172.18.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc2"
  }
}

############# Creating SUBNET IN VPC1 ##########
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "172.17.1.0/24"
  availability_zone       = "us-west-2a" # specify the availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

############# Creating SUBNET IN VPC2 ##########
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "172.18.1.0/24"
  availability_zone       = "us-west-2b" # specify the availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

########### Creating Internet Gateway for VPC1 #########
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw1"
  }
}

########### Creating Internet Gateway for VPC2 #########
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "igw2"
  }
}

############### Creating VPC peering connection from VPC1 to VPC2 #####
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "vpc-peering"
  }
}


################# Creating routes for VPC1 route table ################
resource "aws_route_table" "vpc1-rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block                = aws_vpc.vpc2.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "vpc1-rt"
  }
}

################# Creating routes for VPC2 route table ################
resource "aws_route_table" "vpc2-rt" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block                = aws_vpc.vpc1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw2.id
  }

  tags = {
    Name = "vpc2-rt"
  }
}

########## RT Association for vpc1 ###############
resource "aws_route_table_association" "vpc1-rt-pub" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.vpc1-rt.id
}

########## RT Association for vpc2 ###############
resource "aws_route_table_association" "vpc2-rt-pub" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.vpc2-rt.id
}
