data "aws_caller_identity" "main" {}

data "aws_region" "active" {}

locals {
  bucket_name    = var.append_random_suffix ? "${var.bucket_name}-${random_string.random_suffix.result}" : var.bucket_name
  length_key_arn = length(keys(var.kms_key_arn))
  kms_key_arn    = local.length_key_arn != 0 ? values(var.kms_key_arn)[0] : module.bucket_kms_key[0].key_arn
  kms_key_id     = local.length_key_arn != 0 ? values(var.kms_key_arn)[0] : module.bucket_kms_key[0].key_id
}
