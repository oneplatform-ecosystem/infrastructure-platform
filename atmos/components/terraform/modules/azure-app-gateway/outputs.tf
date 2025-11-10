output "id" {
  description = "The ID of the Application Gateway"
  value       = var.enabled ? azurerm_application_gateway.this[0].id : null
}

output "name" {
  description = "The name of the Application Gateway"
  value       = var.enabled ? azurerm_application_gateway.this[0].name : null
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.enabled ? azurerm_application_gateway.this[0].resource_group_name : null
}

output "location" {
  description = "The Azure region where the Application Gateway is deployed"
  value       = var.enabled ? azurerm_application_gateway.this[0].location : null
}

output "backend_address_pool" {
  description = "Backend address pool configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].backend_address_pool : null
}

output "backend_http_settings" {
  description = "Backend HTTP settings configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].backend_http_settings : null
}

output "frontend_ip_configuration" {
  description = "Frontend IP configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].frontend_ip_configuration : null
}

output "frontend_port" {
  description = "Frontend port configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].frontend_port : null
}

output "gateway_ip_configuration" {
  description = "Gateway IP configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].gateway_ip_configuration : null
}

output "http_listener" {
  description = "HTTP listener configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].http_listener : null
}

output "request_routing_rule" {
  description = "Request routing rule configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].request_routing_rule : null
}

output "probe" {
  description = "Health probe configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].probe : null
}

output "ssl_certificate" {
  description = "SSL certificate configuration (sensitive data excluded)"
  value       = var.enabled ? azurerm_application_gateway.this[0].ssl_certificate : null
  sensitive   = true
}

output "identity" {
  description = "Managed identity configuration"
  value       = var.enabled ? azurerm_application_gateway.this[0].identity : null
}

output "tags" {
  description = "Tags applied to the Application Gateway"
  value       = module.label.tags
}

output "context" {
  description = "Context from the label module"
  value       = module.label.context
}
