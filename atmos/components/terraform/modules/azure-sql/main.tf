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

# Azure SQL Server
resource "azurerm_mssql_server" "this" {
  count = var.enabled ? 1 : 0

  name                         = coalesce(var.sql_server_name, module.label.id)
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = azuread_administrator.value.tenant_id
      azuread_authentication_only = lookup(azuread_administrator.value, "azuread_authentication_only", false)
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = module.label.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "this" {
  count = var.enabled ? 1 : 0

  name                        = coalesce(var.database_name, "${module.label.id}-db")
  server_id                   = azurerm_mssql_server.this[0].id
  collation                   = var.collation
  license_type                = var.license_type
  max_size_gb                 = var.max_size_gb
  read_scale                  = var.read_scale
  sku_name                    = var.sku_name
  zone_redundant              = var.zone_redundant
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  min_capacity                = var.min_capacity
  storage_account_type        = var.storage_account_type

  dynamic "short_term_retention_policy" {
    for_each = var.short_term_retention_policy != null ? [var.short_term_retention_policy] : []
    content {
      retention_days           = short_term_retention_policy.value.retention_days
      backup_interval_in_hours = lookup(short_term_retention_policy.value, "backup_interval_in_hours", 12)
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = var.long_term_retention_policy != null ? [var.long_term_retention_policy] : []
    content {
      weekly_retention  = lookup(long_term_retention_policy.value, "weekly_retention", null)
      monthly_retention = lookup(long_term_retention_policy.value, "monthly_retention", null)
      yearly_retention  = lookup(long_term_retention_policy.value, "yearly_retention", null)
      week_of_year      = lookup(long_term_retention_policy.value, "week_of_year", null)
    }
  }

  dynamic "threat_detection_policy" {
    for_each = var.threat_detection_policy != null ? [var.threat_detection_policy] : []
    content {
      state                      = lookup(threat_detection_policy.value, "state", "Enabled")
      disabled_alerts            = lookup(threat_detection_policy.value, "disabled_alerts", [])
      email_account_admins       = lookup(threat_detection_policy.value, "email_account_admins", "Disabled")
      email_addresses            = lookup(threat_detection_policy.value, "email_addresses", [])
      retention_days             = lookup(threat_detection_policy.value, "retention_days", 0)
      storage_account_access_key = lookup(threat_detection_policy.value, "storage_account_access_key", null)
      storage_endpoint           = lookup(threat_detection_policy.value, "storage_endpoint", null)
    }
  }

  tags = module.label.tags
}

# Firewall Rules
resource "azurerm_mssql_firewall_rule" "this" {
  for_each = var.enabled ? var.firewall_rules : {}

  name             = each.key
  server_id        = azurerm_mssql_server.this[0].id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Virtual Network Rule
resource "azurerm_mssql_virtual_network_rule" "this" {
  for_each = var.enabled ? var.virtual_network_rules : {}

  name      = each.key
  server_id = azurerm_mssql_server.this[0].id
  subnet_id = each.value.subnet_id
}
