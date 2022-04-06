# AWS S3 Bucket

Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance. This component creates an encrypted S3 bucket that is "closed by default" and has security policies configured.

It creates:

- _S3 bucket_
- _S3 folder structure_: Optional, empty folders to be created in the bucket.
- _Random string resource_: To append to S3 bucket name for making them unique, globally
- _S3 bucket policy_: Allow the following principals full access on the S3 bucket
  - AWS account where the bucket is created
  - Other AWS account ids which are passed as parameters to `cross_account_principals` variable
- _S3 consumer policy_: This policy is created for the consumers of S3 bucket. It can be directly attached to all the consumers which will give them required permissions to access this bucket. Support for multiple policy statement by passing them in allowed*actions map variable. \_We do not recommend consumers creating s3 bucket access policy on their own*.
- _KMS key_: Server side encryption using KMS key.
- _Optional Bucket Policy Override_: Support for additional bucket policy statement or override statements with the same sid from the latest policy. This is useful, when S3 bucket policy needs extension to provide access to other AWS services. Component will combine both the policy statements(standard & parameterised) to create final bucket policy.
- _Optional Object Lock_: Object Lock can help prevent all the objects in the bucket from being deleted or overwritten for a fixed amount of time or indefinitely. Used for write-once-read-many (WORM) model
- _Optional KMS key_: Support for bring your KMS key. This is to be used in restricted scenarios when custom KMS policies are needed that are not supported by KMS key component.

## Architecture

[TODO] Insert Architecture Diagram

## Run-Book

### Pre-requisites

#### IMPORTANT NOTE

1. Required version of Terraform is mentioned in `versions.tf`.
2. Go through `variables.tf` for understanding each terraform variable before running this component.

#### Complex Variables in variables.tf

1. `lifecycle_rules`: Lifecycle rules for the data in S3 bucket. E.g.

```terraform
[
  {
    id              = "expiration"
    transition      = []
    expiration_days = 10
  },
  {
    id = "LogLifecycleManagement"
    transition = [
      {
        days          = 31
        storage_class = "STANDARD_IA"
      },
      {
        days          = 366
        storage_class = "GLACIER"
      }
    ]
    expiration_days = 3660
  }
]
```

2. `enable_object_lock` & `object_lock_rule`. Used in Conjuction

```terraform
enable_object_lock = true
object_lock_rule = {
  days = 10
  mode = "GOVERNANCE"
}
```

#### AWS Accounts

Needs the following accounts:

1. Spoke Account (AWS account where S3 Bucket is to be created)

### Getting Started

#### How to use this component in a blueprint

IMPORTANT: We periodically release versions for the components. Since, master branch may have on-going changes, best practice would be to use a released version in form of a tag (e.g. ?ref=x.y.z)

```terraform
module "config_log_bucket" {
  source = "git::https://<YOUR_VCS_URL>/components/terraform-aws-s3-bucket.git?ref=v6.2.0"

  prefix               = "<customer_name>"
  name                 = "<paas_name>"
  environment          = "devops"

  centralize_hub       = true
  versioning_enabled   = true
  force_s3_destroy     = false

  is_enable_s3_hardening_policy = false
  is_use_kms_managed_key        = true

  consumer_policy_actions            = { "EC2Read" = ["s3:GetObject", "s3:ListBucket"], "FirehoseWrite" = ["s3:PutObjectAcl"] }
  is_create_consumer_readonly_policy = true

  tags = {
  "Workspace" = "000-test"
  }

  additional_bucket_polices = [data.aws_iam_policy_document.cloudfront_oai.json]

  kms_key_additional_policies = [data.aws_iam_policy_document.kms_additional.json]
}
```

#### How to unit test this component

Find the test files in the 'tests' subfolder. They are Terratest codes written in Golang.

1. `cd tests`
1. `go test`

