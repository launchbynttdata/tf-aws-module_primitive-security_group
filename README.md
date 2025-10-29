# tf-aws-module_primitive-security_group

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

Terraform primitive module for managing AWS Security Group resources. This module wraps the `aws_security_group` resource and provides sensible defaults, validation, and the canonical Launch tagging pattern.

A primitive module manages a **single AWS resource** and follows Launch organizational standards for structure, testing, and documentation.

## Important Notes

- This module creates **only the security group resource itself**
- It does **NOT** create ingress or egress rules
- Use separate rule resources (`aws_vpc_security_group_ingress_rule`, `aws_vpc_security_group_egress_rule`) to manage traffic rules
- Launch provides primitive modules for rule management

## Pre-Commit hooks

[`.pre-commit-config.yaml`](.github/.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with `PATCH` in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with `MINOR` in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with `MAJOR` in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than `BREAKING CHANGE: <description>` may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. _THIS STEP APPLIES ONLY TO MICROSOFT AZURE. IF YOU ARE USING A DIFFERENT PLATFORM PLEASE SKIP THIS STEP._ The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `azure_env.sh` file on local workstation. Devloper would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Service principle used for authentication(value of ARM_CLIENT_ID) should have below privileges on resource group within the subscription.

```
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
```

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `azure` specific. If primitive/segment under development uses any other cloud provider than azure, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "azurerm" {
  features {}
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests

## Usage

```hcl
module "security_group" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/security_group/aws"
  version = "~> 1.0"

  name        = "my-security-group"
  description = "Security group for application servers"
  vpc_id      = "vpc-1234567890abcdef0"

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

## Examples

- [Minimal](examples/minimal) - Minimal security group with required parameters only
- [Complete](examples/complete) - Comprehensive example showing all configuration options
- [Simple](examples/simple) - Simple working example used by integration tests

## Validation

This module implements the following validations:

### VPC ID Format Validation
Validates that the `vpc_id` follows the AWS VPC ID format: `vpc-` followed by hexadecimal characters.

```hcl
validation {
  condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
  error_message = "VPC ID must be a valid AWS VPC identifier starting with 'vpc-' followed by hexadecimal characters."
}
```

### Name Mutual Exclusivity
Ensures that exactly one naming option is specified: either `name` OR `name_prefix`, but not both. Implemented using check blocks (Terraform 1.5+).

```hcl
check "name_validation" {
  assert {
    condition     = local.validate_name_options
    error_message = "Exactly one naming option must be specified: either 'name' or 'name_prefix', but not both."
  }
}
```

**Why check blocks?**
- Non-blocking warnings (don't fail entire apply)
- More flexible than preconditions
- Let AWS provider handle complex validations

## Tagging Strategy

This module implements the canonical Launch tagging pattern:

```hcl
locals {
  default_tags = {
    provisioner = "Terraform"
  }
  tags = merge(local.default_tags, var.tags)
}
```

User-provided tags override defaults via `merge()` order. The `provisioner = "Terraform"` tag is always applied.

## Testing

Testing is performed using `make check` which runs:

- `terraform fmt` - Code formatting
- `terraform validate` - Syntax validation
- `tflint` - Linting
- `conftest` - Policy-as-code validation
- `regula` - Security compliance scanning
- Integration tests using Terratest (Go)

To run tests locally:

```bash
make configure  # First time only
pre-commit install
make check
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the security group.<br/>Conflicts with name\_prefix. Either name or name\_prefix must be specified, but not both. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix.<br/>Conflicts with name. Either name or name\_prefix must be specified, but not both. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Security group description. Defaults to 'Managed by Terraform' if not specified. | `string` | `"Managed by Terraform"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created. Must be a valid VPC ID format (vpc-xxxxxxxx). | `string` | n/a | yes |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules<br/>before deleting the security group itself. This is normally not needed, but can help in certain situations. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the security group. These tags will be merged with default tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the security group. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the security group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the security group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID where the security group was created. |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS account ID of the owner of the security group. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags. |
<!-- END_TF_DOCS -->


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Security group description. Defaults to 'Managed by Terraform' if not specified. | `string` | `"Managed by Terraform"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the security group. <br/>Conflicts with name\_prefix. Either name or name\_prefix must be specified, but not both. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix. <br/>Conflicts with name. Either name or name\_prefix must be specified, but not both. | `string` | `null` | no |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules <br/>before deleting the security group itself. This is normally not needed, but can help in certain situations. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the security group. These tags will be merged with default tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created. Must be a valid VPC ID format (vpc-xxxxxxxx). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the security group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the security group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the security group. |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS account ID of the owner of the security group. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID where the security group was created. |
<!-- END_TF_DOCS -->
