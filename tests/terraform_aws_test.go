package test

import (
	"flag"
	"fmt"
	"os"
	//"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/oozou/terraform-test-util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Global variables for test reporting
var (
	generateReport bool
	reportFile     string
	htmlFile       string
)

// TestMain enables custom test runner with reporting
func TestMain(m *testing.M) {
	flag.BoolVar(&generateReport, "report", false, "Generate test report")
	flag.StringVar(&reportFile, "report-file", "test-report.json", "Test report JSON file")
	flag.StringVar(&htmlFile, "html-file", "test-report.html", "Test report HTML file")
	flag.Parse()

	exitCode := m.Run()
	os.Exit(exitCode)
}

func TestTerraformAWSS3Module(t *testing.T) {
	t.Parallel()

	// Record test start time
	startTime := time.Now()
	var testResults []testutil.TestResult

	// Pick a random AWS region to test in
	awsRegion := "ap-southeast-1"

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/terraform-test",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"prefix":      "terratest",
			"environment": "test",
			"name":        "cms",
			"custom_tags":        map[string]string{"test": "true"},
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		terraform.Destroy(t, terraformOptions)

		// Generate and display test report
		endTime := time.Now()
		report := testutil.GenerateTestReport(testResults, startTime, endTime)
		report.TestSuite = "Terraform AWS S3 Tests"
		report.PrintReport()

		// Save reports to files
		if err := report.SaveReportToFile("test-report.json"); err != nil {
			t.Errorf("failed to save report to file: %v", err)
		}

		if err := report.SaveReportToHTML("test-report.html"); err != nil {
			t.Errorf("failed to save report to HTML: %v", err)
		}
	}()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Define test cases with their functions
	testCases := []struct {
		name string
		fn   func(*testing.T, *terraform.Options, string)
	}{
		{"TestS3BucketCreated", testS3BucketCreated},
		{"TestS3BucketEncryption", testS3BucketEncryption},
		{"TestS3BucketVersioning", testS3BucketVersioning},
		{"TestS3BucketPublicAccess", testS3BucketPublicAccess},
		{"TestS3BucketPolicies", testS3BucketPolicies},
		{"TestS3ServerAccessLogging", testS3ServerAccessLogging},
	}

	// Run all test cases and collect results
	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			testStart := time.Now()

			// Capture test result
			defer func() {
				testEnd := time.Now()
				duration := testEnd.Sub(testStart)

				result := testutil.TestResult{
					Name:     tc.name,
					Duration: duration.String(),
				}

				if r := recover(); r != nil {
					result.Status = "FAIL"
					result.Error = fmt.Sprintf("Panic: %v", r)
				} else if t.Failed() {
					result.Status = "FAIL"
					result.Error = "Test assertions failed"
				} else if t.Skipped() {
					result.Status = "SKIP"
				} else {
					result.Status = "PASS"
				}

				testResults = append(testResults, result)
			}()

			// Run the actual test
			tc.fn(t, terraformOptions, awsRegion)
		})
	}
}

// Test if S3 buckets are created
func testS3BucketCreated(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get all bucket names from terraform output
	allBucketNames := terraform.OutputList(t, terraformOptions, "all_bucket_names")
	require.NotEmpty(t, allBucketNames, "Should have bucket names")
	require.Len(t, allBucketNames, 3, "Should have exactly 3 buckets")

	// Verify all buckets exist
	sess := createAWSSession(t, awsRegion)
	s3Client := s3.New(sess)

	for _, bucketName := range allBucketNames {
		_, err := s3Client.HeadBucket(&s3.HeadBucketInput{
			Bucket: aws.String(bucketName),
		})
		require.NoError(t, err, fmt.Sprintf("S3 bucket %s should exist", bucketName))
		
		// Verify bucket name contains expected prefix
		assert.Contains(t, bucketName, "terratest-test", fmt.Sprintf("Bucket %s should contain expected prefix", bucketName))
	}
}

