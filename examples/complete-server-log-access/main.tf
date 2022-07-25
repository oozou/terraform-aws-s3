module "static_bucket" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  bucket_name = format("%s-static", var.name)

  versioning_enabled                 = true
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = true
  is_create_consumer_readonly_policy = true

  object_ownership            = "BucketOwnerEnforced"
  additional_kms_key_policies = []

  tags = var.custom_tags
}

module "media_bucket" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  bucket_name = format("%s-media", var.name)

  versioning_enabled                 = true
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = false
  is_create_consumer_readonly_policy = false

  object_ownership            = "BucketOwnerEnforced"
  additional_kms_key_policies = []

  tags = var.custom_tags
}

module "server_log_bucket" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  bucket_name = var.name

  versioning_enabled                 = false
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = false
  is_create_consumer_readonly_policy = true

  object_ownership = "BucketOwnerEnforced"

  bucket_mode            = "log"
  is_use_kms_managed_key = false
  source_s3_server_logs = {
    image_bucket = {
      bucket_name   = module.static_bucket.bucket_name
      bucket_prefix = "a" # Auto append with /
    }
    static_bucket = {
      bucket_name   = module.media_bucket.bucket_name
      bucket_prefix = "b/"
    }
  }

  tags = var.custom_tags
}
