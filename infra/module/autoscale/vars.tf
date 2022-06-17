variable "vpc_id" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t4g.small"
}
variable "name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "port" {
  type = string
}

variable "vpc_security_group_id" {
  type = string
}