// Test S3 bucket encryption configuration
func testS3BucketEncryption(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get bucket names from terraform output
	staticBucketName := terraform.Output(t, terraformOptions, "static_bucket_name")
	mediaBucketName := terraform.Output(t, terraformOptions, "media_bucket_name")
	
	require.NotEmpty(t, staticBucketName, "Static bucket name should not be empty")
	require.NotEmpty(t, mediaBucketName, "Media bucket name should not be empty")

	// Create AWS session
	sess := createAWSSession(t, awsRegion)
	s3Client := s3.New(sess)

	// Test static bucket encryption (should use KMS)
	staticEncryption, err := s3Client.GetBucketEncryption(&s3.GetBucketEncryptionInput{
		Bucket: aws.String(staticBucketName),
	})
	require.NoError(t, err, "Should be able to get static bucket encryption")
	require.NotEmpty(t, staticEncryption.ServerSideEncryptionConfiguration.Rules, "Static bucket should have encryption rules")
	
	staticRule := staticEncryption.ServerSideEncryptionConfiguration.Rules[0]
	assert.Equal(t, "aws:kms", *staticRule.ApplyServerSideEncryptionByDefault.SSEAlgorithm, "Static bucket should use KMS encryption")
	assert.NotEmpty(t, *staticRule.ApplyServerSideEncryptionByDefault.KMSMasterKeyID, "Static bucket should have KMS key")

	// Test media bucket encryption (should use KMS)
	mediaEncryption, err := s3Client.GetBucketEncryption(&s3.GetBucketEncryptionInput{
		Bucket: aws.String(mediaBucketName),
	})
	require.NoError(t, err, "Should be able to get media bucket encryption")
	require.NotEmpty(t, mediaEncryption.ServerSideEncryptionConfiguration.Rules, "Media bucket should have encryption rules")
}

// Test S3 bucket versioning configuration
func testS3BucketVersioning(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get bucket names from terraform output
	staticBucketName := terraform.Output(t, terraformOptions, "static_bucket_name")
	mediaBucketName := terraform.Output(t, terraformOptions, "media_bucket_name")
	serverLogBucketName := terraform.Output(t, terraformOptions, "server_log_bucket_name")

	// Create AWS session
	sess := createAWSSession(t, awsRegion)
	s3Client := s3.New(sess)

	// Test static bucket versioning (should be enabled)
	staticVersioning, err := s3Client.GetBucketVersioning(&s3.GetBucketVersioningInput{
		Bucket: aws.String(staticBucketName),
	})
	require.NoError(t, err, "Should be able to get static bucket versioning")
	assert.Equal(t, "Enabled", *staticVersioning.Status, "Static bucket versioning should be enabled")

	// Test media bucket versioning (should be enabled)
	mediaVersioning, err := s3Client.GetBucketVersioning(&s3.GetBucketVersioningInput{
		Bucket: aws.String(mediaBucketName),
	})
	require.NoError(t, err, "Should be able to get media bucket versioning")
	assert.Equal(t, "Enabled", *mediaVersioning.Status, "Media bucket versioning should be enabled")

	// Test server log bucket versioning (should be disabled)
	serverLogVersioning, err := s3Client.GetBucketVersioning(&s3.GetBucketVersioningInput{
		Bucket: aws.String(serverLogBucketName),
	})
	require.NoError(t, err, "Should be able to get server log bucket versioning")
	// Server log bucket has versioning disabled, so status might be empty or "Suspended"
	if serverLogVersioning.Status != nil {
		assert.NotEqual(t, "Enabled", *serverLogVersioning.Status, "Server log bucket versioning should not be enabled")
	}
}

