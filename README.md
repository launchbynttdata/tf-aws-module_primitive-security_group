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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

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
| <a name="input_name"></a> [name](#input\_name) | Name of the security group.<br/>Conflicts with name\_prefix. Either name or name\_prefix must be specified, but not both. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix.<br/>Conflicts with name. Either name or name\_prefix must be specified, but not both. | `string` | `null` | no |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules<br/>before deleting the security group itself. This is normally not needed, but can help in certain situations. | `bool` | `false` | no |
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

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
