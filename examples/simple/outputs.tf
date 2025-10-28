// Copyright 2025 Launch by NTT DATA

output "resource_id" {
  description = "The ID of the security group"
  value       = module.security_group.id
}

output "resource_name" {
  description = "The name of the security group"
  value       = module.security_group.name
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = module.security_group.arn
}

output "vpc_id" {
  description = "The VPC ID where the security group was created"
  value       = module.security_group.vpc_id
}

output "owner_id" {
  description = "The AWS account ID of the security group owner"
  value       = module.security_group.owner_id
}
