module "s3_bucket" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  bucket_name = var.name

  versioning_enabled                 = true
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = true
  is_create_consumer_readonly_policy = true

  folder_names = ["static", "image"]

  object_ownership = "BucketOwnerEnforced"

  tags = var.custom_tags
}
