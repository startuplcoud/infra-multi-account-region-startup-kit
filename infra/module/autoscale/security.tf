module "load_balancer_security" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "4.9.0"
  name            = "${var.name}-load-balancer-group"
  description     = "${var.name} load balancer security group"
  vpc_id          = var.vpc_id
  use_name_prefix = false

  ingress_with_source_security_group_id = [
    {
      from_port                = var.port
      to_port                  = var.port
      protocol                 = "tcp"
      source_security_group_id = var.vpc_security_group_id
    }
  ]
  egress_rules = ["all-all"]
}