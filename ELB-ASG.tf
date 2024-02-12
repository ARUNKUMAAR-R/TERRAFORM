## Author : ARUNKUMAAR R
## Description : Creating ELB along with ASB in AWS
## Date : 12/02/24
## Language : HCL   

resource "aws_key_pair" "SG-key" {
  key_name   = "SG"
  public_key = file("SG.pub")
}

resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.tetra_vpc.id
  description = "allow traffic from anywhere to alb"
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
}
resource "aws_elb" "tetra_alb" {
  name = "tetra-alb"
  #load_balancer_type = "application"
  internal = false
  subnets = [
    aws_subnet.tetra_pub_sub1.id,
    aws_subnet.tetra_pub_sub2.id,
  ]
  security_groups             = [aws_security_group.alb-sg.id]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300

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
}


resource "aws_security_group" "tetra-lc-sg" {
  name        = "tetra-lc-sg"
  vpc_id      = aws_vpc.tetra_vpc.id
  description = "allow traffic from anywhere to lc"
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
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_launch_configuration" "tetra-lc" {
  name_prefix                 = "tetra-launch-config"
  image_id                    = var.AMIS[var.REGION]
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.tetra-lc-sg.id]
  key_name                    = "SG"
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<-EOT
    #!/bin/bash
    yum update
    yum install httpd -y
    systemctl enable httpd
    systemctl start httpd
    echo "instance $(curl http://169.254.169.254/latest/meta-data/local-ipv4)" > /var/www/html/index.html
    systemctl restart httpd
  EOT
}

resource "aws_autoscaling_group" "tetra_ASG" {
  name                      = "tetra-asg"
  launch_configuration      = aws_launch_configuration.tetra-lc.name
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 3
  vpc_zone_identifier       = [aws_subnet.tetra_pub_sub1.id, aws_subnet.tetra_pub_sub2.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  load_balancers            = [aws_elb.tetra_alb.name]
  force_delete              = true
}





