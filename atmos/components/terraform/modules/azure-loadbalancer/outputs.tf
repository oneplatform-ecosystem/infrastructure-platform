output "id" {
  description = "The ID of the Load Balancer"
  value       = var.enabled ? azurerm_lb.this[0].id : ""
}

output "name" {
  description = "The name of the Load Balancer"
  value       = var.enabled ? azurerm_lb.this[0].name : ""
}

output "frontend_ip_configuration" {
  description = "The frontend IP configuration of the Load Balancer"
  value       = var.enabled ? azurerm_lb.this[0].frontend_ip_configuration : []
}

output "frontend_ip_configuration_ids" {
  description = "Map of frontend IP configuration names to their IDs"
  value = var.enabled ? {
    for config in azurerm_lb.this[0].frontend_ip_configuration :
    config.name => config.id
  } : {}
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their IDs"
  value = var.enabled ? {
    for k, v in azurerm_lb_backend_address_pool.this : k => v.id
  } : {}
}

output "probe_ids" {
  description = "Map of probe names to their IDs"
  value = var.enabled ? {
    for k, v in azurerm_lb_probe.this : k => v.id
  } : {}
}

output "load_balancing_rule_ids" {
  description = "Map of load balancing rule names to their IDs"
  value = var.enabled ? {
    for k, v in azurerm_lb_rule.this : k => v.id
  } : {}
}

output "nat_rule_ids" {
  description = "Map of NAT rule names to their IDs"
  value = var.enabled ? {
    for k, v in azurerm_lb_nat_rule.this : k => v.id
  } : {}
}

output "nat_pool_ids" {
  description = "Map of NAT pool names to their IDs"
  value = var.enabled ? {
    for k, v in azurerm_lb_nat_pool.this : k => v.id
  } : {}
}

output "outbound_rule_ids" {
  description = "Map of outbound rule names to their IDs"
  value = var.enabled ? {
    for k, v in azurerm_lb_outbound_rule.this : k => v.id
  } : {}
}

output "private_ip_address" {
  description = "The first private IP address assigned to the load balancer in frontend_ip_configuration blocks, if any"
  value       = var.enabled ? azurerm_lb.this[0].private_ip_address : ""
}

output "private_ip_addresses" {
  description = "The list of private IP addresses assigned to the load balancer in frontend_ip_configuration blocks, if any"
  value       = var.enabled ? azurerm_lb.this[0].private_ip_addresses : []
}

output "label_id" {
  description = "The generated ID from the label module"
  value       = module.label.id
}

output "tags" {
  description = "The tags applied to the Load Balancer"
  value       = module.label.tags
}

output "context" {
  description = "Exported context from the label module for use by other modules"
  value       = module.label.context
}
