module "bucket_kms_key" {
  source = "git@github.com:oozou/terraform-aws-kms-key.git?ref=v0.0.2"
  count  = local.length_key_arn == 0 ? 1 : 0

  prefix               = var.prefix
  name                 = "${var.bucket_name}-s3-kms"
  environment          = var.environment
  append_random_suffix = true
  description          = "S3 bucket encryption KMS key"
  key_type             = "service"
  tags                 = var.tags


  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main.account_id]
    aws_service_names  = ["s3.${data.aws_region.active.name}.amazonaws.com"]
  }

  additional_policies = var.kms_key_additional_policies
}
