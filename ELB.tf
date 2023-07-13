#####AWS ELB Configuration
resource "aws_elb" "my-elb" {
  name            = "my-elb"
  subnets         = [aws_subnet.tetra_pub_sub.id]
  security_groups = [aws_security_group.elb-sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "my-elb"
  }
}

#Security group for AWS ELB
resource "aws_security_group" "elb-sg" {
  vpc_id      = aws_vpc.tetra_vpc.id
  name        = "elb-sg"
  description = "security group for Elastic Load Balancer"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }
}

#Security group for the Instances
resource "aws_security_group" "instance-sg" {
  vpc_id      = aws_vpc.tetra_vpc.id
  name        = "instance1"
  description = "security group for instances"

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

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
  }

  tags = {
    Name = "instance1"
  }
}

#AutoScaling Launch Configuration
resource "aws_launch_configuration" "launchconfig" {
  name_prefix     = "launchconfig"
  image_id        = var.AMIS[var.REGION]
  instance_type   = "t2.micro"
  key_name        = "SG"
  security_groups = [aws_security_group.instance-sg.id]
  user_data       = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`\necho 'Hello Team\nThis is my IP: '$MYIP > /var/www/html/index.html"

  lifecycle {
    create_before_destroy = true
  }
}

#Generate Key
resource "aws_key_pair" "SG" {
  key_name   = "SG"
  public_key = file("SG.pub")
}

#Autoscaling Group
resource "aws_autoscaling_group" "up-autoscaling" {
  name                      = "up-autoscaling"
  vpc_zone_identifier       = [aws_subnet.tetra_pub_sub.id]
  launch_configuration      = aws_launch_configuration.launchconfig.name
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 200
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.my-elb.name]
  force_delete              = true

}

output "ELB" {
  value = aws_elb.my-elb.dns_name
}
