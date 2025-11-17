variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "location" {
  description = "The Azure Region where the Redis Cache should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Redis Cache"
  type        = string
}

variable "redis_cache_name" {
  description = "Custom name for the Redis Cache. If not specified, the module will use the ID from the label module"
  type        = string
  default     = null
}

# Redis Cache Configuration
variable "sku_name" {
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "The sku_name must be one of: Basic, Standard, Premium."
  }
}

variable "family" {
  description = "The SKU family/pricing group to use. Valid values are C (for Basic/Standard) and P (for Premium)"
  type        = string
  default     = "C"
  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "The family must be either C or P."
  }
}

variable "capacity" {
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0-6, and for P (Premium) are 1-5"
  type        = number
  default     = 1
  validation {
    condition     = var.capacity >= 0 && var.capacity <= 6
    error_message = "The capacity must be between 0 and 6."
  }
}

variable "redis_version" {
  description = "Redis version. Only major version needed. Valid values are 4 and 6"
  type        = string
  default     = "6"
  validation {
    condition     = contains(["4", "6"], var.redis_version)
    error_message = "The redis_version must be either 4 or 6."
  }
}

variable "enable_non_ssl_port" {
  description = "Enable the non-SSL port (6379) - disabled by default for security"
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "The minimum TLS version. Possible values are 1.0, 1.1 and 1.2"
  type        = string
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "The minimum_tls_version must be one of: 1.0, 1.1, 1.2."
  }
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this Redis Cache"
  type        = bool
  default     = false
}

# Redis Configuration
variable "redis_configuration" {
  description = "Redis configuration options"
  type = object({
    enable_authentication           = optional(bool)
    maxmemory_reserved              = optional(number)
    maxmemory_delta                 = optional(number)
    maxmemory_policy                = optional(string)
    maxfragmentationmemory_reserved = optional(number)
    notify_keyspace_events          = optional(string)
    aof_backup_enabled              = optional(bool)
    aof_storage_connection_string_0 = optional(string)
    aof_storage_connection_string_1 = optional(string)
    rdb_backup_enabled              = optional(bool)
    rdb_backup_frequency            = optional(number)
    rdb_backup_max_snapshot_count   = optional(number)
    rdb_storage_connection_string   = optional(string)
  })
  default = null
}

# Patch Schedule
variable "patch_schedules" {
  description = "A list of patch schedules for the Redis Cache"
  type = list(object({
    day_of_week        = string
    start_hour_utc     = number
    maintenance_window = optional(string)
  }))
  default = []
}

# Zones and Replicas (Premium SKU only)
variable "zones" {
  description = "A list of Availability Zones in which this Redis Cache should be located. Changing this forces a new resource to be created"
  type        = list(string)
  default     = null
}

# Note: replicas_per_master is deprecated in AzureRM v4.x - use replicas_per_primary instead

variable "replicas_per_primary" {
  description = "Amount of replicas to create per primary for this Redis Cache. Only available when using the Premium SKU"
  type        = number
  default     = null
}

variable "shard_count" {
  description = "Only available when using the Premium SKU. The number of Shards to create on the Redis Cluster"
  type        = number
  default     = null
}

# Network Configuration
variable "subnet_id" {
  description = "The ID of the Subnet within which the Redis Cache should be deployed. Only available when using the Premium SKU"
  type        = string
  default     = null
}

# Private Endpoint Configuration
variable "create_private_endpoint" {
  description = "Whether to create a private endpoint for the Redis Cache"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet from which the private IP will be allocated for private endpoint"
  type        = string
  default     = null
}

variable "private_endpoint_manual_connection" {
  description = "Does the private endpoint require manual approval from the remote resource owner?"
  type        = bool
  default     = false
}

variable "private_endpoint_dns_zone_group" {
  description = "Private DNS zone group configuration for Redis Cache private endpoint"
  type = object({
    name                 = string
    private_dns_zone_ids = list(string)
  })
  default = null
}

# Identity
variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the Redis Cache. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned"
  type        = string
  default     = null
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "The identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned to the Redis Cache"
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
