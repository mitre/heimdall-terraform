## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ConfigToHdf"></a> [ConfigToHdf](#module\_ConfigToHdf) | terraform-aws-modules/lambda/aws |  |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.ConfigToHdfEventRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ConfigToHdfEventTarget](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.ConfigToHdfRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.HeimdallPassKmsKey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_permission.ConfigToHdfEventRuleLambdaPermission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_ssm_parameter.heimdall_pass_ssm_param](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_endpoint.ConfigToHdfConfigVpcEndpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ConfigToHdfSsmVpcEndpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ConfigToHdf_security_groups"></a> [ConfigToHdf\_security\_groups](#input\_ConfigToHdf\_security\_groups) | The security groups to attach to ConfigToHdf lambda | `list(string)` | n/a | yes |
| <a name="input_ConfigVpcEndpoint_security_groups"></a> [ConfigVpcEndpoint\_security\_groups](#input\_ConfigVpcEndpoint\_security\_groups) | The security groups to attach to ConfigToHdfConfigVpcEndpoint VPC endpoint | `list(string)` | n/a | yes |
| <a name="input_SsmVpcEndpoint_security_groups"></a> [SsmVpcEndpoint\_security\_groups](#input\_SsmVpcEndpoint\_security\_groups) | The security groups to attach to ConfigToHdfSsmVpcEndpoint VPC endpoint | `list(string)` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | n/a | `string` | `"missing-account-name"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-gov-west-1"` | no |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | n/a | `string` | `"000"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_function_zip_path"></a> [function\_zip\_path](#input\_function\_zip\_path) | The absolute path to the zipped function | `string` | n/a | yes |
| <a name="input_heimdall_eval_tag"></a> [heimdall\_eval\_tag](#input\_heimdall\_eval\_tag) | The evaluation tag to attach to HDF formatted results | `string` | `"ConfigToHdf"` | no |
| <a name="input_heimdall_password"></a> [heimdall\_password](#input\_heimdall\_password) | The Heimdall user's password used to log in | `string` | n/a | yes |
| <a name="input_heimdall_url"></a> [heimdall\_url](#input\_heimdall\_url) | The url to the Heimdall server in http://... format | `string` | n/a | yes |
| <a name="input_heimdall_user"></a> [heimdall\_user](#input\_heimdall\_user) | The Heimdall user's email used to log in | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The private subnet IDs to deploy to | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID for the VPC. Default value is a valid CIDR | `string` | n/a | yes |

## Outputs

No outputs.
