## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_password.rds_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.deployment_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_random_string_length"></a> [random\_string\_length](#input\_random\_string\_length) | how many characters the random string should be | `number` | `10` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deployment_id"></a> [deployment\_id](#output\_deployment\_id) | n/a |
| <a name="output_rds_password"></a> [rds\_password](#output\_rds\_password) | n/a |
