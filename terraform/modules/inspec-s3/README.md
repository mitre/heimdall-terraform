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
| [aws_s3_bucket.inspec_profiles_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.inspec_results_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_object.rhel7-stig-baseline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-gov-west-1"` | no |
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | n/a | `string` | `"000"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inspec_profiles_bucket_name"></a> [inspec\_profiles\_bucket\_name](#output\_inspec\_profiles\_bucket\_name) | n/a |
| <a name="output_inspec_results_bucket_name"></a> [inspec\_results\_bucket\_name](#output\_inspec\_results\_bucket\_name) | n/a |
| <a name="output_inspec_rhel7_baseline_s3_key"></a> [inspec\_rhel7\_baseline\_s3\_key](#output\_inspec\_rhel7\_baseline\_s3\_key) | n/a |
