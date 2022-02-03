# v6.2.0

* Block public access to bucket
* Upgraded KMS component version

# v6.1.1

* Simplified consumer policies output

# v6.1.0

* Support to add dynamic consumer policy creation to support for multiple consumer policies
* Support to bring your own KMS if needed in restricted scenarios
* Upgraded to Terraform 1.0.0

# v6.0.0

* S3 Object Lock to support write-once-read-many (WORM) model
* Support to add more bucket policy statement or override statements with the same sid from the latest policy
* Upgraded to Terraform 0.14
* Variable tags renamed

# v5.2.0

* S3 buckets should require requests to use Secure Socket Layer.

# v5.1.0

* Version bump of kms key component to v4.1.0 for fine-graining KMS key policies

## v5.0.0

* Bug Fix: Add KMS key for the S3 folder

## v4.3.1

* Bug Fix: Add KMS key for the S3 folder

## v4.3.0

* Feature: Add support for custom_tags

## v4.2.0

* Feature flagged versioning, standard lifecycle and expiration support

## v4.1.0

* Fix kms config
* "Adding "bucket-owner-full-control" to allowed ACL type in the bucket policy. Lots of AWS service use this canned ACL while writing to the bucket e.g. Kinesis Firehose

## v4.0.0

* Add ability to generate multiple consumer bucket access policies
* Restrict bucket policy access to certain principals only
* Enforce server-side encryption

## v3.1.0

* Support for folder structure

## v3.0.0

* Upgrade to Terraform 0.12

## v2.0.1

* Enabled cross account access by providing account numbers

## v2.0.0

* Large refactor

## v1.0.0

* Initial version
