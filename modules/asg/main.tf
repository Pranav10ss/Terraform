resource "aws_launch_template" "lt_name" {
  name = "launch-temp-asg"
  image_id = var.ami
  instance_type = var.cpu
  key_name = var.key_name
  vpc_security_group_ids = [var.client_sg_id]
  user_data = filebase64("../modules/asg/config.sh")

    tags = {
      Name = "${var.tags}-lt"
    } 
}

resource "aws_autoscaling_group" "asg_name" {
    name                    = "asg-terraform"
    max_size                  = var.max_size
    min_size                  = var.min_size
    health_check_grace_period = 300
    health_check_type         = var.asg_health_check_type
    desired_capacity          = var.desired_cap
    vpc_zone_identifier       = [var.pri_sub_3a_id,var.pri_sub_4b_id]
    target_group_arns         = [var.tg_arn]

    enabled_metrics = [  
        "GroupMinSize",
        "GroupMaxSize",
        "GroupDesiredCapacity",
        "GroupInserviceInstaances",
        "GroupTotalInstances"
    ]

    metrics_granularity = "1Minute"

    launch_template {
      id = aws_launch_template.lt_name.id
      version = aws_launch_template.lt_name.latest_version
    }
}

#scale_up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg-scale-up-policy"
  scaling_adjustment     = 1 #increasing instance by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  policy_type = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = asg-scale-up-alarm
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  dimensions = {
    "AutoScalingGroupName"  = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

#scale down policy
# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}