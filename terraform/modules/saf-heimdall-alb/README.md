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
| [aws_alb.heimdall-alb-private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb.heimdall-alb-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb_listener.private_front_end_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener.public_front_end_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_target_group.private-heimdal-alb-targetgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_alb_target_group.public-heimdal-alb-targetgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_security_group.SafHeimdallAlbSG](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.SafHeimdallContainerCommsSG](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.SafHeimdallContainerCommsEgressRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.SafHeimdallContainerCommsIngressRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addl_alb_sg_ids"></a> [addl\_alb\_sg\_ids](#input\_addl\_alb\_sg\_ids) | Additional SG to apply to the ALB | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | n/a | `string` | `"000"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The private subnet IDs to deploy to | `list(string)` | n/a | yes |
| <a name="input_proj_name"></a> [proj\_name](#input\_proj\_name) | Name of the project in which Heimdall is being deployed | `string` | `"nnc"` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | The public subnet IDs to deploy to | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID for the VPC. Default value is a valid CIDR | `string` | n/a | yes |
| <a name="input_your_name"></a> [your\_name](#input\_your\_name) | Name of the contact tag for all AWS resources | `string` | `"jwhite"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_SafHeimdallContainerCommsSG"></a> [SafHeimdallContainerCommsSG](#output\_SafHeimdallContainerCommsSG) | n/a |
| <a name="output_private_alb_address"></a> [private\_alb\_address](#output\_private\_alb\_address) | n/a |
| <a name="output_private_alb_target_group_id"></a> [private\_alb\_target\_group\_id](#output\_private\_alb\_target\_group\_id) | n/a |
| <a name="output_public_alb_address"></a> [public\_alb\_address](#output\_public\_alb\_address) | n/a |
| <a name="output_public_alb_target_group_id"></a> [public\_alb\_target\_group\_id](#output\_public\_alb\_target\_group\_id) | n/a |
