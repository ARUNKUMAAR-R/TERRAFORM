######### KEY PAIR #########
resource "aws_key_pair" "southeast-key" {
  key_name   = "SG"
  public_key = file("SG.pub")
}
############### LAUNCH CONFIGURATION #######
resource "aws_launch_configuration" "my-config" {
  name_prefix   = "terraform-launch-config"
  image_id      = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  key_name      = "SG"
  lifecycle {
    create_before_destroy = true
  }
}

########### AUTO SCALING GROUP #######
resource "aws_autoscaling_group" "my-grp" {
  name                      = "terraform-auto-grp"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  launch_configuration      = aws_launch_configuration.my-config.name
  vpc_zone_identifier       = [aws_subnet.tetra_pub_sub.id]
}

########## AUTOSCALING POLICY FOR UPSCALING ######
resource "aws_autoscaling_policy" "my-upscale-policy" {
  name                   = "upscale-policy"
  scaling_adjustment     = 1
  autoscaling_group_name = aws_autoscaling_group.my-grp.name
  cooldown               = "200"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
}

################### CLOUDWATCH ALARM FOR UPSCALING ########
resource "aws_cloudwatch_metric_alarm" "upscale-alarm" {
  alarm_name          = "upscale-alarm"
  alarm_description   = "Alarm Once when CPU utilization exceeds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.my-grp.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.my-upscale-policy.arn]
}

################ AUTOACALING POLICY FOR DOWNSCALING ########
resource "aws_autoscaling_policy" "my-downscale-policy" {
  name                   = "downscale-policy"
  scaling_adjustment     = "-1"
  autoscaling_group_name = aws_autoscaling_group.my-grp.name
  cooldown               = "200"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
}

################### CLOUDWATCH ALARM FOR DOWNSCALING########
resource "aws_cloudwatch_metric_alarm" "downscale-alarm" {
  alarm_name          = "downscale-alarm"
  alarm_description   = "Alarm Once when CPU utilization decreases"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.my-grp.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.my-downscale-policy.arn]
}


