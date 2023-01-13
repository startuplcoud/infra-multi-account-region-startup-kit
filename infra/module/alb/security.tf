module "load_balancer_security" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "4.17.1"
  name            = "${var.service_name}-load-balancer-group"
  description     = "${var.service_name} load balancer security group"
  vpc_id          = var.vpc_id
  use_name_prefix = false
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
}