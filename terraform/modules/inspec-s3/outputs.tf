output "inspec_profiles_bucket_name" {
  value = aws_s3_bucket.inspec_profiles_bucket.id
}

output "inspec_results_bucket_name" {
  value = aws_s3_bucket.inspec_profiles_bucket.id
}

output "inspec_rhel7_baseline_s3_key" {
  value = "s3://${aws_s3_bucket.inspec_profiles_bucket.id}/redhat-enterprise-linux-7-stig-baseline"
}