# NNC AWS RDK Controls

## Creating a Custom Named AWS Managed Rule

[AWS Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

[Supported Config Rule Resource Types](https://docs.aws.amazon.com/config/latest/developerguide/resource-config-reference.html)

```bash
cd python
rdk create <custom rule name> --source-identifier <rule source identifier> ...<additional args>...

# Periodic rule 
rdk create CM-08-03_Cloudwatch_Log_Group_Encrypted --source-identifier CLOUDWATCH_LOG_GROUP_ENCRYPTED --maximum-frequency TwentyFour_Hours 

# Configuration change based rule
rdk create CM-08-03_EC2_Managedinstance_Patch_Compliance_Status_Check --source-identifier EC2_MANAGEDINSTANCE_PATCH_COMPLIANCE_STATUS_CHECK --resource-types AWS::SSM::PatchCompliance
```

## Concepts

### Config Rules

Config rules allow specifying the definitiion of compliance for specific types of AWS resources. AWS has many pre-made rules that may be used (see `AC-02_IAM_Password_Policy`), and also allows the creation of custom rules (see `SC-07_EC2_Instance_No_Public_IP`). The configuration of both types may be found under the `python` directory.


### IAM Roles

IAM roles allow AWS to assume certain permissions when remediating a non-compliant config rule. The configuration for these roles can be found under the `roles` directory. All roles should have the `AssumeRoleTrustRelationship` trust policy, as well as both the `SsmOnboardingInlinePolicy` and `SSMQuickSetupEnableExplorerInlinePolicy` inline policies. On top of this, a role should have the MINIMUM permissions it needs to perform its specific remediation task. When specifying the remediation role in a `parameters.json` file, you must specify the region (i.e. no generics that can be assiumed like). The default aws prefix would be `arn:aws:iam::...` and the gov west prefix would be `arn:aws-us-gov:iam::...`.


### SSM Documents

SSM documents are used here to specify how non-compliant config rules should be remediated. AWS has many pre-made remediations that may be used, and also allows the creation of custom remediations. The custom remediation documents can be found under the `ssm-remediation-documents` folder. Note that ONLY `Automation` type SSM documents may be used for AWS config rule remediation. 


## Useful Scripts

__run all tests__: `./run-tests.sh`

__deploy all IAM roles for remediations__: `./deploy-roles.sh`

__deploy all SSM documents for remediations__: `./deploy-ssm-documents.sh`

__update all SSM documents for remediations__: `./update-ssm-documents.sh`

__deploy all rules in repo__: `./deploy-rules.sh`


## Initial Deployment Steps

```bash
./deploy-roles.sh
./deploy-ssm-documents.sh
./deploy-all-rules.sh
```


## Limitations

- Python RDK rule name length constraint is out of date: https://github.com/awslabs/aws-config-rdk/pull/284
- Python RDK supported resource types are out of date: https://github.com/awslabs/aws-config-rdk/pull/285
- conformance packs are not currently available in US-Gov-West region
- Rules in AWS console cannot be sorted by rule name


## Useful Links

[RDK (Rule Development Kit)](https://github.com/awslabs/aws-config-rdk)

[RDKLib (Library to run rules at scale)](https://github.com/awslabs/aws-config-rdklib)

[AWS Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

[Supported Config Rule Resource Types](https://docs.aws.amazon.com/config/latest/developerguide/resource-config-reference.html)

[Config Rules Engine (Deploy and manage Rules at scale)](https://github.com/awslabs/aws-config-engine-for-compliance-as-code)

[SSM Syntax](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-doc-syntax.html)

[Remediation Configuration Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-remediationconfiguration.html)

[Automation SSM Document Reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-actions.html)

[Automation aws:executeScript Reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-action-executeScript.html)

[Boto3 Reference](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/index.html)

[IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

[Example IAM policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_examples.html)
