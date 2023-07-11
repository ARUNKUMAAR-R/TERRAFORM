variable "REGION" {
  default = "ap-southeast-1"
}

variable "AMIS" {
  type = map(any)
  default = {
    ap-southeast-1 = "ami-0d4430d42d5b76bcd"
    ap-south-1     = "ami-bajbh032030aas5"
  }
}
variable "USER" {
  default = "ec2-user"
}

variable "ZONE1" {
  default = "ap-southeast-1b"
}
