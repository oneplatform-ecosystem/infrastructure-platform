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
  # Redis Cache name
  redis_cache_name = var.enabled ? coalesce(var.redis_cache_name, module.label.id) : null
}

# Azure Cache for Redis
resource "azurerm_redis_cache" "this" {
  count = var.enabled ? 1 : 0

  name                = local.redis_cache_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # SKU Configuration
  sku_name = var.sku_name
  family   = var.family
  capacity = var.capacity

  # Redis Configuration
  redis_version                 = var.redis_version
  non_ssl_port_enabled          = var.enable_non_ssl_port
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled

  # Note: In v4.x, enable_authentication has been removed from redis_configuration
  # Authentication is now always enabled for security reasons and cannot be disabled

  # Redis Configuration Options
  dynamic "redis_configuration" {
    for_each = var.redis_configuration != null ? [var.redis_configuration] : []
    content {
      maxmemory_reserved              = redis_configuration.value.maxmemory_reserved
      maxmemory_delta                 = redis_configuration.value.maxmemory_delta
      maxmemory_policy                = redis_configuration.value.maxmemory_policy
      maxfragmentationmemory_reserved = redis_configuration.value.maxfragmentationmemory_reserved
      notify_keyspace_events          = redis_configuration.value.notify_keyspace_events

      # AOF Persistence (Premium only)
      aof_backup_enabled              = redis_configuration.value.aof_backup_enabled
      aof_storage_connection_string_0 = redis_configuration.value.aof_storage_connection_string_0
      aof_storage_connection_string_1 = redis_configuration.value.aof_storage_connection_string_1

      # RDB Persistence
      rdb_backup_enabled            = redis_configuration.value.rdb_backup_enabled
      rdb_backup_frequency          = redis_configuration.value.rdb_backup_frequency
      rdb_backup_max_snapshot_count = redis_configuration.value.rdb_backup_max_snapshot_count
      rdb_storage_connection_string = redis_configuration.value.rdb_storage_connection_string
    }
  }

  # Patch Schedule
  dynamic "patch_schedule" {
    for_each = var.patch_schedules
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = patch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }

  # Premium SKU Features
  zones                = var.zones
  replicas_per_primary = var.replicas_per_primary
  shard_count          = var.shard_count
  subnet_id            = var.subnet_id

  # Managed Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = module.label.tags

  lifecycle {
    ignore_changes = [
      redis_configuration[0].rdb_storage_connection_string,
      redis_configuration[0].aof_storage_connection_string_0,
      redis_configuration[0].aof_storage_connection_string_1
    ]
  }
}

# Private Endpoint for Redis Cache
resource "azurerm_private_endpoint" "this" {
  count = var.enabled && var.create_private_endpoint ? 1 : 0

  name                = "${local.redis_cache_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.redis_cache_name}-psc"
    private_connection_resource_id = azurerm_redis_cache.this[0].id
    is_manual_connection           = var.private_endpoint_manual_connection
    subresource_names              = ["redisCache"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoint_dns_zone_group != null ? [var.private_endpoint_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  tags = module.label.tags
}
