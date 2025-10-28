// Copyright 2025 Launch by NTT DATA

module "resource_names" {
  # checkov:skip=CKV_TF_1: trusted module source
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.instance_resource
}

module "vpc" {
  # checkov:skip=CKV_TF_1: trusted module source
  source  = "terraform.registry.launch.nttdata.com/module_primitive/vpc/aws"
  version = "~> 1.0"

  cidr_block = var.vpc_cidr

  tags = merge(var.tags, { Name = module.resource_names["vpc"].standard })
}

# Configure default security group to deny all traffic (security best practice)
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  # No ingress or egress rules = deny all traffic
  tags = merge(var.tags, { Name = "${module.resource_names["vpc"].standard}-default-sg" })
}

module "security_group" {
  source = "../.."

  name                   = module.resource_names["security_group"].standard
  description            = "Simple security group example for integration testing"
  vpc_id                 = module.vpc.vpc_id
  revoke_rules_on_delete = true

  tags = var.tags
}
