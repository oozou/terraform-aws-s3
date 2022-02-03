resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      id      = lifecycle_rule.value.storage_class
      enabled = true
      transition {
        days          = lifecycle_rule.value.days
        storage_class = lifecycle_rule.value.storage_class
      }
    }
  }

  lifecycle_rule {
    id      = "expiration"
    enabled = var.expiration_days > 0 ? true : false

    expiration {
      days = var.expiration_days
    }
  }

  // Optional Object Lock Config
  dynamic "object_lock_configuration" {
    for_each = var.enable_object_lock ? ["on"] : []
    content {
      object_lock_enabled = "Enabled"

      dynamic "rule" {
        for_each = var.object_lock_rule.mode != "" ? ["on"] : []
        content {
          default_retention {
            mode = var.object_lock_rule.mode
            days = var.object_lock_rule.retention_days
          }
        }
      }
    }
  }

  force_destroy = var.force_s3_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = local.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge({
    Name = var.bucket_name
  }, var.tags)
}

resource "random_string" "random_suffix" {
  length  = 12
  upper   = false
  lower   = true
  number  = true
  special = false
}
