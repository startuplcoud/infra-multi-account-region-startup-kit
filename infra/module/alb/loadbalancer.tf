resource "aws_alb" "load_balancer" {
  name               = replace(var.service_name, "_", "-")
  load_balancer_type = "application"
  internal           = false
  security_groups    = [module.load_balancer_security.security_group_id]
  subnets            = var.load_balancer_subnets
}

resource "aws_alb_target_group" "target_group" {
  name             = replace("${var.service_name}-target", "_", "-")
  port             = var.target_port
  protocol         = "HTTP"
  target_type      = "instance"
  vpc_id           = var.vpc_id
  protocol_version = "HTTP2"
  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

resource "aws_alb_listener" "alb_listener_80" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }
}

resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_alb_target_group.target_group.arn
}

