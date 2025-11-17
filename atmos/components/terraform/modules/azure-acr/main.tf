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
  acr_name = var.enabled ? (
    var.add_random_suffix ?
    "${module.label.id}${try(random_string.suffix[0].result, "")}" :
    coalesce(var.container_registry_name, module.label.id)
  ) : ""
}

####################
# Azure Container Registry
####################

resource "azurerm_container_registry" "this" {
  count = var.enabled ? 1 : 0

  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Premium SKU features
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  export_policy_enabled         = var.export_policy_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Encryption (Premium SKU only)
  # Note: In AzureRM provider v4.x, encryption.enabled is deprecated
  # Encryption is automatically enabled when key_vault_key_id is provided
  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  # Georeplications (Premium SKU only)
  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      tags                      = merge(module.label.tags, georeplications.value.tags)
    }
  }

  # Network Rule Set (Premium SKU only)
  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }

      # In AzureRM provider v4.x, virtual_network is deprecated
      # Use public_network_access_enabled = false and network_rule_bypass_option instead
    }
  }

  # Note: retention_policy and trust_policy blocks are deprecated in AzureRM provider v4.x
  # These are now managed through separate resources:
  # - azurerm_container_registry_retention_policy
  # - azurerm_container_registry_trust_policy

  tags = module.label.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to georeplications tags as they are managed separately
      georeplications
    ]
  }
}

####################
# Scope Map (for tokens)
####################

resource "azurerm_container_registry_scope_map" "this" {
  for_each = var.enabled ? var.scope_maps : {}

  name                    = each.key
  container_registry_name = azurerm_container_registry.this[0].name
  resource_group_name     = var.resource_group_name
  actions                 = each.value.actions
}

####################
# Tokens
####################

resource "azurerm_container_registry_token" "this" {
  for_each = var.enabled ? var.tokens : {}

  name                    = each.key
  container_registry_name = azurerm_container_registry.this[0].name
  resource_group_name     = var.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.this[each.value.scope_map_name].id
  enabled                 = each.value.enabled
}

####################
# Webhooks
####################

resource "azurerm_container_registry_webhook" "this" {
  for_each = var.enabled ? var.webhooks : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  registry_name       = azurerm_container_registry.this[0].name
  location            = var.location

  service_uri    = each.value.service_uri
  status         = each.value.status
  scope          = each.value.scope
  actions        = each.value.actions
  custom_headers = each.value.custom_headers

  tags = module.label.tags
}
