# PostgreSQL Server Outputs
output "server_id" {
  description = "The ID of the PostgreSQL Flexible Server"
  value       = var.enabled ? azurerm_postgresql_flexible_server.this[0].id : ""
}

output "server_name" {
  description = "The name of the PostgreSQL Flexible Server"
  value       = var.enabled ? azurerm_postgresql_flexible_server.this[0].name : ""
}

output "server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server"
  value       = var.enabled ? azurerm_postgresql_flexible_server.this[0].fqdn : ""
}

output "server_public_network_access_enabled" {
  description = "Is public network access enabled for the PostgreSQL Flexible Server"
  value       = var.enabled ? azurerm_postgresql_flexible_server.this[0].public_network_access_enabled : false
}

output "server_identity" {
  description = "The identity block of the PostgreSQL Flexible Server"
  value       = var.enabled && var.identity_type != null ? azurerm_postgresql_flexible_server.this[0].identity : null
}

# Database Outputs
output "database_ids" {
  description = "Map of database IDs"
  value = var.enabled ? {
    for k, v in azurerm_postgresql_flexible_server_database.this : k => v.id
  } : {}
}

output "database_names" {
  description = "Map of database names"
  value = var.enabled ? {
    for k, v in azurerm_postgresql_flexible_server_database.this : k => v.name
  } : {}
}

# Connection Strings
output "connection_string" {
  description = "The connection string for the PostgreSQL Flexible Server (without password)"
  value       = var.enabled ? "postgresql://${var.administrator_login}@${azurerm_postgresql_flexible_server.this[0].fqdn}:5432/postgres?sslmode=require" : ""
  sensitive   = true
}

output "jdbc_connection_string" {
  description = "JDBC connection string for the PostgreSQL Flexible Server (without password)"
  value       = var.enabled ? "jdbc:postgresql://${azurerm_postgresql_flexible_server.this[0].fqdn}:5432/postgres?sslmode=require&user=${var.administrator_login}" : ""
  sensitive   = true
}

output "python_connection_string" {
  description = "Python (psycopg2) connection string for the PostgreSQL Flexible Server (without password)"
  value       = var.enabled ? "host=${azurerm_postgresql_flexible_server.this[0].fqdn} port=5432 dbname=postgres user=${var.administrator_login} sslmode=require" : ""
  sensitive   = true
}

output "dotnet_connection_string" {
  description = ".NET (Npgsql) connection string for the PostgreSQL Flexible Server (without password)"
  value       = var.enabled ? "Host=${azurerm_postgresql_flexible_server.this[0].fqdn};Port=5432;Database=postgres;Username=${var.administrator_login};SSL Mode=Require;" : ""
  sensitive   = true
}

# Firewall Rules
output "firewall_rules" {
  description = "Map of created firewall rules"
  value = var.enabled ? {
    for k, v in azurerm_postgresql_flexible_server_firewall_rule.this : k => {
      id               = v.id
      name             = v.name
      start_ip_address = v.start_ip_address
      end_ip_address   = v.end_ip_address
    }
  } : {}
}

# Server Configurations
output "server_configurations" {
  description = "Map of applied server configurations"
  value = var.enabled ? {
    for k, v in azurerm_postgresql_flexible_server_configuration.this : k => {
      id    = v.id
      name  = v.name
      value = v.value
    }
  } : {}
}

# Azure AD Administrator
output "azuread_administrator_id" {
  description = "The ID of the Azure AD administrator"
  value       = var.enabled && var.azuread_administrator != null ? azurerm_postgresql_flexible_server_active_directory_administrator.this[0].id : ""
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
