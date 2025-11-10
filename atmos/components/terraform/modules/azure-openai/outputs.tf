output "cognitive_account_id" {
  description = "The ID of the Azure OpenAI Service (Cognitive Account)"
  value       = var.enabled ? azurerm_cognitive_account.this[0].id : null
}

output "cognitive_account_name" {
  description = "The name of the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].name : null
}

output "cognitive_account_endpoint" {
  description = "The endpoint used to connect to the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].endpoint : null
}

output "cognitive_account_location" {
  description = "The location of the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].location : null
}

output "cognitive_account_resource_group_name" {
  description = "The name of the resource group in which the Azure OpenAI Service was created"
  value       = var.enabled ? azurerm_cognitive_account.this[0].resource_group_name : null
}

output "cognitive_account_kind" {
  description = "The kind of the Cognitive Account (OpenAI)"
  value       = var.enabled ? azurerm_cognitive_account.this[0].kind : null
}

output "cognitive_account_sku_name" {
  description = "The SKU name of the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].sku_name : null
}

output "custom_subdomain_name" {
  description = "The custom subdomain name of the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].custom_subdomain_name : null
}

# Security and Configuration Outputs
output "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  value       = var.enabled ? azurerm_cognitive_account.this[0].public_network_access_enabled : null
}

# Managed Identity Outputs
output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity"
  value       = var.enabled && var.identity_type != null ? azurerm_cognitive_account.this[0].identity[0].principal_id : null
}

output "identity_tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity"
  value       = var.enabled && var.identity_type != null ? azurerm_cognitive_account.this[0].identity[0].tenant_id : null
}

# Access Keys (Sensitive)
output "primary_access_key" {
  description = "The primary access key for the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].primary_access_key : null
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Azure OpenAI Service"
  value       = var.enabled ? azurerm_cognitive_account.this[0].secondary_access_key : null
  sensitive   = true
}

# Model Deployments
output "model_deployments" {
  description = "Map of deployed AI models and their metadata"
  value = var.enabled ? {
    for k, v in azurerm_cognitive_deployment.deployments : k => {
      id                   = v.id
      name                 = v.name
      cognitive_account_id = v.cognitive_account_id
      model_name           = v.model[0].name
      model_version        = v.model[0].version
      scale_type           = v.scale[0].type
      scale_capacity       = v.scale[0].capacity
    }
  } : {}
}

# Labels and Tags
output "tags" {
  description = "The tags applied to the Azure OpenAI Service"
  value       = module.label.tags
}

output "context" {
  description = "Exported context for use by other modules"
  value       = module.label.context
}