// Test S3 bucket public access block configuration
func testS3BucketPublicAccess(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get all bucket names from terraform output
	allBucketNames := terraform.OutputList(t, terraformOptions, "all_bucket_names")
	require.NotEmpty(t, allBucketNames, "Should have bucket names")

	// Create AWS session
	sess := createAWSSession(t, awsRegion)
	s3Client := s3.New(sess)

	// Test all buckets have public access blocked
	for _, bucketName := range allBucketNames {
		publicAccessBlock, err := s3Client.GetPublicAccessBlock(&s3.GetPublicAccessBlockInput{
			Bucket: aws.String(bucketName),
		})
		require.NoError(t, err, fmt.Sprintf("Should be able to get public access block for bucket %s", bucketName))
		
		config := publicAccessBlock.PublicAccessBlockConfiguration
		assert.True(t, *config.BlockPublicAcls, fmt.Sprintf("Bucket %s should block public ACLs", bucketName))
		assert.True(t, *config.BlockPublicPolicy, fmt.Sprintf("Bucket %s should block public policy", bucketName))
		assert.True(t, *config.IgnorePublicAcls, fmt.Sprintf("Bucket %s should ignore public ACLs", bucketName))
		assert.True(t, *config.RestrictPublicBuckets, fmt.Sprintf("Bucket %s should restrict public buckets", bucketName))
	}
}

// Test S3 bucket IAM policies
func testS3BucketPolicies(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get policy ARNs from terraform output
	staticReadonlyPolicy := terraform.Output(t, terraformOptions, "static_bucket_consumer_readonly_policy")
	serverLogReadonlyPolicy := terraform.Output(t, terraformOptions, "server_log_bucket_consumer_readonly_policy")

	// Validate policy ARNs are not empty
	require.NotEmpty(t, staticReadonlyPolicy, "Static bucket readonly policy should exist")
	require.NotEmpty(t, serverLogReadonlyPolicy, "Server log bucket readonly policy should exist")

	// Validate ARN format
	assert.Contains(t, staticReadonlyPolicy, "arn:aws:iam:", "Static policy should be valid IAM policy ARN")
	assert.Contains(t, staticReadonlyPolicy, "policy/", "Static policy should be valid IAM policy ARN")
	
	assert.Contains(t, serverLogReadonlyPolicy, "arn:aws:iam:", "Server log policy should be valid IAM policy ARN")
	assert.Contains(t, serverLogReadonlyPolicy, "policy/", "Server log policy should be valid IAM policy ARN")
}

// Test S3 server access logging configuration
func testS3ServerAccessLogging(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	// Get bucket names from terraform output
	staticBucketName := terraform.Output(t, terraformOptions, "static_bucket_name")
	mediaBucketName := terraform.Output(t, terraformOptions, "media_bucket_name")
	serverLogBucketName := terraform.Output(t, terraformOptions, "server_log_bucket_name")

	// Create AWS session
	sess := createAWSSession(t, awsRegion)
	s3Client := s3.New(sess)

	// Test static bucket logging configuration
	staticLogging, err := s3Client.GetBucketLogging(&s3.GetBucketLoggingInput{
		Bucket: aws.String(staticBucketName),
	})
	require.NoError(t, err, "Should be able to get static bucket logging")
	
	if staticLogging.LoggingEnabled != nil {
		assert.Equal(t, serverLogBucketName, *staticLogging.LoggingEnabled.TargetBucket, "Static bucket should log to server log bucket")
		assert.Contains(t, *staticLogging.LoggingEnabled.TargetPrefix, "a", "Static bucket should have correct log prefix")
	}

	// Test media bucket logging configuration
	mediaLogging, err := s3Client.GetBucketLogging(&s3.GetBucketLoggingInput{
		Bucket: aws.String(mediaBucketName),
	})
	require.NoError(t, err, "Should be able to get media bucket logging")
	
	if mediaLogging.LoggingEnabled != nil {
		assert.Equal(t, serverLogBucketName, *mediaLogging.LoggingEnabled.TargetBucket, "Media bucket should log to server log bucket")
		assert.Contains(t, *mediaLogging.LoggingEnabled.TargetPrefix, "b", "Media bucket should have correct log prefix")
	}
}

// Helper function to create AWS session
func createAWSSession(t *testing.T, region string) *session.Session {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	require.NoError(t, err, "Should be able to create AWS session")
	return sess
}