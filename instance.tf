## Author : ARUNKUMAAR R
## Description : Creating EC2 Instance in AWS
## Date : 12/02/24
## Language : HCL   

resource "aws_instance" "Amz" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  #vpc_id = "vpc-0c63f36e182098dab"
  availability_zone      = var.ZONE1
  vpc_security_group_ids = [aws_security_group.SG-httpd.id]
  key_name               = "SG"
  tags = {
    Name = "AMAZON LINUX"
  }

  provisioner "file" {
    source      = "httpd.sh"
    destination = "/opt"
  }

  provisioner "remote-exec" {
    inline = [
      " chmod 777 /opt/httpd.sh",
      " /opt/httpd.sh"
    ]
  }
  connection {
    type     = "ssh"
    user     = "var.USER"
    password = file("SG")
    host     = self.public_ip
  }
}
