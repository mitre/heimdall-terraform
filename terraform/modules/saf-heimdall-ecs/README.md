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
| [aws_cloudwatch_log_group.heimdall_cwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.heimdall_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.heimdall_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ECS_execution_agent_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ECSTaskExec-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.RDSFullAccess-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group_rule.S3GatewayEndpointEgressRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.CloudWatchVpcEndpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.EcrApiVpcEndpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.EcrDkrVpcEndpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3VpcEndpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_ecs_cluster.heimdall_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_prefix_list.s3VpcEndpointPrefixList](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/prefix_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AmazonECSTaskExecutionRolePolicy_arn"></a> [AmazonECSTaskExecutionRolePolicy\_arn](#input\_AmazonECSTaskExecutionRolePolicy\_arn) | The ARN for the ECS task execution role policy. Change this from the default if working in non standard region (govcloud) | `string` | `"arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"` | no |
| <a name="input_AmazonRDSDataFullAccess_arn"></a> [AmazonRDSDataFullAccess\_arn](#input\_AmazonRDSDataFullAccess\_arn) | The ARN for the RDS full access role policy. Change this from the default if working in non standard region (govcloud) | `string` | `"arn:aws:iam::aws:policy/AmazonRDSFullAccess"` | no |
| <a name="input_DISABLE_SPRING"></a> [DISABLE\_SPRING](#input\_DISABLE\_SPRING) | Disable springboot in Heimdall deployment? Default false | `bool` | `false` | no |
| <a name="input_HEIMDALL_RELATIVE_URL_ROOT"></a> [HEIMDALL\_RELATIVE\_URL\_ROOT](#input\_HEIMDALL\_RELATIVE\_URL\_ROOT) | Relative root url for heimdall deployment location. Default empty | `string` | `""` | no |
| <a name="input_RAILS_ENV"></a> [RAILS\_ENV](#input\_RAILS\_ENV) | Environment tag for rails deployment. Default production | `string` | `"production"` | no |
| <a name="input_RAILS_LOG_TO_STDOUT"></a> [RAILS\_LOG\_TO\_STDOUT](#input\_RAILS\_LOG\_TO\_STDOUT) | Display rails logs to stdout for viewing in AWS cloudwatch/ECS logs? Default true | `bool` | `true` | no |
| <a name="input_RAILS_SERVE_STATIC_FILES"></a> [RAILS\_SERVE\_STATIC\_FILES](#input\_RAILS\_SERVE\_STATIC\_FILES) | Whether rails serves static files in its deployment. Default true | `bool` | `true` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy to. | `string` | `"us-gov-west-1"` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the domain certificate for Heimdall. See: https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html | `string` | `"arn:aws-us-gov:acm:us-gov-west-1:060708420889:certificate/4c71d20b-a581-4ee1-a342-c254b74e2126"` | no |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | n/a | `string` | `"000"` | no |
| <a name="input_ecs_security_group_ids"></a> [ecs\_security\_group\_ids](#input\_ecs\_security\_group\_ids) | The Security Groups to apply to the ECS instances | `list(string)` | `[]` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_heimdall_ecr_arn"></a> [heimdall\_ecr\_arn](#input\_heimdall\_ecr\_arn) | The ARN of the AWS ECR repository | `string` | n/a | yes |
| <a name="input_heimdall_image"></a> [heimdall\_image](#input\_heimdall\_image) | Heimdall image repo url and version. Ex: mitre/heimdall:latest | `string` | `"mitre/heimdall2:release-latest"` | no |
| <a name="input_private_alb_target_group_id"></a> [private\_alb\_target\_group\_id](#input\_private\_alb\_target\_group\_id) | Private ALB Target Group ID for ECS. | `string` | n/a | yes |
| <a name="input_proj_name"></a> [proj\_name](#input\_proj\_name) | Name of the project in which Heimdall is being deployed | `string` | `"nnc"` | no |
| <a name="input_public_alb_target_group_id"></a> [public\_alb\_target\_group\_id](#input\_public\_alb\_target\_group\_id) | Public ALB Target Group ID for ECS. | `string` | n/a | yes |
| <a name="input_rds_db_name"></a> [rds\_db\_name](#input\_rds\_db\_name) | n/a | `string` | `""` | no |
| <a name="input_rds_endpoint"></a> [rds\_endpoint](#input\_rds\_endpoint) | n/a | `string` | `""` | no |
| <a name="input_rds_password"></a> [rds\_password](#input\_rds\_password) | n/a | `string` | `""` | no |
| <a name="input_rds_sg_id"></a> [rds\_sg\_id](#input\_rds\_sg\_id) | n/a | `string` | `""` | no |
| <a name="input_rds_user_name"></a> [rds\_user\_name](#input\_rds\_user\_name) | n/a | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The private subnet IDs to deploy to | `list(string)` | n/a | yes |
| <a name="input_vpcEndpoint_security_group"></a> [vpcEndpoint\_security\_group](#input\_vpcEndpoint\_security\_group) | The security group to attach to ECR VPC endpoints | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy Heimdall into. | `string` | n/a | yes |
| <a name="input_your_name"></a> [your\_name](#input\_your\_name) | Name of the contact tag for all AWS resources | `string` | `"jwhite"` | no |

## Outputs

No outputs.
