variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "environment" {
  description = "To manage a resources with tags"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "centralize_hub" {
  description = "centralize bucket in hub (will add account id to  bucket name)"
  type        = bool
  default     = true
}

variable "force_s3_destroy" {
  description = "Force destruction of the S3 bucket when the stack is deleted"
  type        = string
  default     = false
}

variable "consumer_policy_actions" {
  description = "[Optional] Map of multiple S3 consumer policies to be applied to bucket e.g. {EC2Read = [s3:GetObject, s3:ListObject], FirehoseWrite =[s3:PutObjectAcl]}"
  type        = map(list(string))
  default     = {}
}

variable "folder_names" {
  description = "List of folder names to be created in the S3 bucket. Will create .keep file in each folder. Sub-folders are also supported, use S3 standard forward slash as folder separator"
  type        = list(string)
  default     = []
}

variable "versioning_enabled" {
  description = "Should versioning be enabled? (true/false)"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to transition the data. Leave empty to disable this feature. storage_class can be STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, or DEEP_ARCHIVE"
  type = list(object({
    id = string

    transition = list(object({
      days          = number
      storage_class = string
    }))

    expiration_days = number
  }))
  default = []
}

variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(string)
  default     = {}
}

variable "additional_bucket_policy" {
  description = "[Optional] Additional IAM policies block, input as data source or json. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document. Bucket Policy Statements can be overriden by the statement with the same sid from the latest policy."
  type        = string
  default     = "{}"
}

variable "enable_object_lock" {
  description = "[Optional] Enable Object Lock configuration. Default is disabled."
  type        = bool
  default     = false
}

variable "object_lock_rule" {
  description = "[Optional] Enable Object Lock rule configuration. Use in conjuction of variable - enable_object_lock. Default is disabled."
  type = object({
    mode = string #Valid values are GOVERNANCE and COMPLIANCE
    days = number
  })

  default = {
    mode = ""
    days = 0
  }

  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE", ""], var.object_lock_rule.mode)
    error_message = "Valid values for object-lock mode are GOVERNANCE and COMPLIANCE."
  }
}

variable "kms_key_arn" {
  description = "[Optional] ARN of the KMS Key to use for object encryption. By default, S3 component will create KMS key and associate it with S3. Use only in restricted cases when custom kms policy is needed and you want to bring your KMS."
  type        = map(string)
  default     = {} // {kmy_arn = <ARN_VALUE>}
}
