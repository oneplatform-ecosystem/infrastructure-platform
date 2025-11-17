# General Variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the PostgreSQL Flexible Server"
  type        = string
}

variable "location" {
  description = "The Azure region where the PostgreSQL Flexible Server should exist"
  type        = string
}

# PostgreSQL Server Variables
variable "server_name" {
  description = "Custom name for the PostgreSQL Flexible Server. If not provided, will use the label module generated ID"
  type        = string
  default     = null
}

variable "postgres_version" {
  description = "The version of PostgreSQL to use. Valid values are 11, 12, 13, 14, 15, 16"
  type        = string
  default     = "16"
  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.postgres_version)
    error_message = "PostgreSQL version must be one of: 11, 12, 13, 14, 15, 16"
  }
}

variable "administrator_login" {
  description = "The administrator login name for the PostgreSQL Flexible Server"
  type        = string
  sensitive   = true
}

variable "administrator_password" {
  description = "The administrator login password for the PostgreSQL Flexible Server"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server. Format: tier_compute-family_cores (e.g., B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server in MB. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432"
  type        = number
  default     = 32768
  validation {
    condition = contains([
      32768, 65536, 131072, 262144, 524288,
      1048576, 2097152, 4194304, 8388608,
      16777216, 33554432
    ], var.storage_mb)
    error_message = "Storage MB must be one of the valid values: 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432"
  }
}

variable "backup_retention_days" {
  description = "The backup retention days for the PostgreSQL Flexible Server. Valid values are between 7 and 35 days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 7 and 35"
  }
}

variable "geo_redundant_backup_enabled" {
  description = "Should geo redundant backup be enabled?"
  type        = bool
  default     = false
}

variable "auto_grow_enabled" {
  description = "Should storage auto grow be enabled?"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Should public network access be enabled for this server?"
  type        = bool
  default     = false
}

variable "zone" {
  description = "The availability zone in which the PostgreSQL Flexible Server should be located. Possible values are 1, 2, 3"
  type        = string
  default     = null
}

# Authentication Configuration
variable "authentication_config" {
  description = "Authentication configuration for the PostgreSQL Flexible Server"
  type = object({
    active_directory_auth_enabled = optional(bool, false)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string)
  })
  default = null
}

# Customer Managed Key
variable "customer_managed_key_id" {
  description = "The ID of the Key Vault Key to use for customer managed key encryption"
  type        = string
  default     = null
}

variable "primary_user_assigned_identity_id" {
  description = "The ID of the primary User Assigned Identity for customer managed key encryption"
  type        = string
  default     = null
}

# High Availability Configuration
variable "high_availability_enabled" {
  description = "Should high availability be enabled?"
  type        = bool
  default     = false
}

variable "high_availability_mode" {
  description = "The high availability mode. Valid values are ZoneRedundant and SameZone"
  type        = string
  default     = "ZoneRedundant"
  validation {
    condition     = contains(["ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "High availability mode must be either ZoneRedundant or SameZone"
  }
}

variable "standby_availability_zone" {
  description = "The availability zone for the standby server when high availability is enabled"
  type        = string
  default     = null
}

# Identity Configuration
variable "identity_type" {
  description = "The type of Managed Service Identity. Possible values are SystemAssigned, UserAssigned"
  type        = string
  default     = null
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Identity type must be either SystemAssigned or UserAssigned"
  }
}

variable "identity_ids" {
  description = "A list of User Assigned Managed Identity IDs to be assigned to this PostgreSQL Flexible Server"
  type        = list(string)
  default     = null
}

# Maintenance Window
variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = null
}

# Server Configurations
variable "server_configurations" {
  description = "Map of PostgreSQL server configuration parameters. The key is the configuration name"
  type        = map(string)
  default     = {}
}

# Databases
variable "databases" {
  description = "Map of databases to create. The key is the database name"
  type = map(object({
    collation = optional(string, "en_US.utf8")
    charset   = optional(string, "UTF8")
  }))
  default = {}
}

# Firewall Rules
variable "firewall_rules" {
  description = "Map of firewall rules to create. The key is the rule name"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

# Azure AD Administrator
variable "azuread_administrator" {
  description = "Azure AD administrator configuration for the PostgreSQL Flexible Server"
  type = object({
    tenant_id      = string
    object_id      = string
    principal_name = string
    principal_type = string
  })
  default = null
}

# Label Module Variables
variable "namespace" {
  description = "ID element. Usually an abbreviation of your organization name"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element. Usually used to indicate the tenant"
  type        = string
  default     = null
}

variable "environment" {
  description = "ID element. Usually used for region (e.g. 'eus', 'weu')"
  type        = string
  default     = null
}

variable "stage" {
  description = "ID element. Usually used to indicate role (e.g. 'prod', 'dev')"
  type        = string
  default     = null
}

variable "name" {
  description = "ID element. Usually the component or solution name"
  type        = string
  default     = null
}

variable "attributes" {
  description = "ID element. Additional attributes to add to ID"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to be used between ID elements"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "regex_replace_chars" {
  description = "Regex string to remove characters from ID elements"
  type        = string
  default     = null
}

variable "label_order" {
  description = "The order in which the labels appear in the id"
  type        = list(string)
  default     = null
}

variable "label_key_case" {
  description = "Controls the letter case of tag keys"
  type        = string
  default     = null
}

variable "label_value_case" {
  description = "Controls the letter case of tag values"
  type        = string
  default     = null
}

variable "id_length_limit" {
  description = "Limit id to this many characters"
  type        = number
  default     = null
}
