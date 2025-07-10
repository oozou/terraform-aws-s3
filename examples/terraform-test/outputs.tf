# Static Bucket Outputs
output "static_bucket_name" {
  description = "Static S3 bucket name"
  value       = module.static_bucket.bucket_name
}

output "static_bucket_arn" {
  description = "Static S3 bucket ARN"
  value       = module.static_bucket.bucket_arn
}

output "static_bucket_kms_key_arn" {
  description = "Static S3 bucket KMS key ARN"
  value       = module.static_bucket.bucket_kms_key_arn
}

# Media Bucket Outputs
output "media_bucket_name" {
  description = "Media S3 bucket name"
  value       = module.media_bucket.bucket_name
}

output "media_bucket_arn" {
  description = "Media S3 bucket ARN"
  value       = module.media_bucket.bucket_arn
}

# Server Log Bucket Outputs
output "server_log_bucket_name" {
  description = "Server log S3 bucket name"
  value       = module.server_log_bucket.bucket_name
}

output "server_log_bucket_arn" {
  description = "Server log S3 bucket ARN"
  value       = module.server_log_bucket.bucket_arn
}

# Consumer Policy Outputs
output "static_bucket_consumer_readonly_policy" {
  description = "Static bucket consumer readonly policy ARN"
  value       = module.static_bucket.consumer_readonly_policy
}

output "server_log_bucket_consumer_readonly_policy" {
  description = "Server log bucket consumer readonly policy ARN"
  value       = module.server_log_bucket.consumer_readonly_policy
}

# Combined bucket list for testing
output "all_bucket_names" {
  description = "List of all bucket names for testing"
  value = [
    module.static_bucket.bucket_name,
    module.media_bucket.bucket_name,
    module.server_log_bucket.bucket_name
  ]
}