// Copyright 2025 Launch by NTT DATA

resource "aws_security_group" "this" {
  name                   = var.name
  name_prefix            = var.name_prefix
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = local.tags

  # Use create_before_destroy to prevent potential issues when replacing security groups.
  # AWS security groups cannot be modified in certain ways (e.g., changing the name or VPC),
  # which requires replacement. If a security group is attached to running resources (like EC2 instances),
  # destroying it first would temporarily disconnect those resources from the network.
  # Creating the replacement first ensures continuous network connectivity during updates.
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#recreating-a-security-group
  lifecycle {
    create_before_destroy = true
  }
}
