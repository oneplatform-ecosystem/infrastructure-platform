# Virtual Machine Outputs
output "vm_id" {
  description = "The ID of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id) : null
}

output "vm_name" {
  description = "The name of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].name : azurerm_windows_virtual_machine.this[0].name) : null
}

output "vm_computer_name" {
  description = "The computer name of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].computer_name : azurerm_windows_virtual_machine.this[0].computer_name) : null
}

output "vm_size" {
  description = "The size of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].size : azurerm_windows_virtual_machine.this[0].size) : null
}

output "vm_location" {
  description = "The location of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].location : azurerm_windows_virtual_machine.this[0].location) : null
}

output "vm_resource_group_name" {
  description = "The resource group name of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].resource_group_name : azurerm_windows_virtual_machine.this[0].resource_group_name) : null
}

output "vm_admin_username" {
  description = "The admin username of the Virtual Machine"
  value       = var.enabled ? var.admin_username : null
}

output "vm_private_ip_address" {
  description = "The primary private IP address of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].private_ip_address : azurerm_windows_virtual_machine.this[0].private_ip_address) : null
}

output "vm_private_ip_addresses" {
  description = "A list of private IP addresses of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].private_ip_addresses : azurerm_windows_virtual_machine.this[0].private_ip_addresses) : null
}

output "vm_public_ip_address" {
  description = "The primary public IP address of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].public_ip_address : azurerm_windows_virtual_machine.this[0].public_ip_address) : null
}

output "vm_public_ip_addresses" {
  description = "A list of public IP addresses of the Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].public_ip_addresses : azurerm_windows_virtual_machine.this[0].public_ip_addresses) : null
}

output "vm_virtual_machine_id" {
  description = "A 128-bit identifier which uniquely identifies this Virtual Machine"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].virtual_machine_id : azurerm_windows_virtual_machine.this[0].virtual_machine_id) : null
}

# Network Interface Outputs
output "network_interface_id" {
  description = "The ID of the Network Interface"
  value       = var.enabled ? azurerm_network_interface.this[0].id : null
}

output "network_interface_name" {
  description = "The name of the Network Interface"
  value       = var.enabled ? azurerm_network_interface.this[0].name : null
}

output "network_interface_private_ip_address" {
  description = "The private IP address of the Network Interface"
  value       = var.enabled ? azurerm_network_interface.this[0].private_ip_address : null
}

output "network_interface_private_ip_addresses" {
  description = "The private IP addresses of the Network Interface"
  value       = var.enabled ? azurerm_network_interface.this[0].private_ip_addresses : null
}

output "network_interface_mac_address" {
  description = "The MAC address of the Network Interface"
  value       = var.enabled ? azurerm_network_interface.this[0].mac_address : null
}

# Public IP Outputs
output "public_ip_id" {
  description = "The ID of the Public IP"
  value       = var.enabled && var.create_public_ip ? azurerm_public_ip.this[0].id : null
}

output "public_ip_name" {
  description = "The name of the Public IP"
  value       = var.enabled && var.create_public_ip ? azurerm_public_ip.this[0].name : null
}

output "public_ip_address" {
  description = "The IP address value that was allocated"
  value       = var.enabled && var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "public_ip_fqdn" {
  description = "The FQDN of the Public IP"
  value       = var.enabled && var.create_public_ip ? azurerm_public_ip.this[0].fqdn : null
}

# OS Disk Outputs
output "os_disk_id" {
  description = "The ID of the OS disk"
  value       = var.enabled ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].os_disk[0].name : azurerm_windows_virtual_machine.this[0].os_disk[0].name) : null
}

output "os_disk_name" {
  description = "The name of the OS disk"
  value       = var.enabled ? local.os_disk_name : null
}

# Data Disk Outputs
output "data_disk_ids" {
  description = "Map of data disk names to their IDs"
  value       = var.enabled ? { for k, v in azurerm_managed_disk.this : k => v.id } : {}
}

output "data_disk_names" {
  description = "Map of data disk keys to their names"
  value       = var.enabled ? { for k, v in azurerm_managed_disk.this : k => v.name } : {}
}

# Identity Outputs
output "identity" {
  description = "The identity block of the Virtual Machine"
  value = var.enabled && var.identity_type != null ? (
    var.os_type == "Linux" ?
    azurerm_linux_virtual_machine.this[0].identity :
    azurerm_windows_virtual_machine.this[0].identity
  ) : null
}

output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity for the Virtual Machine"
  value = var.enabled && var.identity_type != null ? (
    var.os_type == "Linux" ?
    try(azurerm_linux_virtual_machine.this[0].identity[0].principal_id, null) :
    try(azurerm_windows_virtual_machine.this[0].identity[0].principal_id, null)
  ) : null
}

output "identity_tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity for the Virtual Machine"
  value = var.enabled && var.identity_type != null ? (
    var.os_type == "Linux" ?
    try(azurerm_linux_virtual_machine.this[0].identity[0].tenant_id, null) :
    try(azurerm_windows_virtual_machine.this[0].identity[0].tenant_id, null)
  ) : null
}

# Labels and Tags
output "tags" {
  description = "The tags applied to the Virtual Machine"
  value       = module.label.tags
}

output "context" {
  description = "Exported context for use by other modules"
  value       = module.label.context
}
