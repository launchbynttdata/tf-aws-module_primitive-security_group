// Copyright 2025 Launch by NTT DATA

output "id" {
  description = "The ID of the security group."
  value       = aws_security_group.this.id
}

output "arn" {
  description = "The ARN of the security group."
  value       = aws_security_group.this.arn
}

output "name" {
  description = "The name of the security group."
  value       = aws_security_group.this.name
}

output "vpc_id" {
  description = "The VPC ID where the security group was created."
  value       = aws_security_group.this.vpc_id
}

output "owner_id" {
  description = "The AWS account ID of the owner of the security group."
  value       = aws_security_group.this.owner_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_security_group.this.tags_all
}
