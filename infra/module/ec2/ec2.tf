resource "aws_instance" "ec2" {
  instance_type = var.instance_type
  associate_public_ip_address = false
  ami = data.aws_ami.ubuntu.id
  key_name = var.ssh_key

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
}

