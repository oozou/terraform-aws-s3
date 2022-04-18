resource "aws_s3_object" "this" {
  bucket                 = aws_s3_bucket.this.bucket
  key                    = "${var.folder_names[count.index]}/.keep"
  kms_key_id             = var.is_use_kms_managed_key ? local.kms_key_id : null
  server_side_encryption = var.is_use_kms_managed_key ? "aws:kms" : "AES256"

  tags = merge({
    Name = "${var.bucket_name}-${var.folder_names[count.index]}"
  }, local.tags)

  count = length(var.folder_names)
}
