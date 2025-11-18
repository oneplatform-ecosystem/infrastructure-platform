####################
# Container App Environment Outputs
####################

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].id : ""
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].name : ""
}

output "default_domain" {
  description = "The default publicly resolvable name of the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].default_domain : ""
}

output "static_ip_address" {
  description = "The Static IP Address of the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].static_ip_address : ""
}

output "docker_bridge_cidr" {
  description = "The Docker bridge CIDR for the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].docker_bridge_cidr : ""
}

output "platform_reserved_cidr" {
  description = "The platform reserved CIDR for the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].platform_reserved_cidr : ""
}

output "platform_reserved_dns_ip_address" {
  description = "The platform reserved DNS IP address for the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].platform_reserved_dns_ip_address : ""
}

output "resource_group_name" {
  description = "The name of the resource group in which the Container App Environment was created"
  value       = var.enabled ? azurerm_container_app_environment.this[0].resource_group_name : ""
}

output "location" {
  description = "The Azure Region where the Container App Environment exists"
  value       = var.enabled ? azurerm_container_app_environment.this[0].location : ""
}

output "tags" {
  description = "Tags applied to the Container App Environment"
  value       = var.enabled ? azurerm_container_app_environment.this[0].tags : {}
}

output "context" {
  description = "Exported context from label module for use by other modules"
  value       = module.label.context
}
