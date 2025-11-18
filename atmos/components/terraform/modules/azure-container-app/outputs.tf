# Container App Environment Outputs
output "environment_id" {
  description = "The ID of the Container App Environment"
  value       = var.enabled && var.create_environment ? azurerm_container_app_environment.this[0].id : var.environment_id
}

output "environment_name" {
  description = "The name of the Container App Environment"
  value       = var.enabled && var.create_environment ? azurerm_container_app_environment.this[0].name : ""
}

output "environment_default_domain" {
  description = "The default domain of the Container App Environment"
  value       = var.enabled && var.create_environment ? azurerm_container_app_environment.this[0].default_domain : ""
}

output "environment_static_ip_address" {
  description = "The static IP address of the Container App Environment"
  value       = var.enabled && var.create_environment ? azurerm_container_app_environment.this[0].static_ip_address : ""
}

# Container App Outputs
output "container_app_id" {
  description = "The ID of the Container App"
  value       = var.enabled ? azurerm_container_app.this[0].id : ""
}

output "container_app_name" {
  description = "The name of the Container App"
  value       = var.enabled ? azurerm_container_app.this[0].name : ""
}

output "container_app_fqdn" {
  description = "The FQDN of the Container App's ingress"
  value       = var.enabled && var.ingress != null ? azurerm_container_app.this[0].ingress[0].fqdn : ""
}

output "container_app_latest_revision_name" {
  description = "The name of the latest Container Revision"
  value       = var.enabled ? azurerm_container_app.this[0].latest_revision_name : ""
}

output "container_app_latest_revision_fqdn" {
  description = "The FQDN of the latest revision of the Container App"
  value       = var.enabled ? azurerm_container_app.this[0].latest_revision_fqdn : ""
}

output "container_app_outbound_ip_addresses" {
  description = "The outbound IP addresses of the Container App"
  value       = var.enabled ? azurerm_container_app.this[0].outbound_ip_addresses : []
}

output "container_app_identity" {
  description = "The identity block of the Container App"
  value       = var.enabled && var.identity_type != null ? azurerm_container_app.this[0].identity : null
}

output "container_app_custom_domain_verification_id" {
  description = "The custom domain verification ID for the Container App"
  value       = var.enabled ? azurerm_container_app.this[0].custom_domain_verification_id : ""
  sensitive   = true
}

# Connection Information
output "container_app_url" {
  description = "The URL of the Container App (HTTPS)"
  value       = var.enabled && var.ingress != null ? "https://${azurerm_container_app.this[0].ingress[0].fqdn}" : ""
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
