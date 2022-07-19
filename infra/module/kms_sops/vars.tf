variable "key_alias" {
  type    = string
  default = "terragrunt"
}


variable "role_arn_list" {
  type    = list(string)
  default = []
}

variable "user_arn_list" {
  type    = list(string)
  default = []
}