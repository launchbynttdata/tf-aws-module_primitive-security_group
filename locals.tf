// Copyright 2025 Launch by NTT DATA

locals {
  # Canonical tagging pattern
  default_tags = {
    provisioner = "Terraform"
  }
  tags = merge(local.default_tags, var.tags)

  # Count how many naming options are specified
  name_count = sum([
    var.name != null ? 1 : 0,
    var.name_prefix != null ? 1 : 0,
  ])

  # Validation flag for mutual exclusivity
  validate_name_options = local.name_count == 1
}

# Validation check block for name mutual exclusivity
check "name_validation" {
  assert {
    condition     = local.validate_name_options
    error_message = "Exactly one naming option must be specified: either 'name' or 'name_prefix', but not both."
  }
}
