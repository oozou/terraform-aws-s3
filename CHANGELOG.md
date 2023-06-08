# Change Log

All notable changes to this module will be documented in this file.

## [v2.0.0] - 2023-06-08

### BREAKING CHANGES

- Upgrade the AWS provider to version 5 with the constraint of `>= 5.0.0, < 6.0.0`.

## [v1.1.4] - 2022-12-13

### Changed

- Update module `bucket_kms_key`'s argument name from `"${var.bucket_name}-s3-kms"` to `"${var.bucket_name}-s3"`; remove `kms` string duplication

## [v1.1.3] - 2022-09-19

### Changed

- In KMS, Change to use Oozou KMS Terraform public registry.

## [v1.1.2] - 2022-07-27

### Changed

- In DenyNonSSLRequests, we update to `<s3_arn>` and `<s3_arn>/*` for best practice when hardening policies enable.

## [v1.1.1] - 2022-07-25

### Changed

- Update tagging format
- Variable `var.object_ownership` from `ObjectWriter` to `BucketOwnerEnforced`; AWS recommendation
    - Fix error_message for validation

## [v1.1.0] - 2022-07-20

### Changed

- Remove the previous CHANGELOG.md
- Update README.md to cover the majority of cases

### Added

- Add variable `bucket_mode` to set the bucket_mode to log (relate with raise condition)
- Add condition for log bucket mode to raise (prevent user from mis config)
- Add the `var.object_ownership` variable to regulate the bucket ownership type.
- Add the variable `var.is_ignore_exist_object` to ignore the warning displayed by the type `var.object_ownership`
- Add condition to remove `aws_s3_bucket_acl` resource when `var.object_ownership` is "BucketOwnerEnforced"
- Add variable `var.is_control_object_ownership` for managing bucket ownership controls provides a resource.
- Add the resource `aws_s3_bucket_ownership_controls`
- Add resource variable `var.source_s3_server_logs` to enable logging and its settings.
- Add data blog `aws_s3_bucket.source_bucket` to query the source bucket
- Add the `aws_s3_bucket_logging` resource to enable logging from the specified source buckets.
- Add data blog `aws_iam_policy_document.target_bucket_policy` in order to construct a policy that authorizes an AWS service to operate on a log bucket.

## [v1.0.4] - 2022-06-15

### Changed

- Enhancement deprecated-variable-number-in-s3 by @xshot9011 in #18
- Nothing change from v1.0.3, only remove deprecated value

## [v1.0.3] - 2022-06-02

### Changed

- DTPK-122: fix kms_key_id for s3 object by

## [v1.0.2] - 2022-08-04

### Changed

- (remove): deprecated env
- Add SSE-S3 feature and CORS configuration
- fix: cors count

## [v1.0.1] - 2022-03-09

### Changed
- Fix bug/object lock

## [v1.0.0] - 2022-03-08

### Changed

- (naming) naming resource for devops standards
- Feature/newest providers
- Feature/consumer policies
- Merge from develop
