# Terraform AWS S3

## Usage

```terraform
module "image" {
  source = "git@github.com:oozou/terraform-aws-s3.git?ref=<version>"

  prefix      = "oozou"
  environment = "devops"
  bucket_name = "image"

  versioning_enabled                 = true
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = true
  is_create_consumer_readonly_policy = true

  object_ownership = "BucketOwnerEnforced"

  tags = { "Workspace" = "xxx-yyy-zzz" }
}

data "aws_iam_policy_document" "cloudfront_log" {
  statement {
    sid    = "Allow CloudFront to use the key to deliver logs"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

module "cdn_log" {
  source = "git@github.com:oozou/terraform-aws-s3.git?ref=<version>"

  prefix      = "oozou"
  environment = "devops"
  bucket_name = "cloudfront-log"

  versioning_enabled                 = true
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = false
  is_create_consumer_readonly_policy = false

  consumer_policy_actions     = { ReadWrite = ["s3:*"] }
  additional_kms_key_policies = [data.aws_iam_policy_document.cloudfront_log.json]

  object_ownership = "BucketOwnerEnforced"

  tags = { "Workspace" = "xxx-yyy-zzz" }
}

module "server_log" {
  source = "git@github.com:oozou/terraform-aws-s3.git?ref=<version>"

  prefix      = "book"
  environment = "devops"
  bucket_name = "server-log"

  versioning_enabled                 = false
  force_s3_destroy                   = true
  is_enable_s3_hardening_policy      = false
  is_create_consumer_readonly_policy = true

  object_ownership = "BucketOwnerEnforced"

  bucket_mode            = "log"
  is_use_kms_managed_key = false
  source_s3_server_logs = {
    image_bucket = {
      bucket_name   = module.image.bucket_name
      bucket_prefix = "image-bucket/" # Auto append /
    }
    static_bucket = {
      bucket_name   = module.cdn_log.bucket_name
      bucket_prefix = "cdn-log/" # Optional /
    }
  }

  tags = { "Workspace" = "xxx-yyy-zzz" }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random)          | >= 3.1.0 |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws)          | 4.18.0  |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.1   |

## Modules

| Name                                                                               | Source                                         | Version |
|------------------------------------------------------------------------------------|------------------------------------------------|---------|
| <a name="module_bucket_kms_key"></a> [bucket\_kms\_key](#module\_bucket\_kms\_key) | git@github.com:oozou/terraform-aws-kms-key.git | v1.0.0  |

## Resources

| Name                                                                                                                                                                                  | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_policy.consumers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                    | resource    |
| [aws_iam_policy.consumers_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                           | resource    |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                   | resource    |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration)                                     | resource    |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource    |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging)                                                           | resource    |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration)                       | resource    |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls)                                     | resource    |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                             | resource    |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object)                                                                           | resource    |
| [random_string.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                                  | resource    |
| [aws_caller_identity.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                            | data source |
| [aws_iam_policy_document.combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                         | data source |
| [aws_iam_policy_document.consumers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                               | data source |
| [aws_iam_policy_document.consumers_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                      | data source |
| [aws_iam_policy_document.hardening](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                               | data source |
| [aws_iam_policy_document.target_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                    | data source |
| [aws_region.active](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                            | data source |
| [aws_s3_bucket.source_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket)                                                               | data source |

## Inputs

| Name                                                                                                                                             | Description                                                                                                                                                                                                                                                                | Type                                                                                                                                                                                                                                                      | Default          | Required |
|--------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------|:--------:|
| <a name="input_additional_bucket_polices"></a> [additional\_bucket\_polices](#input\_additional\_bucket\_polices)                                | Additional IAM policies block, input as data source or json. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document. Bucket Policy Statements can be overriden by the statement with the same sid from the latest policy. | `list(string)`                                                                                                                                                                                                                                            | `[]`             |    no    |
| <a name="input_additional_kms_key_policies"></a> [additional\_kms\_key\_policies](#input\_additional\_kms\_key\_policies)                        | Additional IAM policies block, input as data source. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document                                                                                                               | `list(string)`                                                                                                                                                                                                                                            | `[]`             |    no    |
| <a name="input_bucket_mode"></a> [bucket\_mode](#input\_bucket\_mode)                                                                            | Define the bucket mode for s3 valida values are default and log                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                                                  | `"default"`      |    no    |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)                                                                            | The name of the bucket                                                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                                                  | n/a              |   yes    |
| <a name="input_centralize_hub"></a> [centralize\_hub](#input\_centralize\_hub)                                                                   | centralize bucket in hub (will add account id to  bucket name)                                                                                                                                                                                                             | `bool`                                                                                                                                                                                                                                                    | `true`           |    no    |
| <a name="input_consumer_policy_actions"></a> [consumer\_policy\_actions](#input\_consumer\_policy\_actions)                                      | Map of multiple S3 consumer policies to be applied to bucket e.g. {EC2Read = [s3:GetObject, s3:ListBucket], FirehoseWrite =[s3:PutObjectAcl]}                                                                                                                              | `map(list(string))`                                                                                                                                                                                                                                       | `{}`             |    no    |
| <a name="input_cors_rule"></a> [cors\_rule](#input\_cors\_rule)                                                                                  | List of core rules to apply to S3 bucket.                                                                                                                                                                                                                                  | <pre>list(object({<br>    id              = string<br>    allowed_headers = list(string)<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    expose_headers  = list(string)<br>    max_age_seconds = number<br>  }))</pre> | `[]`             |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                              | To manage a resources with tags                                                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                                                  | n/a              |   yes    |
| <a name="input_folder_names"></a> [folder\_names](#input\_folder\_names)                                                                         | List of folder names to be created in the S3 bucket. Will create .keep file in each folder. Sub-folders are also supported, use S3 standard forward slash as folder separator                                                                                              | `list(string)`                                                                                                                                                                                                                                            | `[]`             |    no    |
| <a name="input_force_s3_destroy"></a> [force\_s3\_destroy](#input\_force\_s3\_destroy)                                                           | Force destruction of the S3 bucket when the stack is deleted                                                                                                                                                                                                               | `string`                                                                                                                                                                                                                                                  | `false`          |    no    |
| <a name="input_is_control_object_ownership"></a> [is\_control\_object\_ownership](#input\_is\_control\_object\_ownership)                        | Whether to provides a resource to manage S3 Bucket Ownership Controls.                                                                                                                                                                                                     | `bool`                                                                                                                                                                                                                                                    | `true`           |    no    |
| <a name="input_is_create_consumer_readonly_policy"></a> [is\_create\_consumer\_readonly\_policy](#input\_is\_create\_consumer\_readonly\_policy) | Whether to create consumer readonly policy, policy contents: {Bucket Readonly = [s3:ListBucket,s3:GetObject*]                                                                                                                                                              | `bool`                                                                                                                                                                                                                                                    | `false`          |    no    |
| <a name="input_is_enable_logging"></a> [is\_enable\_logging](#input\_is\_enable\_logging)                                                        | Whether to enable logging for s3 or not                                                                                                                                                                                                                                    | `bool`                                                                                                                                                                                                                                                    | `false`          |    no    |
| <a name="input_is_enable_s3_hardening_policy"></a> [is\_enable\_s3\_hardening\_policy](#input\_is\_enable\_s3\_hardening\_policy)                | Whether to create S3 with hardening policy                                                                                                                                                                                                                                 | `bool`                                                                                                                                                                                                                                                    | `true`           |    no    |
| <a name="input_is_ignore_exist_object"></a> [is\_ignore\_exist\_object](#input\_is\_ignore\_exist\_object)                                       | Whether to provides a resource to manage S3 Bucket Ownership Controls.                                                                                                                                                                                                     | `bool`                                                                                                                                                                                                                                                    | `false`          |    no    |
| <a name="input_is_use_kms_managed_key"></a> [is\_use\_kms\_managed\_key](#input\_is\_use\_kms\_managed\_key)                                     | Whether to use kms managed key for server-side encryption. If false sse-s3 managed key will be used.                                                                                                                                                                       | `bool`                                                                                                                                                                                                                                                    | `true`           |    no    |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn)                                                                          | ARN of the KMS Key to use for object encryption. By default, S3 component will create KMS key and associate it with S3. Use only in restricted cases when custom kms policy is needed and you want to bring your KMS.                                                      | `map(string)`                                                                                                                                                                                                                                             | `{}`             |    no    |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules)                                                                | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage\_class can be STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, or DEEP\_ARCHIVE                                                                                      | <pre>list(object({<br>    id = string<br><br>    transition = list(object({<br>      days          = number<br>      storage_class = string<br>    }))<br><br>    expiration_days = number<br>  }))</pre>                                                 | `[]`             |    no    |
| <a name="input_object_lock_rule"></a> [object\_lock\_rule](#input\_object\_lock\_rule)                                                           | Enable Object Lock rule configuration. Default is disabled. If days is set, please set years to null and if years is set, please set days to null. Valid values for mode are GOVERNANCE and COMPLIANCE.                                                                    | <pre>object({<br>    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.<br>    days  = number # If days is set, please set years to null.<br>    years = number # If years is set, please set days to null.<br>  })</pre>                       | `null`           |    no    |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership)                                                             | Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter.                                                                                                                                                                                 | `string`                                                                                                                                                                                                                                                  | `"ObjectWriter"` |    no    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                                             | The prefix name of customer to be displayed in AWS console and resource                                                                                                                                                                                                    | `string`                                                                                                                                                                                                                                                  | n/a              |   yes    |
| <a name="input_source_s3_server_logs"></a> [source\_s3\_server\_logs](#input\_source\_s3\_server\_logs)                                          | Source log configuration to enable sending log to this bucket                                                                                                                                                                                                              | `map(map(any))`                                                                                                                                                                                                                                           | `{}`             |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                   | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys.                                                                                                                                                              | `map(string)`                                                                                                                                                                                                                                             | `{}`             |    no    |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled)                                                       | Should versioning be enabled? (true/false)                                                                                                                                                                                                                                 | `bool`                                                                                                                                                                                                                                                    | `false`          |    no    |

## Outputs

| Name                                                                                                             | Description                                         |
|------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn)                                             | S3 Bucket ARN                                       |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name)                   | S3 Bucket Domain Name                               |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id)                                                | S3 Bucket Id                                        |
| <a name="output_bucket_kms_key_arn"></a> [bucket\_kms\_key\_arn](#output\_bucket\_kms\_key\_arn)                 | S3 Bucket KMS Key ARN                               |
| <a name="output_bucket_kms_key_id"></a> [bucket\_kms\_key\_id](#output\_bucket\_kms\_key\_id)                    | S3 Bucket KMS Key ID                                |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name)                                          | S3 Bucket Name                                      |
| <a name="output_consumer_policies"></a> [consumer\_policies](#output\_consumer\_policies)                        | S3 Bucket Consumer Policies name and ARN map        |
| <a name="output_consumer_readonly_policy"></a> [consumer\_readonly\_policy](#output\_consumer\_readonly\_policy) | S3 Bucket Consumer Readonly Policy name and ARN map |
<!-- END_TF_DOCS -->
