

# S3_Bucket_Public_Write_Prohibited
# AC-03
# SC-07
aws iam create-role --role-name Config_Remediation_Role-S3_Bucket_Public_Write_Prohibited --assume-role-policy-document file://roles/AssumeRoleTrustRelationship.json
aws iam put-role-policy --role-name Config_Remediation_Role-S3_Bucket_Public_Write_Prohibited --policy-name SsmOnboardingInlinePolicy --policy-document file://roles/SsmOnboardingInlinePolicy.json
aws iam put-role-policy --role-name Config_Remediation_Role-S3_Bucket_Public_Write_Prohibited --policy-name SSMQuickSetupEnableExplorerInlinePolicy --policy-document file://roles/SSMQuickSetupEnableExplorerInlinePolicy.json
aws iam put-role-policy --role-name Config_Remediation_Role-S3_Bucket_Public_Write_Prohibited --policy-name AllowPutBucketPublicAccessBlockPolicy --policy-document file://roles/AllowPutBucketPublicAccessBlockPolicy.json
