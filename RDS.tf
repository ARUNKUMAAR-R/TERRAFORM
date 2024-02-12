## Author : ARUNKUMAAR
## Description : Creating RDS in AWS
## Date : 12/02/24
## Language : HCL   

resource "aws_db_subnet_group" "mine_sbg" {
  name       = "mine-subnet"
  subnet_ids = [
    aws_subnet.tetra_pvt_sub2.id,
    aws_subnet.tetra_pvt_sub1.id
  ]

  tags = {
    Name = "my-subnet-group"
  }
}
resource "aws_key_pair" "southeast-key" {
  key_name = "SG"
  public_key = file("SG.pub")
}
resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  vpc_id      =  aws_vpc.tetra_vpc.id
  description = "allow traffic from 22"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "APP-SG"
  }
}
resource "aws_instance" "app1" {
  subnet_id                   = aws_subnet.tetra_pub_sub.id
  ami                         = var.AMIS[var.REGION]
  key_name                    = "SG"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.app-sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "app in pub"
  }
}
resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  vpc_id      =  aws_vpc.tetra_vpc.id
  description = "allow traffic from 3306"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }
  tags = {
    Name = "DB-SG"
  }
}
resource "aws_db_instance" "db1" {
  db_name                = "accounts"
  db_subnet_group_name   = aws_db_subnet_group.mine_sbg.name
  engine                 = "mariadb"
  engine_version         = "10.6.10"
  identifier             = "db1"
  instance_class         = "db.t2.small"
  username               = "admin"
  password               = "admin123"
  allocated_storage      = 10
  skip_final_snapshot    = true
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  tags = {
    Name = "DB1"
  }
}
output "rds" {
  value = aws_db_instance.db1.endpoint
}
output "app_ip" {
  value = aws_instance.app1.public_ip
}

