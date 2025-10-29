# Example: Complete Security Group Configuration

This example demonstrates comprehensive configuration options for AWS Security Groups using the primitive module.

## Features

- Creates a VPC with public and private subnets
- Configures the default security group to deny all traffic (security best practice)
- Creates a security group with all available configuration options
- Demonstrates the canonical tagging pattern and custom tag merging
- Shows the `revoke_rules_on_delete` option

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

## What This Example Shows

### All Configuration Options

This example demonstrates all available configuration options for the security group module:

- **name**: Explicit security group name using Launch naming conventions
- **description**: Custom description for the security group
- **vpc_id**: VPC where the security group is created
- **revoke_rules_on_delete**: Set to true to revoke rules before deletion
- **tags**: Custom tags merged with the module's default tags

### Tag Merging

Shows how custom tags are merged with the module's default tags:

- Module always adds: `provisioner = "Terraform"`
- User tags override defaults
- Example adds cost center, owner, and compliance tags

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
| resource_id | The ID of the security group (normalized for tests) |
| resource_name | The name of the security group (normalized for tests) |
| security_group_arn | ARN of the security group |
| security_group_tags_all | All tags including provider defaults |
| vpc_id | VPC ID where the security group was created |

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
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service name | `string` | `"complete"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class (e.g., dev, qa, prod) | `string` | `"demo"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | `"10.1.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | <pre>{<br/>  "Environment": "demo",<br/>  "Example": "complete",<br/>  "Terraform": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The ID of the security group |
| <a name="output_resource_name"></a> [resource\_name](#output\_resource\_name) | The name of the security group |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group |
| <a name="output_security_group_tags_all"></a> [security\_group\_tags\_all](#output\_security\_group\_tags\_all) | All tags applied to the security group (including defaults) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID where the security group was created |
<!-- END_TF_DOCS -->
