
resource "aws_vpc" "tetra_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tetra-vpc"
  }
}

resource "aws_subnet" "tetra_pub_sub" {
  vpc_id            = aws_vpc.tetra_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "tetra-pub-sub"
  }
}

resource "aws_subnet" "tetra_pvt_sub" {
  vpc_id            = aws_vpc.tetra_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "tetra-pvt-sub"
  }
}

resource "aws_internet_gateway" "tetra_igw" {
  vpc_id = aws_vpc.tetra_vpc.id

  tags = {
    Name = "tetra-igw"
  }
}

resource "aws_route_table" "tetra_pub_rt" {
  vpc_id = aws_vpc.tetra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tetra_igw.id
  }

  tags = {
    Name = "tetra-pub-rt"
  }
}

resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.tetra_pub_sub.id
  route_table_id = aws_route_table.tetra_pub_rt.id
}

