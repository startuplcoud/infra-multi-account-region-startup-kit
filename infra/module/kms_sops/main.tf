resource "aws_kms_key" "key" {
  multi_region             = true
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
}

resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.key_id
  name          = "alias/${var.key_alias}"
}