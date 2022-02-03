resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.bucket.id

  policy = data.aws_iam_policy_document.combined_policy.json
}

data "aws_iam_policy_document" "combined_policy" {
  override_policy_documents = [
    data.aws_iam_policy_document.this.json,
    var.bucket_policy_document
  ]
}

/*
  The S3 bucket policy goals are as follows:

    * Require that all content uploaded uses the 'private' ACL
    * Require that all content uploaded uses AWS KMS encryption

  The ability to use the bucket is controlled by `deny` statements:

    1. Deny when KMS key ID is not provided (`PutObject`)
    2. Deny when KMS key ID is not as expected (`PutObject`)
    3. Deny when SSE is not specified (`PutObject`)
    4. Deny when SSE mode is not KMS (`PutObject`)
    5. Deny when ACL is non-null and not 'private' (default = private) (`PutObject`, `PutObjectAcl`, `PutObjectVersionAcl`)
    6. Deny when any of the 5 explicit grants are non-null: read (`PutObject`, `PutObjectAcl`, `PutObjectVersionAcl`)
    7. Deny when any of the 5 explicit grants are non-null: write (`PutObject`, `PutObjectAcl`, `PutObjectVersionAcl`)
    8. Deny when any of the 5 explicit grants are non-null: read-acp (`PutObject`, `PutObjectAcl`, `PutObjectVersionAcl`)
    9. Deny when any of the 5 explicit grants are non-null: write-acp (`PutObject`, `PutObjectAcl`, `PutObjectVersionAcl`)
    10. Deny when any of the 5 explicit grants are non-null: full-control (`PutObject`, `PutObjectAcl`, `PutObjectVersionAcl`)
    11. Deny S3 buckets access for non Secure Socket Layer requests.

*/
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "DenyInsecureUploadsNullEncryption"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DenyInsecureUploadsWithoutKMS"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid       = "DenyUnspecifiedSSEKey"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DenyIncorrectSSEKey"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [local.kms_key_arn]
    }
  }

  statement {
    sid       = "DenyInsecureAcl"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-acl"
      values   = ["private", "bucket-owner-full-control"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-acl"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyGrantRead"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-grant-read"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyGrantWrite"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-grant-write"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyGrantReadAcp"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-grant-read-acp"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyGrantWriteAcp"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-grant-write-acp"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyGrantFullControl"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-grant-full-control"
      values   = ["false"]
    }
  }

  // S3 buckets should require requests to use Secure Socket Layer
  statement {
    sid = "DenyNonSSLRequests"
    actions = [
      "s3:*",
    ]
    effect    = "Deny"
    resources = [aws_s3_bucket.bucket.arn]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
