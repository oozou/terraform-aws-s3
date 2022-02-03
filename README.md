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

