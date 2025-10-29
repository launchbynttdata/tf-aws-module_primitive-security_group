// Copyright 2025 Launch by NTT DATA

variable "name" {
  description = <<-DESC
    Name of the security group.
    Conflicts with name_prefix. Either name or name_prefix must be specified, but not both.
  DESC
  type        = string
  default     = null
}

variable "name_prefix" {
  description = <<-DESC
    Creates a unique name beginning with the specified prefix.
    Conflicts with name. Either name or name_prefix must be specified, but not both.
  DESC
  type        = string
  default     = null
}

variable "description" {
  description = "Security group description. Defaults to 'Managed by Terraform' if not specified."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created. Must be a valid VPC ID format (vpc-xxxxxxxx)."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC identifier starting with 'vpc-' followed by hexadecimal characters."
  }
}

variable "revoke_rules_on_delete" {
  description = <<-DESC
    Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules
    before deleting the security group itself. This is normally not needed, but can help in certain situations.
  DESC
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the security group. These tags will be merged with default tags."
  type        = map(string)
  default     = {}
}
