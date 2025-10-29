// Copyright 2025 Launch by NTT DATA

# Normalized outputs for test framework
output "resource_id" {
  description = "The ID of the security group"
  value       = module.security_group.id
}

output "resource_name" {
  description = "The name of the security group"
  value       = module.security_group.name
}

# Additional outputs
output "security_group_arn" {
  description = "The ARN of the security group"
  value       = module.security_group.arn
}

output "security_group_tags_all" {
  description = "All tags applied to the security group (including defaults)"
  value       = module.security_group.tags_all
}

output "vpc_id" {
  description = "The VPC ID where the security group was created"
  value       = module.vpc.vpc_id
}
