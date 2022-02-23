# AWS S3 Bucket

Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance. This component creates an encrypted S3 bucket that is "closed by default" and has security policies configured.

It creates:

- *S3 bucket*
- *S3 folder structure*: Optional, empty folders to be created in the bucket.
- *Random string resource*: To append to S3 bucket name for making them unique, globally
- *S3 bucket policy*: Allow the following principals full access on the S3 bucket
  - AWS account where the bucket is created
  - Other AWS account ids which are passed as parameters to `cross_account_principals` variable
- *S3 consumer policy*: This policy is created for the consumers of S3 bucket. It can be directly attached to all the consumers which will give them required permissions to access this bucket. Support for multiple policy statement by passing them in allowed_actions map variable. *We do not recommend consumers creating s3 bucket access policy on their own*.
- *KMS key*: Server side encryption using KMS key.
- *Optional Bucket Policy Override*: Support for additional bucket policy statement or override statements with the same sid from the latest policy. This is useful, when S3 bucket policy needs extension to provide access to other AWS services. Component will combine both the policy statements(standard & parameterised) to create final bucket policy.
- *Optional Object Lock*: Object Lock can help prevent all the objects in the bucket from being deleted or overwritten for a fixed amount of time or indefinitely. Used for write-once-read-many (WORM) model
- *Optional KMS key*: Support for bring your KMS key. This is to be used in restricted scenarios when custom KMS policies are needed that are not supported by KMS key component.

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
[{
"storage_class" = "STANDARD_IA"
"days" = 30
}, {
"storage_class" = "INTELLIGENT_TIERING"
"days" = 60
}]
```

2. `enable_object_lock` & `object_lock_rule`. Used in Conjuction
```
"enable_object_lock" = true
"object_lock_rule" = { //optional
    mode           = "GOVERNANCE"
    retention_days = 10
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

  bucket_name          = "bucket_name"
  append_random_suffix = true
  force_s3_destroy     = false

  cross_account_principals = local.all_account_ids

  providers = {
    aws = "aws.logging"
  }
}
```

#### How to unit test this component
Find the test files in the 'tests' subfolder. They are Terratest codes written in  Golang.
1. `cd tests`
1. `go test`

##### Prerequisite: Install Go - `brew install go`


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0, < 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.50.0, < 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket_kms_key"></a> [bucket\_kms\_key](#module\_bucket\_kms\_key) | git@github.com:oozou/terraform-aws-kms-key.git | v0.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.consumers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_object.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [random_string.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.consumers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.active](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_append_random_suffix"></a> [append\_random\_suffix](#input\_append\_random\_suffix) | Append random string as suffix, to create unique S3 bucket name. Default set to true | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket | `string` | n/a | yes |
| <a name="input_bucket_policy_document"></a> [bucket\_policy\_document](#input\_bucket\_policy\_document) | [Optional] Additional Bucket Policy JSON document. Bucket Policy Statements can be overriden by the statement with the same sid from the latest policy. | `string` | `"{}"` | no |
| <a name="input_consumer_policy_actions"></a> [consumer\_policy\_actions](#input\_consumer\_policy\_actions) | [Optional] Map of multiple S3 consumer policies to be applied to bucket e.g. {EC2Read = [s3:GetObject, s3:ListObject], FirehoseWrite =[s3:PutObjectAcl]} | `map(list(string))` | `{}` | no |
| <a name="input_enable_object_lock"></a> [enable\_object\_lock](#input\_enable\_object\_lock) | [Optional] Enable Object Lock configuration. Default is disabled. | `bool` | `false` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | Number of days after which data will be automatically destroyed. Defaults to 0 meaning expiration is disabled | `number` | `0` | no |
| <a name="input_folder_names"></a> [folder\_names](#input\_folder\_names) | List of folder names to be created in the S3 bucket. Will create .keep file in each folder. Sub-folders are also supported, use S3 standard forward slash as folder separator | `list(string)` | `[]` | no |
| <a name="input_force_s3_destroy"></a> [force\_s3\_destroy](#input\_force\_s3\_destroy) | Force destruction of the S3 bucket when the stack is deleted | `string` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | [Optional] ARN of the KMS Key to use for object encryption. By default, S3 component will create KMS key and associate it with S3. Use only in restricted cases when custom kms policy is needed and you want to bring your KMS. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage\_class can be STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, or DEEP\_ARCHIVE | <pre>list(object({<br>    storage_class = string<br>    days          = number<br>  }))</pre> | `[]` | no |
| <a name="input_object_lock_rule"></a> [object\_lock\_rule](#input\_object\_lock\_rule) | [Optional] Enable Object Lock rule configuration. Use in conjuction of variable - enable\_object\_lock. Default is disabled. | <pre>object({<br>    mode           = string #Valid values are GOVERNANCE and COMPLIANCE<br>    retention_days = number<br>  })</pre> | <pre>{<br>  "mode": "",<br>  "retention_days": 0<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Should versioning be enabled? (true/false) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | S3 Bucket ARN |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | S3 Bucket Domain Name |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | S3 Bucket Id |
| <a name="output_bucket_kms_key_arn"></a> [bucket\_kms\_key\_arn](#output\_bucket\_kms\_key\_arn) | S3 Bucket KMS Key ARN |
| <a name="output_bucket_kms_key_id"></a> [bucket\_kms\_key\_id](#output\_bucket\_kms\_key\_id) | S3 Bucket KMS Key ID |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | S3 Bucket Name |
| <a name="output_consumer_policies"></a> [consumer\_policies](#output\_consumer\_policies) | S3 Bucket Consumer Policies name and ARN map |
<!-- END_TF_DOCS -->