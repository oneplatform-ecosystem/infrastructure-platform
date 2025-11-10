####################
# Container Registry Outputs
####################

output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = var.enabled ? azurerm_container_registry.this[0].id : ""
}

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = var.enabled ? azurerm_container_registry.this[0].name : ""
}

output "login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = var.enabled ? azurerm_container_registry.this[0].login_server : ""
}

output "admin_username" {
  description = "The Username associated with the Container Registry Admin account"
  value       = var.enabled && var.admin_enabled ? azurerm_container_registry.this[0].admin_username : ""
  sensitive   = true
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account"
  value       = var.enabled && var.admin_enabled ? azurerm_container_registry.this[0].admin_password : ""
  sensitive   = true
}

output "identity_principal_id" {
  description = "The Principal ID associated with this Managed Service Identity"
  value       = var.enabled && var.identity_type != null ? azurerm_container_registry.this[0].identity[0].principal_id : ""
}

output "identity_tenant_id" {
  description = "The Tenant ID associated with this Managed Service Identity"
  value       = var.enabled && var.identity_type != null ? azurerm_container_registry.this[0].identity[0].tenant_id : ""
}

output "sku" {
  description = "The SKU name of the container registry"
  value       = var.enabled ? azurerm_container_registry.this[0].sku : ""
}

output "resource_group_name" {
  description = "The name of the resource group in which the Container Registry was created"
  value       = var.enabled ? azurerm_container_registry.this[0].resource_group_name : ""
}

output "location" {
  description = "The Azure Region where the Container Registry exists"
  value       = var.enabled ? azurerm_container_registry.this[0].location : ""
}

output "scope_map_ids" {
  description = "Map of scope map names to their IDs"
  value       = var.enabled ? { for k, v in azurerm_container_registry_scope_map.this : k => v.id } : {}
}

output "token_ids" {
  description = "Map of token names to their IDs"
  value       = var.enabled ? { for k, v in azurerm_container_registry_token.this : k => v.id } : {}
}

output "webhook_ids" {
  description = "Map of webhook names to their IDs"
  value       = var.enabled ? { for k, v in azurerm_container_registry_webhook.this : k => v.id } : {}
}

output "tags" {
  description = "Tags applied to the Container Registry"
  value       = var.enabled ? azurerm_container_registry.this[0].tags : {}
}

output "context" {
  description = "Exported context from label module for use by other modules"
  value       = module.label.context
}
