# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE AZURE OPENAI MODEL DEPLOYMENTS
# This module creates Azure OpenAI model deployments within an existing Azure OpenAI service (Cognitive Account)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# LABEL MODULE
# This module generates consistent names and tags for the resources
# ---------------------------------------------------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AZURE OPENAI MODEL DEPLOYMENTS
# Deploy AI models to an existing Azure OpenAI Service (Cognitive Account)
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_cognitive_deployment" "deployments" {
  for_each = var.enabled ? var.deployments : {}

  name                 = each.key
  cognitive_account_id = var.cognitive_account_id

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  # Note: In AzureRM provider v4.x, scale block has been replaced with sku block
  # The scale_type is now the sku name, and tier/size/family are no longer used
  sku {
    name     = each.value.scale_type
    capacity = each.value.scale_capacity
  }

  rai_policy_name            = each.value.rai_policy_name
  version_upgrade_option     = each.value.version_upgrade_option
  dynamic_throttling_enabled = each.value.dynamic_throttling_enabled
}
