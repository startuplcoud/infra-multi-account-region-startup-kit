variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "load_balancer_subnets" {
  type = list(string)
}

variable "target_port" {
  type = number
}

variable "autoscaling_group_name" {
  type = string
}