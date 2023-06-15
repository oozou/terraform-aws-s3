module "bucket_kms_key" {
  source  = "oozou/kms-key/aws"
  version = "2.0.1"

  count = var.is_use_kms_managed_key && local.length_key_arn == 0 ? 1 : 0

  prefix               = var.prefix
  environment          = var.environment
  name                 = "${var.bucket_name}-s3"
  append_random_suffix = true
  description          = "S3 bucket encryption KMS key"
  key_type             = "service"

  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main.account_id]
    aws_service_names  = ["s3.${data.aws_region.active.name}.amazonaws.com"]
  }

  additional_policies = var.additional_kms_key_policies

  tags = var.tags
}
