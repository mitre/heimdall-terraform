
# ------------------- #
# IAM_Password_Policy #
# AC-02               #
# ------------------- #
aws ssm create-document \
    --content file://ssm-remediation-documents/SetPasswordPolicy.yaml \
    --name "SetPasswordPolicy" \
    --document-format YAML \
    --document-type "Automation" 
