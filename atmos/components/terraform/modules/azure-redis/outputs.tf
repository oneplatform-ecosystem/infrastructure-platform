output "redis_cache_id" {
  description = "The ID of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].id : null
}

output "redis_cache_name" {
  description = "The name of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].name : null
}

output "redis_cache_hostname" {
  description = "The hostname of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].hostname : null
}

output "redis_cache_port" {
  description = "The non-SSL port of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].port : null
}

output "redis_cache_ssl_port" {
  description = "The SSL port of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].ssl_port : null
}

output "redis_cache_primary_connection_string" {
  description = "The primary connection string of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].primary_connection_string : null
  sensitive   = true
}

output "redis_cache_secondary_connection_string" {
  description = "The secondary connection string of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].secondary_connection_string : null
  sensitive   = true
}

output "redis_cache_primary_access_key" {
  description = "The primary access key for the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].primary_access_key : null
  sensitive   = true
}

output "redis_cache_secondary_access_key" {
  description = "The secondary access key for the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].secondary_access_key : null
  sensitive   = true
}

output "redis_cache_sku_name" {
  description = "The SKU name of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].sku_name : null
}

output "redis_cache_family" {
  description = "The SKU family of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].family : null
}

output "redis_cache_capacity" {
  description = "The capacity of the Redis Cache"
  value       = var.enabled ? azurerm_redis_cache.this[0].capacity : null
}

output "redis_version" {
  description = "The Redis version"
  value       = var.enabled ? azurerm_redis_cache.this[0].redis_version : null
}

output "redis_cache_private_static_ip_address" {
  description = "The static IP address of the Redis Cache when deployed into a Virtual Network"
  value       = var.enabled && var.subnet_id != null ? azurerm_redis_cache.this[0].private_static_ip_address : null
}

# Identity outputs
output "redis_cache_identity" {
  description = "The identity block of the Redis Cache"
  value       = var.enabled && var.identity_type != null ? azurerm_redis_cache.this[0].identity : null
}

output "redis_cache_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity for the Redis Cache"
  value       = var.enabled && var.identity_type != null ? try(azurerm_redis_cache.this[0].identity[0].principal_id, null) : null
}

output "redis_cache_tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity for the Redis Cache"
  value       = var.enabled && var.identity_type != null ? try(azurerm_redis_cache.this[0].identity[0].tenant_id, null) : null
}

# Private Endpoint outputs
output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = var.enabled && var.create_private_endpoint ? azurerm_private_endpoint.this[0].id : null
}

output "private_endpoint_name" {
  description = "The name of the private endpoint"
  value       = var.enabled && var.create_private_endpoint ? azurerm_private_endpoint.this[0].name : null
}

output "private_endpoint_private_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = var.enabled && var.create_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
}

# Labels and Tags
output "tags" {
  description = "The tags applied to the Redis Cache"
  value       = module.label.tags
}

output "context" {
  description = "Exported context for use by other modules"
  value       = module.label.context
}
