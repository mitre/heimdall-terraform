##
# Helper script to be copied into a directory where archived InSpec profiles are stored.
#
# This will ls all *.tar.gz files and upload each one to a specified S3 bucket.
#

BUCKET="inspec-profiles-bucket-nncoffline-r6xk"
for f in *.tar.gz; do
  echo "Uploading -> $f"
  aws s3 cp $f s3://$BUCKET/$f
done