variable "ami_owner_id" {
  type    = string
  default = "099720109477"
}

variable "instance_type" {
  type    = string
  default = "t4g.small"
}

variable "user_data" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "autoscaling_name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_port" {
  type = string
}

variable "vpc_security_group_id" {
  type = string
}