##### Prerequisite: Install Go - `brew install go`

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 3.1.0 |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | 4.4.0   |
| <a name="provider_random"></a> [random](#provider_random) | 3.1.0   |

## Modules

| Name                                                                          | Source                                         | Version |
| ----------------------------------------------------------------------------- | ---------------------------------------------- | ------- |
| <a name="module_bucket_kms_key"></a> [bucket_kms_key](#module_bucket_kms_key) | git@github.com:oozou/terraform-aws-kms-key.git | v0.0.2  |

## Resources

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.consumers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                    | resource    |
| [aws_iam_policy.consumers_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                           | resource    |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                   | resource    |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource    |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration)                       | resource    |
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
| [aws_region.active](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                            | data source |

## Inputs

| Name                                                                                                                                    | Description                                                                                                                                                                                                                                                                | Type                                                                                                                                                                                                                    | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_additional_bucket_polices"></a> [additional_bucket_polices](#input_additional_bucket_polices)                            | Additional IAM policies block, input as data source or json. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document. Bucket Policy Statements can be overriden by the statement with the same sid from the latest policy. | `list(string)`                                                                                                                                                                                                          | `[]`    |    no    |
| <a name="input_additional_kms_key_policies"></a> [additional_kms_key_policies](#input_additional_kms_key_policies)                      | Additional IAM policies block, input as data source. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document                                                                                                               | `list(string)`                                                                                                                                                                                                          | `[]`    |    no    |
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name)                                                                      | The name of the bucket                                                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                | n/a     |   yes    |
| <a name="input_centralize_hub"></a> [centralize_hub](#input_centralize_hub)                                                             | centralize bucket in hub (will add account id to bucket name)                                                                                                                                                                                                              | `bool`                                                                                                                                                                                                                  | `true`  |    no    |
| <a name="input_consumer_policy_actions"></a> [consumer_policy_actions](#input_consumer_policy_actions)                                  | Map of multiple S3 consumer policies to be applied to bucket e.g. {EC2Read = [s3:GetObject, s3:ListBucket], FirehoseWrite =[s3:PutObjectAcl]}                                                                                                                              | `map(list(string))`                                                                                                                                                                                                     | `{}`    |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                                      | To manage a resources with tags                                                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                | n/a     |   yes    |
| <a name="input_folder_names"></a> [folder_names](#input_folder_names)                                                                   | List of folder names to be created in the S3 bucket. Will create .keep file in each folder. Sub-folders are also supported, use S3 standard forward slash as folder separator                                                                                              | `list(string)`                                                                                                                                                                                                          | `[]`    |    no    |
| <a name="input_force_s3_destroy"></a> [force_s3_destroy](#input_force_s3_destroy)                                                       | Force destruction of the S3 bucket when the stack is deleted                                                                                                                                                                                                               | `string`                                                                                                                                                                                                                | `false` |    no    |
| <a name="input_is_create_consumer_readonly_policy"></a> [is_create_consumer_readonly_policy](#input_is_create_consumer_readonly_policy) | Whether to create consumer readonly policy, policy contents: {Bucket Readonly = [s3:ListBucket,s3:GetObject*]                                                                                                                                                              | `bool`                                                                                                                                                                                                                  | `false` |    no    |
| <a name="input_is_enable_s3_hardening_policy"></a> [is_enable_s3_hardening_policy](#input_is_enable_s3_hardening_policy)                | Whether to create S3 with hardening policy                                                                                                                                                                                                                                 | `bool`                                                                                                                                                                                                                  | `true`  |    no    |
| <a name="input_is_use_kms_managed_key"></a> [is_use_kms_managed_key](#input_is_use_kms_managed_key)                                     | Whether to use kms managed key for server-side encryption. If false sse-s3 managed key will be used.                                                                                                                                                                       | `bool`                                                                                                                                                                                                                  | `true`  |    no    |
| <a name="input_kms_key_arn"></a> [kms_key_arn](#input_kms_key_arn)                                                                      | ARN of the KMS Key to use for object encryption. By default, S3 component will create KMS key and associate it with S3. Use only in restricted cases when custom kms policy is needed and you want to bring your KMS.                                                      | `map(string)`                                                                                                                                                                                                           | `{}`    |    no    |
| <a name="input_lifecycle_rules"></a> [lifecycle_rules](#input_lifecycle_rules)                                                          | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage_class can be STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, or DEEP_ARCHIVE                                                                                           | <pre>list(object({<br> id = string<br><br> transition = list(object({<br> days = number<br> storage_class = string<br> }))<br><br> expiration_days = number<br> }))</pre>                                               | `[]`    |    no    |
| <a name="input_object_lock_rule"></a> [object_lock_rule](#input_object_lock_rule)                                                       | Enable Object Lock rule configuration. Default is disabled. If days is set, please set years to null and if years is set, please set days to null. Valid values for mode are GOVERNANCE and COMPLIANCE.                                                                    | <pre>object({<br> mode = string # Valid values are GOVERNANCE and COMPLIANCE.<br> days = number # If days is set, please set years to null.<br> years = number # If years is set, please set days to null.<br> })</pre> | `null`  |    no    |
| <a name="input_prefix"></a> [prefix](#input_prefix)                                                                                     | The prefix name of customer to be displayed in AWS console and resource                                                                                                                                                                                                    | `string`                                                                                                                                                                                                                | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                           | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys.                                                                                                                                                              | `map(string)`                                                                                                                                                                                                           | `{}`    |    no    |
| <a name="input_versioning_enabled"></a> [versioning_enabled](#input_versioning_enabled)                                                 | Should versioning be enabled? (true/false)                                                                                                                                                                                                                                 | `bool`                                                                                                                                                                                                                  | `false` |    no    |

## Outputs

| Name                                                                                                        | Description                                         |
| ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| <a name="output_bucket_arn"></a> [bucket_arn](#output_bucket_arn)                                           | S3 Bucket ARN                                       |
| <a name="output_bucket_domain_name"></a> [bucket_domain_name](#output_bucket_domain_name)                   | S3 Bucket Domain Name                               |
| <a name="output_bucket_id"></a> [bucket_id](#output_bucket_id)                                              | S3 Bucket Id                                        |
| <a name="output_bucket_kms_key_arn"></a> [bucket_kms_key_arn](#output_bucket_kms_key_arn)                   | S3 Bucket KMS Key ARN                               |
| <a name="output_bucket_kms_key_id"></a> [bucket_kms_key_id](#output_bucket_kms_key_id)                      | S3 Bucket KMS Key ID                                |
| <a name="output_bucket_name"></a> [bucket_name](#output_bucket_name)                                        | S3 Bucket Name                                      |
| <a name="output_consumer_policies"></a> [consumer_policies](#output_consumer_policies)                      | S3 Bucket Consumer Policies name and ARN map        |
| <a name="output_consumer_readonly_policy"></a> [consumer_readonly_policy](#output_consumer_readonly_policy) | S3 Bucket Consumer Readonly Policy name and ARN map |

<!-- END_TF_DOCS -->
