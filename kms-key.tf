module "bucket_kms_key" {
  source = "git::https://github.mdl.cloud/digital-lightning-components/terraform-aws-kms-key?ref=v4.3.1"
  count  = local.length_key_arn == 0 ? 1 : 0

  alias_name           = var.bucket_name
  append_random_suffix = true
  description          = "S3 bucket encryption KMS key"
  key_type             = "service"
  tags                 = var.tags


  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main.account_id]
    aws_service_names  = ["s3.${data.aws_region.active.name}.amazonaws.com"]
  }
}
