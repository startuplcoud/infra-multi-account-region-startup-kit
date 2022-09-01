resource "aws_launch_configuration" "configuration" {
  name                        = var.autoscaling_name
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = false
  user_data                   = base64encode(templatefile("${path.module}/config/init.yaml", var.user_data))
  key_name                    = var.ssh_key
  security_groups             = [module.load_balancer_security.security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "autoscaling_group" {
  max_size                  = 4
  min_size                  = 2
  launch_configuration      = aws_launch_configuration.configuration.name
  force_delete              = true
  health_check_grace_period = 60
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = "ELB"
  lifecycle {
    create_before_destroy = true
  }
}


#resource "aws_autoscaling_policy" "scale_up" {
#  autoscaling_group_name = aws_autoscaling_group.auto_group.name
#  name                   = "${var.name}-scale_up"
#  policy_type            = "TargetTrackingScaling"
#  adjustment_type        = "ChangeInCapacity"
#  cooldown               = 100
#  target_tracking_configuration {
#    target_value = 0
#  }
#}
#
#resource "aws_autoscaling_policy" "scale_down" {
#  autoscaling_group_name = aws_autoscaling_group.auto_group.name
#  name                   = "${var.name}-scale_up"
#  policy_type            = ""
#  adjustment_type        = ""
#  cooldown               = 100
#  target_tracking_configuration {
#    target_value = 0
#  }
#
#}