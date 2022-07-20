variable "vpc_id" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "security_cidr_blocks" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}
variable "identifier" {
  type = string
}

variable "username" {
  type = string
}

variable "environment" {
  type = string
}
variable "password" {
  type = string
}