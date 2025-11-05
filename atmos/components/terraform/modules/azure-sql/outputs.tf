# SQL Server Outputs
output "sql_server_id" {
  description = "The ID of the SQL Server"
  value       = var.enabled ? azurerm_mssql_server.this[0].id : ""
}

output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = var.enabled ? azurerm_mssql_server.this[0].name : ""
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = var.enabled ? azurerm_mssql_server.this[0].fully_qualified_domain_name : ""
}

output "sql_server_identity" {
  description = "The identity block of the SQL Server"
  value       = var.enabled && var.identity_type != null ? azurerm_mssql_server.this[0].identity : null
}

# Database Outputs
output "database_id" {
  description = "The ID of the SQL Database"
  value       = var.enabled ? azurerm_mssql_database.this[0].id : ""
}

output "database_name" {
  description = "The name of the SQL Database"
  value       = var.enabled ? azurerm_mssql_database.this[0].name : ""
}

# Connection Strings
output "connection_string" {
  description = "The connection string for the SQL Database (without password)"
  value       = var.enabled ? "Server=tcp:${azurerm_mssql_server.this[0].fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.this[0].name};Persist Security Info=False;User ID=${var.administrator_login};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" : ""
  sensitive   = true
}

output "jdbc_connection_string" {
  description = "JDBC connection string for the SQL Database (without password)"
  value       = var.enabled ? "jdbc:sqlserver://${azurerm_mssql_server.this[0].fully_qualified_domain_name}:1433;database=${azurerm_mssql_database.this[0].name};user=${var.administrator_login}@${azurerm_mssql_server.this[0].name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" : ""
  sensitive   = true
}

output "odbc_connection_string" {
  description = "ODBC connection string for the SQL Database (without password)"
  value       = var.enabled ? "Driver={ODBC Driver 17 for SQL Server};Server=tcp:${azurerm_mssql_server.this[0].fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.this[0].name};Uid=${var.administrator_login};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;" : ""
  sensitive   = true
}

# Firewall Rules
output "firewall_rules" {
  description = "Map of created firewall rules"
  value = var.enabled ? {
    for k, v in azurerm_mssql_firewall_rule.this : k => {
      id               = v.id
      name             = v.name
      start_ip_address = v.start_ip_address
      end_ip_address   = v.end_ip_address
    }
  } : {}
}

# Virtual Network Rules
output "virtual_network_rules" {
  description = "Map of created virtual network rules"
  value = var.enabled ? {
    for k, v in azurerm_mssql_virtual_network_rule.this : k => {
      id        = v.id
      name      = v.name
      subnet_id = v.subnet_id
    }
  } : {}
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
