# Terraform AWS S3 Module Tests

This directory contains comprehensive tests for the Terraform AWS S3 module using the `terraform-test-util` framework.

## Overview

The tests validate the functionality of the AWS s3 module by:

## Test Framework

The tests use the [terraform-test-util](https://github.com/oozou/terraform-test-util) framework which provides:
- Comprehensive test reporting with JSON and HTML outputs
- Beautiful console output with emojis and clear formatting
- Pass rate calculation and test statistics
- GitHub-friendly summary generation

## Prerequisites

- Go 1.21 or later
- Terraform 1.6.0 or later
- AWS credentials configured
- Access to AWS S3, Route53, and IAM services

## Running Tests

### Using Make (Recommended)

```bash
# Run all tests with report generation
make test

# Generate test reports (if tests were already run)
make generate-report

# Clean up test artifacts
make clean

# Run tests in verbose mode
make test-verbose

# Run a specific test
make test-specific TEST=xxx
```

### Using Go Test Directly

```bash
# Run all tests
go test -v -timeout 45m

# Run tests with report generation
go test -v -timeout 45m -args -report=true -report-file=test-report.json -html-file=test-report.html

# Run a specific test
go test -v -timeout 45m -run xxxx
```

## Test Structure

The test suite includes the following test cases:

### 1. TestS3BucketCreated
- **Purpose**: Validates that all S3 buckets are created successfully
- **Validates**: 
  - Bucket existence using AWS HeadBucket API
  - Correct number of buckets (3 total)
  - Proper naming conventions with expected prefixes

### 2. TestS3BucketEncryption
- **Purpose**: Validates server-side encryption configuration
- **Validates**:
  - KMS encryption enabled on static and media buckets
  - Proper KMS key configuration
  - Encryption algorithms (aws:kms vs AES256)

### 3. TestS3BucketVersioning
- **Purpose**: Validates bucket versioning settings
- **Validates**:
  - Versioning enabled on static and media buckets
  - Versioning disabled on server log bucket
  - Proper versioning status configuration

### 4. TestS3BucketPublicAccess
- **Purpose**: Validates public access block settings for security
- **Validates**:
  - All buckets have public access blocked
  - Block public ACLs enabled
  - Block public policy enabled
  - Ignore public ACLs enabled
  - Restrict public buckets enabled

### 5. TestS3BucketPolicies
- **Purpose**: Validates IAM policies creation and configuration
- **Validates**:
  - Consumer readonly policies exist
  - Policy ARN format validation
  - Policy accessibility for static and server log buckets

### 6. TestS3ServerAccessLogging
- **Purpose**: Validates server access logging configuration
- **Validates**:
  - Access logging configuration for source buckets
  - Correct target bucket for logs
  - Proper log prefix configuration

## Test Configuration

The tests use the `examples/terraform-test` configuration which includes:

- **Static Bucket**: Versioned bucket with KMS encryption and hardening policies
- **Media Bucket**: Versioned bucket with KMS encryption, no hardening policies
- **Server Log Bucket**: Non-versioned bucket for storing access logs with AES256 encryption
- **Cross-bucket Dependencies**: Server access logging from static/media to log bucket
- **IAM Policies**: Consumer readonly policies for secure access
- **Security Features**: Public access blocking, object ownership controls

## Test Reports

The framework generates multiple types of reports:

### JSON Report (`test-report.json`)
Contains detailed test results in JSON format for programmatic processing.

### HTML Report (`test-report.html`)
A beautiful, interactive HTML report with:
- Test statistics and pass rates
- Detailed test results with status indicators
- Error details for failed tests
- Progress bars and visual indicators

### Console Output
Formatted console output with:
- Test execution progress
- Detailed statistics
- Pass/fail indicators with emojis
- Summary and recommendations

## CI/CD Integration

The tests are integrated with GitHub Actions workflow that:
- Runs tests automatically on pull requests
- Generates and uploads test reports
- Posts test results as PR comments
- Includes "@claude fix build error:" prefix for failed tests
- Provides direct links to workflow runs and detailed logs

## Environment Variables

The following environment variables can be used to configure the tests:

- `AWS_DEFAULT_REGION` - AWS region for testing (default: ap-southeast-1)
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_SESSION_TOKEN` - AWS session token (if using temporary credentials)

## Troubleshooting

### Common Issues

1. **AWS Permissions**: Ensure your AWS credentials have permissions for S3, Route53, and IAM
2. **Domain Conflicts**: Tests use unique domain names to avoid conflicts
3. **Timeout Issues**: Tests have a 45-minute timeout; adjust if needed
4. **Resource Cleanup**: The `terraform destroy` is called automatically in defer blocks

### Debug Mode

For debugging failed tests:

```bash
# Run with verbose output
go test -v -timeout 45m -run TestSpecificTest

# Check terraform logs
export TF_LOG=DEBUG
go test -v -timeout 45m
```

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Add proper error handling and cleanup
3. Include meaningful assertions and error messages
4. Update this README with new test descriptions
5. Ensure tests are idempotent and don't interfere with each other

## Dependencies

The tests depend on:

- `github.com/gruntwork-io/terratest` - Terraform testing framework
- `github.com/stretchr/testify` - Test assertions and utilities
- `github.com/aws/aws-sdk-go` - AWS SDK for Go
- `github.com/oozou/terraform-test-util` - Test reporting utilities

## License

This test suite is part of the terraform-aws-s3 module and follows the same license terms.
