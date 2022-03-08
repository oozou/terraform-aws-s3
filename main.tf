/* -------------------------------------------------------------------------- */
/*                                  S3 Bucket                                 */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  # Optional Object Lock Config
  dynamic "object_lock_configuration" {
    for_each = var.object_lock_rule != null ? [1] : []

    content {
      object_lock_enabled = "Enabled"
    }
  }

  force_destroy = var.force_s3_destroy

  tags = merge({
    Name = local.bucket_name
  }, local.tags)
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
/*                                S3 Bucket ACL                               */
/* -------------------------------------------------------------------------- */
resource "aws_s3_bucket_acl" "this" {
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
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = "Enabled"

      filter {
        prefix = ""
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])
        content {
          days          = lookup(transition.value, "days", null)
          storage_class = lookup(transition.value, "storage_class", null)
        }
      }

      expiration {
        days = rule.value.expiration_days
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
      kms_master_key_id = local.kms_key_arn
      sse_algorithm     = "aws:kms"
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
  number  = true
  special = false
}
