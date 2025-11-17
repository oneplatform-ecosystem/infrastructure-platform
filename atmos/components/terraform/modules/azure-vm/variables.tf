variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "location" {
  description = "The Azure Region where the Virtual Machine should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Virtual Machine"
  type        = string
}

variable "vm_name" {
  description = "Custom name for the Virtual Machine. If not specified, the module will use the ID from the label module"
  type        = string
  default     = null
}

variable "os_type" {
  description = "The type of OS for the Virtual Machine. Possible values are Linux and Windows"
  type        = string
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "The os_type must be either Linux or Windows."
  }
}

# VM Configuration
variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "computer_name" {
  description = "The hostname of the Virtual Machine. If not specified, defaults to vm_name"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "The admin username for the Virtual Machine"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The admin password for the Virtual Machine. Required for Windows VMs and Linux VMs when disable_password_authentication is false"
  type        = string
  default     = null
  sensitive   = true
}

# Linux-specific variables
variable "disable_password_authentication" {
  description = "Should password authentication be disabled for Linux VMs? Requires admin_ssh_keys to be set"
  type        = bool
  default     = true
}

variable "admin_ssh_keys" {
  description = "A list of SSH public keys for Linux VM authentication"
  type        = list(string)
  default     = []
}

variable "linux_patch_mode" {
  description = "Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are AutomaticByPlatform and ImageDefault"
  type        = string
  default     = "ImageDefault"
  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.linux_patch_mode)
    error_message = "The linux_patch_mode must be either AutomaticByPlatform or ImageDefault."
  }
}

# Windows-specific variables
variable "enable_automatic_updates" {
  description = "Specifies if Automatic Updates are enabled for the Windows Virtual Machine"
  type        = bool
  default     = true
}

variable "windows_patch_mode" {
  description = "Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform"
  type        = string
  default     = "AutomaticByOS"
  validation {
    condition     = contains(["Manual", "AutomaticByOS", "AutomaticByPlatform"], var.windows_patch_mode)
    error_message = "The windows_patch_mode must be one of: Manual, AutomaticByOS, AutomaticByPlatform."
  }
}

variable "timezone" {
  description = "Specifies the Time Zone which should be used by the Windows Virtual Machine"
  type        = string
  default     = null
}

# Common VM Configuration
variable "patch_assessment_mode" {
  description = "Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault"
  type        = string
  default     = "ImageDefault"
  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_assessment_mode)
    error_message = "The patch_assessment_mode must be either AutomaticByPlatform or ImageDefault."
  }
}

variable "provision_vm_agent" {
  description = "Should the Azure VM Agent be provisioned on this Virtual Machine?"
  type        = bool
  default     = true
}

variable "allow_extension_operations" {
  description = "Should Extension Operations be allowed on this Virtual Machine?"
  type        = bool
  default     = true
}

variable "license_type" {
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server for Windows, RHEL_BYOS and SLES_BYOS for Linux"
  type        = string
  default     = null
}

variable "custom_data" {
  description = "The Base64-encoded custom data which should be used for this Virtual Machine"
  type        = string
  default     = null
}

# Source Image Configuration
variable "source_image_reference" {
  description = "Source image reference for the Virtual Machine"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "The ID of the Image which this Virtual Machine should be created from. Mutually exclusive with source_image_reference"
  type        = string
  default     = null
}

# Plan (for marketplace images)
variable "plan" {
  description = "Plan block for marketplace images"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

# OS Disk Configuration
variable "os_disk_name" {
  description = "Custom name for the OS disk. If not specified, defaults to {vm_name}-osdisk"
  type        = string
  default     = null
}

variable "os_disk_caching" {
  description = "The type of caching to use for the OS disk. Possible values are None, ReadOnly and ReadWrite"
  type        = string
  default     = "ReadWrite"
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "The os_disk_caching must be one of: None, ReadOnly, ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "The type of storage account to use for the OS disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS"
  type        = string
  default     = "Premium_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk_storage_account_type)
    error_message = "The os_disk_storage_account_type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS."
  }
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in gigabytes"
  type        = number
  default     = null
}

# Data Disks Configuration
variable "data_disks" {
  description = "Map of data disks to attach to the VM"
  type = map(object({
    lun                  = number
    disk_size_gb         = number
    storage_account_type = string
    caching              = string
    create_option        = string
  }))
  default = {}
}

