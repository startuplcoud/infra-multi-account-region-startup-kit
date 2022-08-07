variable "key_alias" {
  type    = string
  default = "terragrunt"
}

variable "multi_region" {
  type    = bool
  default = true
}

variable "role_arn_list" {
  type    = list(string)
  default = []
}

variable "user_arn_list" {
  type    = list(string)
  default = []
}