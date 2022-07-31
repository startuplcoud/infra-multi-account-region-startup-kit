module "security_group" {
  source          = "terraform-aws-modules/security-group/aws"
  name            = "${var.identifier}-rds-security-group"
  description     = "PostgreSQL security group"
  vpc_id          = var.vpc_id
  use_name_prefix = false

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.security_cidr_blocks
    },
  ]
  egress_rules = ["all-all"]
}