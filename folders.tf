resource "aws_s3_object" "this" {
  bucket                 = aws_s3_bucket.this.bucket
  key                    = "${var.folder_names[count.index]}/.keep"
  kms_key_id             = local.kms_key_arn
  server_side_encryption = "aws:kms"

  tags = merge({
    Name = "${var.bucket_name}-${var.folder_names[count.index]}"
  }, local.tags)

  count = length(var.folder_names)
}
