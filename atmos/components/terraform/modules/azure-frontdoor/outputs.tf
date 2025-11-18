output "id" {
  description = "The ID of the Front Door Profile"
  value       = var.enabled ? azurerm_cdn_frontdoor_profile.this[0].id : null
}

output "name" {
  description = "The name of the Front Door Profile"
  value       = var.enabled ? azurerm_cdn_frontdoor_profile.this[0].name : null
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.enabled ? azurerm_cdn_frontdoor_profile.this[0].resource_group_name : null
}

output "sku_name" {
  description = "The SKU name of the Front Door Profile"
  value       = var.enabled ? azurerm_cdn_frontdoor_profile.this[0].sku_name : null
}

output "resource_guid" {
  description = "The resource GUID of the Front Door Profile"
  value       = var.enabled ? azurerm_cdn_frontdoor_profile.this[0].resource_guid : null
}

output "endpoints" {
  description = "Map of Front Door endpoints"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_endpoint.this : k => {
    id        = v.id
    name      = v.name
    host_name = v.host_name
    enabled   = v.enabled
  } } : {}
}

output "endpoint_host_names" {
  description = "Map of endpoint keys to their host names"
  value       = var.enabled ? { for k, v in azurerm_cdn_frontdoor_endpoint.this : k => v.host_name } : {}
}

output "origin_groups" {
  description = "Map of Front Door origin groups"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_origin_group.this : k => {
    id   = v.id
    name = v.name
  } } : {}
}

output "origins" {
  description = "Map of Front Door origins"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_origin.this : k => {
    id        = v.id
    name      = v.name
    host_name = v.host_name
  } } : {}
}

output "routes" {
  description = "Map of Front Door routes"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_route.this : k => {
    id                  = v.id
    name                = v.name
    enabled             = v.enabled
    patterns_to_match   = v.patterns_to_match
    supported_protocols = v.supported_protocols
  } } : {}
}

output "rule_sets" {
  description = "Map of Front Door rule sets"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_rule_set.this : k => {
    id   = v.id
    name = v.name
  } } : {}
}

output "rules" {
  description = "Map of Front Door rules"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_rule.this : k => {
    id    = v.id
    name  = v.name
    order = v.order
  } } : {}
}

output "custom_domains" {
  description = "Map of Front Door custom domains"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => {
    id        = v.id
    name      = v.name
    host_name = v.host_name
  } } : {}
}

output "security_policies" {
  description = "Map of Front Door security policies"
  value = var.enabled ? { for k, v in azurerm_cdn_frontdoor_security_policy.this : k => {
    id   = v.id
    name = v.name
  } } : {}
}

output "tags" {
  description = "Tags applied to the Front Door Profile"
  value       = module.label.tags
}

output "context" {
  description = "Context from the label module"
  value       = module.label.context
}
