####################
# Label Module
####################

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled     = var.enabled
  namespace   = var.namespace
  tenant      = var.tenant
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags

  label_order         = var.label_order
  regex_replace_chars = var.regex_replace_chars
  id_length_limit     = var.id_length_limit
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case

  additional_tag_map = var.additional_tag_map
  context            = var.context
}

####################
# Random Suffix (for global uniqueness)
####################

resource "random_string" "suffix" {
  count   = var.enabled && var.add_random_suffix ? 1 : 0
  length  = 4
  special = false
  upper   = false
}

locals {
  container_app_environment_name = var.enabled ? (
    var.add_random_suffix ?
    "${module.label.id}${try(random_string.suffix[0].result, "")}" :
    coalesce(var.container_app_environment_name, module.label.id)
  ) : ""
}

####################
# Azure Container App Environment
####################

resource "azurerm_container_app_environment" "this" {
  count = var.enabled ? 1 : 0

  name                = local.container_app_environment_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Log Analytics Workspace integration
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Network configuration
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled

  # High Availability
  zone_redundancy_enabled = var.zone_redundancy_enabled

  # Dapr configuration
  dapr_application_insights_connection_string = var.dapr_application_insights_connection_string

  # Mutual TLS
  mutual_tls_enabled = var.mutual_tls_enabled

  # Workload Profiles (for Consumption + Dedicated plans)
  dynamic "workload_profile" {
    for_each = var.workload_profiles
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }

  tags = module.label.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to workload profiles as they may be managed outside Terraform
      workload_profile
    ]
  }
}
