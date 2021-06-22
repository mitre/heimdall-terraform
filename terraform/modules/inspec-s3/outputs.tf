output "inspec_profiles_bucket_name" {
  value = aws_s3_bucket.inspec_profiles_bucket.id
}

output "inspec_profiles_bucket_arn" {
  value = aws_s3_bucket.inspec_profiles_bucket.arn
}

output "inspec_results_bucket_name" {
  value = aws_s3_bucket.inspec_results_bucket.id
}

output "inspec_results_bucket_arn" {
  value = aws_s3_bucket.inspec_results_bucket.arn
}
