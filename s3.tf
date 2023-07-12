resource "aws_s3_bucket" "terraform_files" {
  bucket = "terra-form-files"
  tags = {
    Name = "My TerraForm Bucket"
  }
}

resource "aws_s3_object" "my_objects" {
  bucket = "terra-form-files"
  key    = "VPC.tf"
  source = "/root/Terraform/vpc-1.tf"
}
