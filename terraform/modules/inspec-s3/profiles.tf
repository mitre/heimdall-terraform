
##
# red-hat-enterprise-linux-7-stig-baseline
#
# https://github.com/mitre/redhat-enterprise-linux-7-stig-baseline
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object
#
# TODO: This appears to not upload recursively!
#
resource "aws_s3_bucket_object" "rhel7-stig-baseline" {
  for_each = fileset("./redhat-enterprise-linux-7-stig-baseline", "*")

  bucket = aws_s3_bucket.inspec_profiles_bucket.id
  key    = "redhat-enterprise-linux-7-stig-baseline/${each.value}"
  source = "./redhat-enterprise-linux-7-stig-baseline/${each.value}"

  etag = filemd5("./redhat-enterprise-linux-7-stig-baseline/${each.value}")
}
