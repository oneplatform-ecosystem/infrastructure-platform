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

# Azure PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "this" {
  count = var.enabled ? 1 : 0

  name                = coalesce(var.server_name, module.label.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name   = var.sku_name
  storage_mb = var.storage_mb
  version    = var.postgres_version

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  auto_grow_enabled            = var.auto_grow_enabled

  public_network_access_enabled = var.public_network_access_enabled
  zone                          = var.zone

  dynamic "authentication" {
    for_each = var.authentication_config != null ? [var.authentication_config] : []
    content {
      active_directory_auth_enabled = lookup(authentication.value, "active_directory_auth_enabled", false)
      password_auth_enabled         = lookup(authentication.value, "password_auth_enabled", true)
      tenant_id                     = lookup(authentication.value, "tenant_id", null)
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_id != null ? [1] : []
    content {
      key_vault_key_id                  = var.customer_managed_key_id
      primary_user_assigned_identity_id = var.primary_user_assigned_identity_id
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode                      = var.high_availability_mode
      standby_availability_zone = var.standby_availability_zone
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = lookup(maintenance_window.value, "day_of_week", 0)
      start_hour   = lookup(maintenance_window.value, "start_hour", 0)
      start_minute = lookup(maintenance_window.value, "start_minute", 0)
    }
  }

  tags = module.label.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
}

# PostgreSQL Flexible Server Configuration
resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each = var.enabled ? var.server_configurations : {}

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this[0].id
  value     = each.value
}

# PostgreSQL Flexible Server Database
resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = var.enabled ? var.databases : {}

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this[0].id
  collation = lookup(each.value, "collation", "en_US.utf8")
  charset   = lookup(each.value, "charset", "UTF8")
}

# Firewall Rules
resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.enabled ? var.firewall_rules : {}

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this[0].id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Active Directory Administrator
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  count = var.enabled && var.azuread_administrator != null ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.this[0].name
  resource_group_name = var.resource_group_name
  tenant_id           = var.azuread_administrator.tenant_id
  object_id           = var.azuread_administrator.object_id
  principal_name      = var.azuread_administrator.principal_name
  principal_type      = var.azuread_administrator.principal_type
}
