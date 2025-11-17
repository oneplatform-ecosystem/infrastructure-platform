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

# PostgreSQL Flexible Server Database
resource "azurerm_postgresql_flexible_server_database" "this" {
  count = var.enabled ? 1 : 0

  name      = coalesce(var.database_name, module.label.id)
  server_id = var.server_id
  collation = var.collation
  charset   = var.charset
}
