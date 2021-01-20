# NNC AWS RDK Controls

## Creating a Custom Named AWS Managed Rule

[AWS Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

[Supported Config Rule Resource Types](https://docs.aws.amazon.com/config/latest/developerguide/resource-config-reference.html)

```bash
cd rules
rdk create <custom rule name> --source-identifier <rule source identifier> ...<additional args>...

# Periodic rule 
rdk create KMS_CMK_Not_Scheduled_For_Deletion --source-identifier KMS_CMK_NOT_SCHEDULED_FOR_DELETION --maximum-frequency TwentyFour_Hours 

# Configuration change based rule
rdk create EC2_Instance_Detailed_Monitoring_Enabled --source-identifier EC2_INSTANCE_DETAILED_MONITORING_ENABLED --resource-types AWS::EC2::Instance
```

## Concepts

### Config Rules

Config rules allow specifying the definitiion of compliance for specific types of AWS resources. AWS has many pre-made rules that may be used (see `AC-02_IAM_Password_Policy`), and also allows the creation of custom rules (see `SC-07_EC2_Instance_No_Public_IP`). The configuration of both types may be found under the `rules` directory.

#### Config Rule Tags
The `generate_compliance_report.py` script that generates xlsx parses the tags assigned in rules' `parameters.json` files to populate a few columns. The blank tags property can be found below to be filled out inside a new rule.

[Rules for AWS Config Tags](https://docs.aws.amazon.com/config/latest/developerguide/tagging.html)

```json
{
    "Tags": "[{\"Key\": \"TestType\", \"Value\": \"\"}, {\"Key\": \"CloudResource\", \"Value\": \"\"}, {\"Key\": \"Category\", \"Value\": \"\"}, {\"Key\": \"Responsibility\", \"Value\": \"\"}, {\"Key\": \"ValidationSteps\", \"Value\": \"\"}, {\"Key\": \"USNORTHCOMValidated\", \"Value\": \"\"}]"
}
```


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

__generate  xlsx for rule compliance__: `python generate_compliance_report.py`


## Initial Deployment Steps

```bash
./deploy-roles.sh
./deploy-ssm-documents.sh
./deploy-rules.sh
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
