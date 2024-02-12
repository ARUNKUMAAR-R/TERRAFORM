## Author : ARUNKUMAAR R
## Description : Creating VPC in AWS - Part2
## Date : 12/02/24
## Language : HCL   

resource "aws_eip" "my-eip" {
  domain   = "vpc"
}
resource "aws_eip_association" "my-eip-association" {
  instance_id   = aws_instance.Amz-pvt.id
  allocation_id = aws_eip.my-eip.id

}
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.tetra_pub_sub.id
  tags = {
    Name = "MY-nat"
  }
}
resource "aws_route_table" "tetra_pvt_rt" {
  vpc_id = aws_vpc.tetra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat.id
  }

  tags = {
    Name = "tetra-pvt-rt"
  }
}

resource "aws_route_table_association" "pvt" {
  subnet_id      = aws_subnet.tetra_pvt_sub.id
  route_table_id = aws_route_table.tetra_pvt_rt.id
}

resource "aws_security_group" "tetra_pub_sg" {
  name        = "tetra_pub_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tetra_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tetra-pub-sg"
  }
}

resource "aws_security_group" "tetra_pvt_sg" {
  name        = "tetra_pvt_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tetra_vpc.id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.tetra_pub_sg.id]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.tetra_pub_sg.id]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tetra-pvt-sg"
  }
}
resource "aws_instance" "Amz-pub" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  #vpc_id = "vpc-0c63f36e182098dab"
  availability_zone      = var.ZONE2
  subnet_id = aws_subnet.tetra_pub_sub.id
  vpc_security_group_ids = [aws_security_group.tetra_pub_sg.id]
  associate_public_ip_address = true
  key_name               = "SG"
  tags = {
    Name = "PUB AMAZON LINUX"
  }
}
resource "aws_instance" "Amz-pvt" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  #vpc_id = "vpc-0c63f36e182098dab"
  subnet_id = aws_subnet.tetra_pvt_sub.id
  availability_zone      = var.ZONE1
  vpc_security_group_ids = [aws_security_group.tetra_pvt_sg.id]
  key_name               = "SG"
  tags = {
    Name = "PVT AMAZON LINUX"
  }
}
