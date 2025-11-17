module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  tenant      = var.tenant
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags

  regex_replace_chars = var.regex_replace_chars
  label_order         = var.label_order
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case
  id_length_limit     = var.id_length_limit
}

locals {
  datafactory_name = coalesce(var.datafactory_name, module.label.id)
}

resource "azurerm_data_factory" "this" {
  count = var.enabled ? 1 : 0

  name                = local.datafactory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Public network access
  public_network_enabled = var.public_network_enabled

  # Managed Virtual Network
  managed_virtual_network_enabled = var.managed_virtual_network_enabled

  # Customer Managed Key
  customer_managed_key_id = var.customer_managed_key_id

  # Managed Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [var.identity_type] : []
    content {
      type         = identity.value
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  # GitHub Configuration
  dynamic "github_configuration" {
    for_each = var.github_configuration != null ? [var.github_configuration] : []
    content {
      account_name       = github_configuration.value.account_name
      branch_name        = github_configuration.value.branch_name
      repository_name    = github_configuration.value.repository_name
      root_folder        = github_configuration.value.root_folder
      git_url            = github_configuration.value.git_url
      publishing_enabled = try(github_configuration.value.publishing_enabled, true)
    }
  }

  # Azure DevOps (VSTS) Configuration
  dynamic "vsts_configuration" {
    for_each = var.vsts_configuration != null ? [var.vsts_configuration] : []
    content {
      account_name       = vsts_configuration.value.account_name
      branch_name        = vsts_configuration.value.branch_name
      project_name       = vsts_configuration.value.project_name
      repository_name    = vsts_configuration.value.repository_name
      root_folder        = vsts_configuration.value.root_folder
      tenant_id          = vsts_configuration.value.tenant_id
      publishing_enabled = try(vsts_configuration.value.publishing_enabled, true)
    }
  }

  # Global Parameters
  dynamic "global_parameter" {
    for_each = var.global_parameters != null ? var.global_parameters : []
    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  tags = module.label.tags
}
