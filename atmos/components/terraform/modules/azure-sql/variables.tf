# General Variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the SQL Server"
  type        = string
}

variable "location" {
  description = "The Azure region where the SQL Server should exist"
  type        = string
}

# SQL Server Variables
variable "sql_server_name" {
  description = "Custom name for the SQL Server. If not provided, will use the label module generated ID"
  type        = string
  default     = null
}

variable "sql_server_version" {
  description = "The version for the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)"
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "The administrator login name for the SQL Server"
  type        = string
  sensitive   = true
}

variable "administrator_login_password" {
  description = "The administrator login password for the SQL Server"
  type        = string
  sensitive   = true
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the SQL Server. Valid values are: 1.0, 1.1, 1.2"
  type        = string
  default     = "1.2"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for this server"
  type        = bool
  default     = false
}

# Azure AD Administrator
variable "azuread_administrator" {
  description = "Azure AD administrator configuration for the SQL Server"
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = string
    azuread_authentication_only = optional(bool, false)
  })
  default = null
}

# Identity Configuration
variable "identity_type" {
  description = "The type of Managed Service Identity. Possible values are SystemAssigned, UserAssigned"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "A list of User Assigned Managed Identity IDs to be assigned to this SQL Server"
  type        = list(string)
  default     = null
}

# Database Variables
variable "database_name" {
  description = "Custom name for the database. If not provided, will use the label module generated ID with -db suffix"
  type        = string
  default     = null
}

variable "collation" {
  description = "Specifies the collation of the database"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "Specifies the license type applied to this database. Possible values are LicenseIncluded and BasePrice"
  type        = string
  default     = null
}

variable "max_size_gb" {
  description = "The max size of the database in gigabytes"
  type        = number
  default     = null
}

variable "read_scale" {
  description = "If enabled, connections that have application intent set to readonly will be routed to a readonly secondary replica"
  type        = bool
  default     = false
}

variable "sku_name" {
  description = "Specifies the name of the SKU used by the database. For example, GP_S_Gen5_2, HS_Gen4_1, BC_Gen5_2, ElasticPool, Basic, S0, P2, DW100c, DS100"
  type        = string
  default     = "GP_S_Gen5_2"
}

variable "zone_redundant" {
  description = "Whether or not this database is zone redundant"
  type        = bool
  default     = false
}

variable "auto_pause_delay_in_minutes" {
  description = "Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled"
  type        = number
  default     = null
}

variable "min_capacity" {
  description = "Minimal capacity that database will always have allocated, if not paused"
  type        = number
  default     = null
}

variable "storage_account_type" {
  description = "Specifies the storage account type used to store backups. Possible values are Geo, Local and Zone"
  type        = string
  default     = "Geo"
}

# Backup and Retention Policies
variable "short_term_retention_policy" {
  description = "Short-term retention policy configuration"
  type = object({
    retention_days           = number
    backup_interval_in_hours = optional(number, 12)
  })
  default = null
}

variable "long_term_retention_policy" {
  description = "Long-term retention policy configuration"
  type = object({
    weekly_retention  = optional(string)
    monthly_retention = optional(string)
    yearly_retention  = optional(string)
    week_of_year      = optional(number)
  })
  default = null
}

# Security
# Note: threat_detection_policy is deprecated in AzureRM v4.x
# Use azurerm_mssql_server_security_alert_policy resource instead
variable "threat_detection_policy" {
  description = "DEPRECATED: Use azurerm_mssql_server_security_alert_policy resource instead. This variable is ignored in provider v4.x"
  type = object({
    state                      = optional(string, "Enabled")
    disabled_alerts            = optional(list(string), [])
    email_account_admins       = optional(string, "Disabled")
    email_addresses            = optional(list(string), [])
    retention_days             = optional(number, 0)
    storage_account_access_key = optional(string)
    storage_endpoint           = optional(string)
  })
  default = null
}

# Firewall and Network Rules
variable "firewall_rules" {
  description = "Map of firewall rules to create. The key is the rule name"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "virtual_network_rules" {
  description = "Map of virtual network rules to create. The key is the rule name"
  type = map(object({
    subnet_id = string
  }))
  default = {}
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
