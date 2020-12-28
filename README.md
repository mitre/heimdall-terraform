# NNC AWS RDK Controls

## Creating a Custom Named AWS Managed Rule

[AWS Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

[Supported Config Rule Resource Types](https://docs.aws.amazon.com/config/latest/developerguide/resource-config-reference.html)

```bash
cd python
rdk create <custom rule name> --source-identifier <rule source identifier> ...<additional args>...

rdk create 800-53_AC-2_secretsmanager-scheduled-rotation --source-identifier SECRETSMANAGER_SCHEDULED_ROTATION_SUCCESS_CHECK -r
```

Config rule names have the following constraints if created through RDK:
- Match the regex `[a-zA-Z][-a-zA-Z0-9]*|arn:[-a-zA-Z0-9:\/._+]*`
- Be 45 characters at most

Config rule names have the following constraints if created through the AWS console:
- Be 128 characters at most
- No special characters or spaces (`-` and `_` are accepted)


## Useful Scripts

__run all tests__: `./run-all-tests.sh`

__deploy all rules in repo__: `./deploy-all-rules.sh`


## Useful Links

[RDK (Rule Development Kit)](https://github.com/awslabs/aws-config-rdk)

[RDKLib (Library to run rules at scale)](https://github.com/awslabs/aws-config-rdklib)

[AWS Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

[Supported Config Rule Resource Types](https://docs.aws.amazon.com/config/latest/developerguide/resource-config-reference.html)

[Config Rules Engine (Deploy and manage Rules at scale)](https://github.com/awslabs/aws-config-engine-for-compliance-as-code)
