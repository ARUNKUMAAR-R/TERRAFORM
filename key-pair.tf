resource "aws_key_pair" "southeast-key" {
  key_name = "SG"
  public_key = file("SG.pub")
}

resource "aws_security_group" "SG-httpd" {
  name = "HTTPD-sg"
  description = "ALLOW TRAFFIC FROM 80 AND 22"
  vpc_id = "vpc-0c63f36e182098dab"
  
  ingress {
    description = "allow port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow port 80"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "httpd-SG"
  }
}

