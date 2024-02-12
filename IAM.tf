## Author : ARUNKUMAAR R
## Description : Creating IAM User and Group
## Date : 12/02/24
## Language : HCL   

resource "aws_iam_user" "user1" {
  name = "user1"
}

###### CREATING USER2 #######
resource "aws_iam_user" "user2" {
  name = "user2"
}

###### CREATING DEV-GRP #######
resource "aws_iam_group" "dev-grp" {
  name = "developers-grp"
}

###### ADDING USER1 AND USER2 IN DEV-GRP #######
resource "aws_iam_group_membership" "dev-grp-member" {
  name  = "developers-grp-members"
  group = aws_iam_group.dev-grp.name
  users = [
    aws_iam_user.user1.name,
    aws_iam_user.user2.name,
  ]
}

###### IAM POLICY S3 BUCKET SPECIFIC ############
resource "aws_iam_group_policy" "dev-policy-s3" {
  name  = "developer-terraform-s3"
  group = aws_iam_group.dev-grp.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListStorageLensConfigurations",
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:PutAccountPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessPoints",
          "s3:PutAccessPointPublicAccessBlock",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:CreateJob"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "arn:aws:s3:::terra-form-files"
      }
    ]
  })
}

##### USER POLICY EC2 AND RDS #######
resource "aws_iam_user_policy" "user2-policy-ec2-rds" {
  name = "user2-policy-ec2-rds"
  user = aws_iam_user.user2.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "rds:*",
          "ec2:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

################# CREATING ACCESS KEY AND SECRET KEY FOR USER1 #######
resource "aws_iam_access_key" "access-key-user1" {
  user = aws_iam_user.user1.name
}

################# CREATING ACCESS KEY AND SECRET KEY FOR USER2 #######
resource "aws_iam_access_key" "access-key-user2" {
  user = aws_iam_user.user2.name
}
output "secret1" {
  value = aws_iam_access_key.access-key-user1.encrypted_secret
}
output "encrypted_secret2" {
  value = aws_iam_access_key.access-key-user2.encrypted_secret
   
}
output "secret2" {
  value = aws_iam_access_key.access-key-user2.secret
  sensitive = true
}


