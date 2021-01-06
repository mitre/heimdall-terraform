
# ------------------- #
# IAM_Password_Policy #
# AC-02               #
# ------------------- #
aws ssm create-document \
    --content file://ssm-remediation-documents/SetPasswordPolicy.json \
    --name "SetPasswordPolicy" \
    --document-type "Command" 
