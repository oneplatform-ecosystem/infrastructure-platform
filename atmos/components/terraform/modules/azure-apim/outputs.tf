output "api_management_id" {
  description = "The ID of the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].id : null
}

output "api_management_name" {
  description = "The name of the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].name : null
}

output "gateway_url" {
  description = "The URL of the Gateway for the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].gateway_url : null
}

output "gateway_regional_url" {
  description = "The regional URL of the Gateway for the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].gateway_regional_url : null
}

output "management_api_url" {
  description = "The URL for the Management API associated with the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].management_api_url : null
}

output "portal_url" {
  description = "The URL for the Publisher Portal associated with the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].portal_url : null
}

output "developer_portal_url" {
  description = "The URL for the Developer Portal associated with the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].developer_portal_url : null
}

output "scm_url" {
  description = "The URL for the SCM (Source Code Management) endpoint associated with the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].scm_url : null
}

output "public_ip_addresses" {
  description = "The Public IP addresses of the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].public_ip_addresses : null
}

output "private_ip_addresses" {
  description = "The Private IP addresses of the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].private_ip_addresses : null
}

output "tenant_access_primary_key" {
  description = "The primary access key for the tenant access information"
  value       = var.enabled ? try(azurerm_api_management.this[0].tenant_access[0].primary_key, null) : null
  sensitive   = true
}

output "tenant_access_secondary_key" {
  description = "The secondary access key for the tenant access information"
  value       = var.enabled ? try(azurerm_api_management.this[0].tenant_access[0].secondary_key, null) : null
  sensitive   = true
}

output "tenant_access_tenant_id" {
  description = "The Tenant ID for the tenant access information"
  value       = var.enabled ? try(azurerm_api_management.this[0].tenant_access[0].tenant_id, null) : null
}

output "sku_name" {
  description = "The SKU name of the API Management Service"
  value       = var.enabled ? var.sku_name : null
}

output "capacity" {
  description = "The capacity of the API Management Service"
  value       = var.enabled ? var.capacity : null
}

output "location" {
  description = "The location of the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].location : null
}

output "additional_locations" {
  description = "Additional locations of the API Management Service"
  value       = var.enabled ? azurerm_api_management.this[0].additional_location : null
}

# Identity outputs
output "identity" {
  description = "The identity block of the API Management Service"
  value       = var.enabled && var.identity_type != null ? azurerm_api_management.this[0].identity : null
}

output "principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity for the API Management Service"
  value       = var.enabled && var.identity_type != null ? try(azurerm_api_management.this[0].identity[0].principal_id, null) : null
}

output "tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity for the API Management Service"
  value       = var.enabled && var.identity_type != null ? try(azurerm_api_management.this[0].identity[0].tenant_id, null) : null
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
  description = "The tags applied to the API Management Service"
  value       = module.label.tags
}

output "context" {
  description = "Exported context for use by other modules"
  value       = module.label.context
}
