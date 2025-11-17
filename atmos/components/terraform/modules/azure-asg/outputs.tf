output "id" {
  description = "The ID of the Application Security Group"
  value       = var.enabled ? azurerm_application_security_group.this[0].id : null
}

output "name" {
  description = "The name of the Application Security Group"
  value       = var.enabled ? azurerm_application_security_group.this[0].name : null
}

output "location" {
  description = "The Azure Region where the Application Security Group exists"
  value       = var.enabled ? azurerm_application_security_group.this[0].location : null
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Application Security Group exists"
  value       = var.enabled ? azurerm_application_security_group.this[0].resource_group_name : null
}

output "asg_id" {
  description = "The ID of the Application Security Group (alias for id)"
  value       = var.enabled ? azurerm_application_security_group.this[0].id : null
}
