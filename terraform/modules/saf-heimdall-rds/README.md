## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.heimdall_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.heimdall_pg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.heimdall_subg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_role.rds_cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.rds_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.SafRdsSG](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.SafRdsEgressRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.SafRdsIngressRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy.rds_enhanced_monitoring_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Initial size of database for Heimdall in GiB | `number` | `20` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Specifies whether to remove automated backups immediately after the DB instance is deleted. | `bool` | `false` | no |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | n/a | `string` | `"000"` | no |
| <a name="input_display_db_pass"></a> [display\_db\_pass](#input\_display\_db\_pass) | Shouold terraform output the generated heimdall database password to stdout? | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_include_special_db_pass"></a> [include\_special\_db\_pass](#input\_include\_special\_db\_pass) | Whether or not to include special characters in the db passcode. This requires URI encoding, so the default is false | `bool` | `true` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Size and type of instance to run RDS. See: https://aws.amazon.com/rds/instance-types/ | `string` | `"db.t2.micro"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum size of database for Heimdall in GiB | `number` | `100` | no |
| <a name="input_rds_password"></a> [rds\_password](#input\_rds\_password) | Password for the RDS instance. | `string` | `"Password123"` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type for RDS storage, best to leave this as default gp2, see: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#Concepts.Storage | `string` | `"gp2"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The private subnet IDs to deploy to | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID for the VPC. Default value is a valid CIDR | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_db_name"></a> [rds\_db\_name](#output\_rds\_db\_name) | n/a |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | n/a |
| <a name="output_rds_password"></a> [rds\_password](#output\_rds\_password) | n/a |
| <a name="output_rds_sg_id"></a> [rds\_sg\_id](#output\_rds\_sg\_id) | n/a |
| <a name="output_rds_user_name"></a> [rds\_user\_name](#output\_rds\_user\_name) | n/a |
