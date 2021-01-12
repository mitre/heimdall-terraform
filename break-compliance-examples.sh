
# This script shouldn't be run as a script - just as examples to modify and use elsewhere
exit


# Enables public read-write for a specific S3 bucket
aws s3api put-bucket-acl --bucket jkufro-s3-test --acl public-read-write


# Provides some insight into the status of remediation actions on a rule
aws configservice describe-remediation-execution-status \
                  --config-rule-name AC-03_S3_Bucket_Public_Write_Prohibited \
                  --region us-gov-west-1 

aws configservice describe-remediation-execution-status \
                  --config-rule-name AC-02_IAM_Password_Policy \
                  --region us-gov-west-1 
