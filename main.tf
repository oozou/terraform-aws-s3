/* -------------------------------------------------------------------------- */
/*                                  S3 Bucket                                 */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  force_destroy = var.force_s3_destroy

  tags = merge({ Name = local.bucket_name }, local.tags)
}

/* -------------------------------------------------------------------------- */
/*                           S3 Block Public Access                           */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

/* -------------------------------------------------------------------------- */
/*                            S3 OwnerShip Controll                           */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.is_control_object_ownership ? 1 : 0

  bucket = local.is_create_bucket_policy == 1 ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }

  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}

/* -------------------------------------------------------------------------- */
/*                                S3 Bucket ACL                               */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_acl" "this" {
  count = var.object_ownership == "BucketOwnerEnforced" ? 0 : 1

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

/* -------------------------------------------------------------------------- */
/*                            S3 Bucket Versioning                            */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = local.versioning_enabled
  }
}

/* -------------------------------------------------------------------------- */
/*                      S3 Bucket Lifecycle Configuration                     */
/* -------------------------------------------------------------------------- */
/* ------------------------- Thank for AWS Community ------------------------ */
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this] # Must have bucket versioning enabled first

  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = "Enabled"

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {
          #          prefix = ""
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, filter.value.tag, [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                     S3 Bucket Oject lock Configuration                     */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.object_lock_rule != null ? 1 : 0
  bucket = aws_s3_bucket.this.bucket

  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode  = var.object_lock_rule.mode
      days  = var.object_lock_rule.days
      years = var.object_lock_rule.years
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                         S3 Bucket SSE Configuration                        */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.is_use_kms_managed_key ? local.kms_key_arn : null
      sse_algorithm     = var.is_use_kms_managed_key ? "aws:kms" : "AES256"
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                        S3 Bucket CORS Configuration                        */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rule) != 0 ? 1 : 0
  bucket = aws_s3_bucket.this.bucket

  dynamic "cors_rule" {
    for_each = var.cors_rule
    content {
      id              = lookup(cors_rule.value, "id", null)
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods = lookup(cors_rule.value, "allowed_methods", null)
      allowed_origins = lookup(cors_rule.value, "allowed_origins", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                                   RANDOM                                   */
/* -------------------------------------------------------------------------- */
resource "random_string" "random_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}
