output "cosmosdb_account_id" {
  description = "The ID of the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].id : null
}

output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].name : null
}

output "location" {
  description = "The location of the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].location : null
}

output "resource_group_name" {
  description = "The resource group name of the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].resource_group_name : null
}

output "endpoint" {
  description = "The endpoint used to connect to the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].endpoint : null
}

output "read_endpoints" {
  description = "A list of read endpoints available for this Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].read_endpoints : []
}

output "write_endpoints" {
  description = "A list of write endpoints available for this Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].write_endpoints : []
}

output "primary_key" {
  description = "The Primary key for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].primary_key : null
  sensitive   = true
}

output "secondary_key" {
  description = "The Secondary key for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].secondary_key : null
  sensitive   = true
}

output "primary_readonly_key" {
  description = "The Primary read-only key for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].primary_readonly_key : null
  sensitive   = true
}

output "secondary_readonly_key" {
  description = "The Secondary read-only key for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].secondary_readonly_key : null
  sensitive   = true
}

output "primary_sql_connection_string" {
  description = "The primary SQL connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].primary_sql_connection_string : null
  sensitive   = true
}

output "secondary_sql_connection_string" {
  description = "The secondary SQL connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].secondary_sql_connection_string : null
  sensitive   = true
}

output "primary_readonly_sql_connection_string" {
  description = "The primary read-only SQL connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].primary_readonly_sql_connection_string : null
  sensitive   = true
}

output "secondary_readonly_sql_connection_string" {
  description = "The secondary read-only SQL connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].secondary_readonly_sql_connection_string : null
  sensitive   = true
}

output "primary_mongodb_connection_string" {
  description = "The primary MongoDB connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].primary_mongodb_connection_string : null
  sensitive   = true
}

output "secondary_mongodb_connection_string" {
  description = "The secondary MongoDB connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].secondary_mongodb_connection_string : null
  sensitive   = true
}

output "primary_readonly_mongodb_connection_string" {
  description = "The primary read-only MongoDB connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].primary_readonly_mongodb_connection_string : null
  sensitive   = true
}

output "secondary_readonly_mongodb_connection_string" {
  description = "The secondary read-only MongoDB connection string for the Cosmos DB Account"
  value       = var.enabled ? azurerm_cosmosdb_account.this[0].secondary_readonly_mongodb_connection_string : null
  sensitive   = true
}

output "identity_principal_id" {
  description = "The Principal ID associated with the Managed Service Identity of the Cosmos DB Account"
  value       = var.enabled && var.identity_type != null ? azurerm_cosmosdb_account.this[0].identity[0].principal_id : null
}

output "identity_tenant_id" {
  description = "The Tenant ID associated with the Managed Service Identity of the Cosmos DB Account"
  value       = var.enabled && var.identity_type != null ? azurerm_cosmosdb_account.this[0].identity[0].tenant_id : null
}

output "identity_identity_ids" {
  description = "The list of User Managed Identity IDs assigned to the Cosmos DB Account"
  value       = var.enabled && var.identity_type != null ? azurerm_cosmosdb_account.this[0].identity[0].identity_ids : []
}

output "context" {
  description = "Exported context from the label module for use by other modules"
  value       = module.label.context
}

output "tags" {
  description = "The tags applied to the Cosmos DB Account"
  value       = module.label.tags
}
