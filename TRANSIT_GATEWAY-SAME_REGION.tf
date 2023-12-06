
# Create VPC1
resource "aws_vpc" "vpc1" {
  cidr_block           = "172.17.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc1"
  }
}

# Create VPC2
resource "aws_vpc" "vpc2" {
  cidr_block           = "172.18.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc2"
  }
}

# Create a subnet in VPC1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "172.17.1.0/24"
  availability_zone       = "us-west-2b" # specify the availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

# Create a subnet in VPC2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "172.18.1.0/24"
  availability_zone       = "us-west-2c" # specify the availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

# Create an Internet Gateway for VPC1
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw1"
  }
}

# Create an Internet Gateway for VPC2
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "igw2"
  }
}

# Create a Transit Gateway
resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "Transit Gateway for VPC peering"
}

# Attach VPC1 to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment_vpc1" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = aws_vpc.vpc1.id

  subnet_ids = [aws_subnet.subnet1.id]

  tags = {
    Name = "attachment_vpc1"
  }
}

# Attach VPC2 to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment_vpc2" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = aws_vpc.vpc2.id

  subnet_ids = [aws_subnet.subnet2.id]

  tags = {
    Name = "attachment_vpc2"
  }
}

# Create routes for VPC1 route table
resource "aws_route_table" "vpc1-rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block         = aws_vpc.vpc2.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "vpc1-rt"
  }
}

# Create routes for VPC2 route table
resource "aws_route_table" "vpc2-rt" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block         = aws_vpc.vpc1.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
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