# Network Configuration
variable "subnet_id" {
  description = "The ID of the Subnet where this Network Interface should be located in"
  type        = string
}

variable "nic_name" {
  description = "Custom name for the Network Interface. If not specified, defaults to {vm_name}-nic"
  type        = string
  default     = null
}

variable "private_ip_address_allocation" {
  description = "The allocation method for the private IP address. Possible values are Dynamic and Static"
  type        = string
  default     = "Dynamic"
  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "The private_ip_address_allocation must be either Dynamic or Static."
  }
}

variable "private_ip_address" {
  description = "The static IP address to assign to the Network Interface. Required when private_ip_address_allocation is Static"
  type        = string
  default     = null
}

variable "enable_accelerated_networking" {
  description = "Should Accelerated Networking be enabled? Defaults to false"
  type        = bool
  default     = false
}

variable "enable_ip_forwarding" {
  description = "Should IP Forwarding be enabled? Defaults to false"
  type        = bool
  default     = false
}

variable "network_security_group_id" {
  description = "The ID of the Network Security Group to associate with the Network Interface"
  type        = string
  default     = null
}

variable "application_security_group_id" {
  description = "The ID of the Application Security Group to associate with the Network Interface"
  type        = string
  default     = null
}

# Public IP Configuration
variable "create_public_ip" {
  description = "Whether to create a public IP address for the VM"
  type        = bool
  default     = false
}

variable "public_ip_name" {
  description = "Custom name for the Public IP. If not specified, defaults to {vm_name}-pip"
  type        = string
  default     = null
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP address. Possible values are Static and Dynamic"
  type        = string
  default     = "Static"
  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "The public_ip_allocation_method must be either Static or Dynamic."
  }
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Possible values are Basic and Standard"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "The public_ip_sku must be either Basic or Standard."
  }
}

# Availability Configuration
variable "availability_set_id" {
  description = "The ID of the Availability Set in which the Virtual Machine should exist"
  type        = string
  default     = null
}

variable "zone" {
  description = "The Availability Zone in which this Virtual Machine should be located. Conflicts with availability_set_id"
  type        = string
  default     = null
}

variable "zones" {
  description = "A list of Availability Zones in which this Public IP should be located"
  type        = list(string)
  default     = null
}

# Security Configuration
variable "encryption_at_host_enabled" {
  description = "Should all disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  type        = bool
  default     = false
}

variable "secure_boot_enabled" {
  description = "Specifies if Secure Boot should be enabled on the Virtual Machine"
  type        = bool
  default     = false
}

variable "vtpm_enabled" {
  description = "Specifies if vTPM should be enabled on the Virtual Machine"
  type        = bool
  default     = false
}

# Boot Diagnostics
variable "boot_diagnostics_storage_account_uri" {
  description = "The Storage Account URI to use for boot diagnostics"
  type        = string
  default     = null
}

# Managed Identity
variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the Virtual Machine. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned"
  type        = string
  default     = null
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "The identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned to the Virtual Machine"
  type        = list(string)
  default     = null
}

# Label module variables
variable "namespace" {
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for"
  type        = string
  default     = null
}

variable "environment" {
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  type        = string
  default     = null
}

variable "stage" {
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
  type        = string
  default     = null
}

variable "name" {
  description = "ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'"
  type        = string
  default     = null
}

variable "attributes" {
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id` in the order they appear in the list"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to be used between ID elements"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`)"
  type        = map(string)
  default     = {}
}

variable "regex_replace_chars" {
  description = "Terraform regular expression (regex) string. Characters matching the regex will be removed from the ID elements"
  type        = string
  default     = null
}

variable "label_order" {
  description = "The order in which the labels (ID elements) appear in the id"
  type        = list(string)
  default     = null
}

variable "label_key_case" {
  description = "Controls the letter case of the tags keys (label names) for tags generated by this module"
  type        = string
  default     = null
}

variable "label_value_case" {
  description = "Controls the letter case of the tags values for tags generated by this module"
  type        = string
  default     = null
}

variable "id_length_limit" {
  description = "Limit `id` to this many characters (minimum 6)"
  type        = number
  default     = null
}
