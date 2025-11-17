output "id" {
  description = "The ID of the Data Factory"
  value       = var.enabled ? azurerm_data_factory.this[0].id : null
}

output "name" {
  description = "The name of the Data Factory"
  value       = var.enabled ? azurerm_data_factory.this[0].name : null
}

output "location" {
  description = "The Azure Region where the Data Factory exists"
  value       = var.enabled ? azurerm_data_factory.this[0].location : null
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Data Factory exists"
  value       = var.enabled ? azurerm_data_factory.this[0].resource_group_name : null
}

output "datafactory_id" {
  description = "The ID of the Data Factory (alias for id)"
  value       = var.enabled ? azurerm_data_factory.this[0].id : null
}

output "identity" {
  description = "The Managed Identity block of the Data Factory"
  value       = var.enabled && var.identity_type != null ? azurerm_data_factory.this[0].identity : null
}

output "principal_id" {
  description = "The Principal ID associated with the Managed Identity of the Data Factory"
  value       = var.enabled && var.identity_type != null ? try(azurerm_data_factory.this[0].identity[0].principal_id, null) : null
}

output "tenant_id" {
  description = "The Tenant ID associated with the Managed Identity of the Data Factory"
  value       = var.enabled && var.identity_type != null ? try(azurerm_data_factory.this[0].identity[0].tenant_id, null) : null
}

output "tags" {
  description = "The tags assigned to the Data Factory"
  value       = var.enabled ? azurerm_data_factory.this[0].tags : null
}
