data "template_file" "user_data" {
  template = file("${path.module}/config/init-config.yaml")
}

data "template_cloudinit_config" "init_config" {
  part {
    filename     = "cloud-init.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}
