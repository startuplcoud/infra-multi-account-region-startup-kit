module "postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.7.0"

  engine                = "postgres"
  engine_version        = "14.2"
  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 1000
  instance_class        = var.instance_class

  family                          = "postgres14"
  parameter_group_name            = "default.postgres14"
  create_db_parameter_group       = false
  parameter_group_use_name_prefix = false
  option_group_name               = "default:postgres-14"
  major_engine_version            = "14"

  db_subnet_group_name            = "${var.identifier}-${var.environment}-private-subnets"
  db_subnet_group_description     = "${var.identifier} only access from the subnet"
  create_db_subnet_group          = true
  db_subnet_group_use_name_prefix = false

  db_name    = var.db_name # create database name
  username   = var.username
  identifier = "${var.identifier}-${var.environment}"
  port       = 5432

  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [module.security_group.security_group_id]

  performance_insights_enabled = true
  multi_az                     = false

  maintenance_window      = "Sun:06:00-Sun:07:00"
  backup_window           = "12:00-13:00"
  backup_retention_period = 0

  tags = {
    Environment = var.environment
  }
}