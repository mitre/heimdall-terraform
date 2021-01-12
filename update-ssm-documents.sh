
# ------------------- #
# IAM_Password_Policy #
# AC-02               #
# ------------------- #

latestDocVersion=$(aws ssm update-document \
    --content file://ssm-remediation-documents/SetPasswordPolicy.yaml \
    --name "SetPasswordPolicy" \
    --document-format YAML \
    --document-version '$LATEST' \
    | jq -r '.DocumentDescription.LatestVersion')
aws ssm update-document-default-version \
    --name "SetPasswordPolicy" \
    --document-version $latestDocVersion