// Copyright 2025 Launch by NTT DATA

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    vpc = {
      name       = "vpc"
      max_length = 64
    }
    security_group = {
      name       = "sg"
      max_length = 60
    }
  }
}

variable "instance_env" {
  description = "Number that represents the instance of the environment"
  type        = number
  default     = 0
}

variable "instance_resource" {
  description = "Number that represents the instance of the resource"
  type        = number
  default     = 0
}

variable "logical_product_family" {
  description = "Logical product family name"
  type        = string
  default     = "launch"
}

variable "logical_product_service" {
  description = "Logical product service name"
  type        = string
  default     = "simple"
}

variable "class_env" {
  description = "Environment class (e.g., dev, qa, prod)"
  type        = string
  default     = "sandbox"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "sandbox"
    Example     = "simple"
  }
}
