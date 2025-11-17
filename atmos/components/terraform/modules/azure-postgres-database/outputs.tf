# Database Outputs
output "database_id" {
  description = "The ID of the PostgreSQL Flexible Server Database"
  value       = var.enabled ? azurerm_postgresql_flexible_server_database.this[0].id : ""
}

output "database_name" {
  description = "The name of the PostgreSQL Flexible Server Database"
  value       = var.enabled ? azurerm_postgresql_flexible_server_database.this[0].name : ""
}

output "database_collation" {
  description = "The collation of the PostgreSQL Flexible Server Database"
  value       = var.enabled ? azurerm_postgresql_flexible_server_database.this[0].collation : ""
}

output "database_charset" {
  description = "The charset of the PostgreSQL Flexible Server Database"
  value       = var.enabled ? azurerm_postgresql_flexible_server_database.this[0].charset : ""
}

output "server_id" {
  description = "The ID of the PostgreSQL Flexible Server"
  value       = var.server_id
}

# Label Outputs
output "tags" {
  description = "The tags applied to the resources"
  value       = module.label.tags
}

output "context" {
  description = "Exported context for use by other modules"
  value       = module.label.context
}

output "id" {
  description = "The generated ID from the label module"
  value       = module.label.id
}
