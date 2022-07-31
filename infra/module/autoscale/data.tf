data "aws_availability_zones" "zones" {}

data "aws_ami" "ubuntu" {
  owners      = [var.ami_owner_id]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

