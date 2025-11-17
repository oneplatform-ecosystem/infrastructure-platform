module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled             = var.enabled
  namespace           = var.namespace
  tenant              = var.tenant
  environment         = var.environment
  stage               = var.stage
  name                = var.name
  delimiter           = var.delimiter
  attributes          = var.attributes
  tags                = var.tags
  additional_tag_map  = var.additional_tag_map
  label_order         = var.label_order
  regex_replace_chars = var.regex_replace_chars
  id_length_limit     = var.id_length_limit
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case
  descriptor_formats  = var.descriptor_formats
  labels_as_tags      = var.labels_as_tags
  context             = var.context
}

locals {
  # Use custom name if provided, otherwise use generated name from label module
  cosmosdb_account_name = coalesce(var.cosmosdb_account_name, module.label.id)

  # If geo_locations is not provided, create a single location based on var.location
  geo_locations = length(var.geo_locations) > 0 ? var.geo_locations : [
    {
      location          = var.location
      failover_priority = 0
      zone_redundant    = false
    }
  ]
}

resource "azurerm_cosmosdb_account" "this" {
  count = var.enabled ? 1 : 0

  name                = local.cosmosdb_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind

  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = var.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy.max_staleness_prefix
  }

  dynamic "geo_location" {
    for_each = local.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  dynamic "capabilities" {
    for_each = var.capabilities
    content {
      name = capabilities.value
    }
  }

  automatic_failover_enabled       = var.enable_automatic_failover
  multiple_write_locations_enabled = var.enable_multiple_write_locations
  free_tier_enabled                = var.enable_free_tier
  analytical_storage_enabled       = var.analytical_storage_enabled
  public_network_access_enabled    = var.public_network_access_enabled

  ip_range_filter                       = var.ip_range_filter
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  backup {
    type                = var.backup.type
    interval_in_minutes = var.backup.interval_in_minutes
    retention_in_hours  = var.backup.retention_in_hours
    storage_redundancy  = var.backup.storage_redundancy
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled
  mongo_server_version               = var.mongo_server_version
  local_authentication_disabled      = var.local_authentication_disabled
  default_identity_type              = var.default_identity_type

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers    = cors_rule.value.allowed_headers
      allowed_methods    = cors_rule.value.allowed_methods
      allowed_origins    = cors_rule.value.allowed_origins
      exposed_headers    = cors_rule.value.exposed_headers
      max_age_in_seconds = cors_rule.value.max_age_in_seconds
    }
  }

  dynamic "analytical_storage" {
    for_each = var.analytical_storage_type != null ? [1] : []
    content {
      schema_type = var.analytical_storage_type
    }
  }

  dynamic "capacity" {
    for_each = var.capacity != null ? [1] : []
    content {
      total_throughput_limit = var.capacity.total_throughput_limit
    }
  }

  create_mode = var.create_mode

  dynamic "restore" {
    for_each = var.restore != null ? [1] : []
    content {
      source_cosmosdb_account_id = var.restore.source_cosmosdb_account_id
      restore_timestamp_in_utc   = var.restore.restore_timestamp_in_utc

      dynamic "database" {
        for_each = var.restore.database != null ? var.restore.database : []
        content {
          name             = database.value.name
          collection_names = database.value.collection_names
        }
      }

      dynamic "gremlin_database" {
        for_each = var.restore.gremlin_database != null ? var.restore.gremlin_database : []
        content {
          name        = gremlin_database.value.name
          graph_names = gremlin_database.value.graph_names
        }
      }

      tables_to_restore = var.restore.tables_to_restore
    }
  }

  partition_merge_enabled = var.partition_merge_enabled
  minimal_tls_version     = var.minimal_tls_version

  tags = module.label.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to geo_location order as Azure may reorder them
      geo_location,
    ]
  }
}
