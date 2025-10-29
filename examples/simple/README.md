# Example: Simple Security Group Configuration

This example demonstrates a straightforward AWS Security Group configuration. This example is primarily used by the integration test framework.

## Features

- Creates a VPC with public and private subnets
- Configures the default security group to deny all traffic (security best practice)
- Creates a security group with standard configuration
- Uses Launch resource naming conventions
- Enables `revoke_rules_on_delete` option

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.5 |
| aws | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.100 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| resource_names | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| vpc | terraform-aws-modules/vpc/aws | ~> 5.0 |
| security_group | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| aws_default_security_group.default | resource |

## Inputs

See `variables.tf` for input descriptions and defaults.

## Outputs

| Name | Description |
|------|-------------|
| resource_id | The ID of the security group |
| resource_name | The name of the security group |
| security_group_arn | The ARN of the security group |
| vpc_id | The VPC ID where the security group was created |
| owner_id | The AWS account ID of the security group owner |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform.registry.launch.nttdata.com/module_primitive/vpc/aws | ~> 1.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br/>    name       = string<br/>    max_length = optional(number, 60)<br/>  }))</pre> | <pre>{<br/>  "security_group": {<br/>    "max_length": 60,<br/>    "name": "sg"<br/>  },<br/>  "vpc": {<br/>    "max_length": 64,<br/>    "name": "vpc"<br/>  }<br/>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource | `number` | `0` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family name | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service name | `string` | `"simple"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class (e.g., dev, qa, prod) | `string` | `"sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | `"10.2.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | <pre>{<br/>  "Environment": "sandbox",<br/>  "Example": "simple"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The ID of the security group |
| <a name="output_resource_name"></a> [resource\_name](#output\_resource\_name) | The name of the security group |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID where the security group was created |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS account ID of the security group owner |
<!-- END_TF_DOCS -->
