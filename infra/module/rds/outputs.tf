output "db_password" {
  value     = module.postgres.db_instance_password
  sensitive = true
}

output "db_uri" {
  value = module.postgres.db_instance_address
}

output "db_username" {
  value     = module.postgres.db_instance_username
  sensitive = true
}

output "db_database_name" {
  value = module.postgres.db_instance_name
}

output "db_port" {
  value = module.postgres.db_instance_port
}
