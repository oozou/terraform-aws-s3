output "bucket_id" {
  description = "S3 Bucket Id"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  description = "S3 Bucket ARN"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = "S3 Bucket Domain Name"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.bucket.bucket
}

output "consumer_policies" {
  description = "S3 Bucket Consumer Policies name and ARN map"
  value = {
    for name, policy in aws_iam_policy.consumers : name => policy.arn
  }
}

output "bucket_kms_key_id" {
  description = "S3 Bucket KMS Key ID"
  value       = local.kms_key_id
}

output "bucket_kms_key_arn" {
  description = "S3 Bucket KMS Key ARN"
  value       = local.kms_key_arn
}
