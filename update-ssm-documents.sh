
# ------------------- #
# IAM_Password_Policy #
# AC-02               #
# ------------------- #

latestDocVersion=$(aws ssm update-document \
    --content file://ssm-remediation-documents/SetPasswordPolicy.json \
    --name "SetPasswordPolicy" \
    --document-format JSON \
    --document-version '$LATEST' \
    | jq -r '.DocumentDescription.LatestVersion')
aws ssm update-document-default-version \
    --name "SetPasswordPolicy" \
    --document-version $latestDocVersion