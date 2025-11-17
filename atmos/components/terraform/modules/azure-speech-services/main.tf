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

# Azure Speech Services (Cognitive Services Account)
resource "azurerm_cognitive_account" "this" {
  count = var.enabled ? 1 : 0

  name                = module.label.id
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "SpeechServices"
  sku_name            = var.sku_name

  # Custom subdomain for Speech Services
  custom_subdomain_name = var.custom_subdomain_name != null ? var.custom_subdomain_name : module.label.id

  # Network and security settings
  public_network_access_enabled = var.public_network_access_enabled

  # Network ACLs
  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action = network_acls.value.default_action
      ip_rules       = network_acls.value.ip_rules

      # Only include virtual_network_rules if subnet_id is provided
      dynamic "virtual_network_rules" {
        for_each = network_acls.value.subnet_id != null ? [network_acls.value.subnet_id] : []
        content {
          subnet_id                            = virtual_network_rules.value
          ignore_missing_vnet_service_endpoint = network_acls.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  # Managed Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [var.identity_type] : []
    content {
      type         = identity.value
      identity_ids = var.identity_ids
    }
  }

  tags = module.label.tags
}
