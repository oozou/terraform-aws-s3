data "aws_caller_identity" "main" {}

data "aws_region" "active" {}

locals {
  prefix         = "${var.prefix}-${var.environment}-${var.bucket_name}"
  bucket_name    = var.centralize_hub ? "${local.prefix}-${data.aws_caller_identity.main.account_id}-${random_string.random_suffix.result}" : "${local.prefix}-${random_string.random_suffix.result}"
  length_key_arn = length(keys(var.kms_key_arn))
  kms_key_arn    = local.length_key_arn != 0 ? values(var.kms_key_arn)[0] : module.bucket_kms_key[0].key_arn
  kms_key_id     = local.length_key_arn != 0 ? values(var.kms_key_arn)[0] : module.bucket_kms_key[0].key_id
  tags = merge({
    "Environment" = var.environment,
    "Terraform"   = "true"
  }, var.tags)
}
