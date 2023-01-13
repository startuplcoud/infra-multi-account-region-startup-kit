module "load_balancer_security" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "4.17.1"
  name            = "${var.autoscaling_name}-load-balancer-group"
  description     = "${var.autoscaling_name} load balancer security group"
  vpc_id          = var.vpc_id
  use_name_prefix = false

  ingress_with_source_security_group_id = [
    {
      from_port                = var.instance_port
      to_port                  = var.instance_port
      protocol                 = "tcp"
      source_security_group_id = var.vpc_security_group_id
    }
  ]
  egress_rules = ["all-all"]
}