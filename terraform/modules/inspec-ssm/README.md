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
| [aws_ssm_association.rhel7-stig-baseline-SSM](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | n/a | `string` | `"000"` | no |
| <a name="input_inspec_rhel7_baseline_s3_key"></a> [inspec\_rhel7\_baseline\_s3\_key](#input\_inspec\_rhel7\_baseline\_s3\_key) | n/a | `string` | n/a | yes |
| <a name="input_inspec_rhel7_baseline_schedule"></a> [inspec\_rhel7\_baseline\_schedule](#input\_inspec\_rhel7\_baseline\_schedule) | n/a | `string` | `"cron(0/30 * * * ? *)"` | no |
| <a name="input_inspec_s3_bucket_name"></a> [inspec\_s3\_bucket\_name](#input\_inspec\_s3\_bucket\_name) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
