variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "location" {
  description = "The Azure Region where the Cosmos DB Account should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Cosmos DB Account"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "The name of the Cosmos DB Account. If not provided, the name will be generated using the label module"
  type        = string
  default     = null
}

variable "offer_type" {
  description = "The Offer Type to use for this Cosmos DB Account - currently only Standard is supported"
  type        = string
  default     = "Standard"
  validation {
    condition     = var.offer_type == "Standard"
    error_message = "The offer_type must be Standard."
  }
}

variable "kind" {
  description = "The Kind of Cosmos DB to create. Possible values are GlobalDocumentDB, MongoDB, and Parse"
  type        = string
  default     = "GlobalDocumentDB"
  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "The kind must be one of: GlobalDocumentDB, MongoDB, Parse."
  }
}

variable "consistency_policy" {
  description = "The consistency policy for the Cosmos DB account"
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  default = {
    consistency_level = "Session"
  }
  validation {
    condition     = contains(["BoundedStaleness", "ConsistentPrefix", "Eventual", "Session", "Strong"], var.consistency_policy.consistency_level)
    error_message = "The consistency_level must be one of: BoundedStaleness, ConsistentPrefix, Eventual, Session, Strong."
  }
}

variable "geo_locations" {
  description = "List of geo-locations for the Cosmos DB account. The first location is the primary write region"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default = []
}

variable "capabilities" {
  description = "List of Cosmos DB capabilities to enable. Possible values are EnableAggregationPipeline, EnableCassandra, EnableGremlin, EnableMongo, EnableTable, EnableServerless, EnableAnalyticalStorage, MongoDBv3.4, mongoEnableDocLevelTTL, DisableRateLimitingResponses, AllowSelfServeUpgradeToMongo36"
  type        = list(string)
  default     = []
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "enable_multiple_write_locations" {
  description = "Enable multiple write locations for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable the Free Tier pricing option for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "analytical_storage_enabled" {
  description = "Enable Analytical Storage for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this Cosmos DB account"
  type        = bool
  default     = true
}

variable "ip_range_filter" {
  description = "Comma-separated list of IP addresses or CIDR ranges to allow access from. Set to empty string to disable IP filtering"
  type        = string
  default     = ""
}

variable "network_acl_bypass_for_azure_services" {
  description = "If Azure services can bypass ACLs"
  type        = bool
  default     = false
}

variable "network_acl_bypass_ids" {
  description = "List of resource IDs for Network ACL bypass for this Cosmos DB account"
  type        = list(string)
  default     = []
}

variable "virtual_network_rules" {
  description = "List of virtual network rules for the Cosmos DB account"
  type = list(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = []
}

variable "backup" {
  description = "Backup configuration for the Cosmos DB account"
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
  })
  default = {
    type = "Periodic"
  }
  validation {
    condition     = contains(["Continuous", "Periodic"], var.backup.type)
    error_message = "The backup type must be one of: Continuous, Periodic."
  }
}

variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the Cosmos DB Account. Possible values are SystemAssigned, UserAssigned, and SystemAssigned, UserAssigned"
  type        = string
  default     = null
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "The identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned to this Cosmos DB Account. Required when identity_type is UserAssigned or SystemAssigned, UserAssigned"
  type        = list(string)
  default     = []
}

variable "access_key_metadata_writes_enabled" {
  description = "Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?"
  type        = bool
  default     = true
}

variable "mongo_server_version" {
  description = "The Server Version of a MongoDB account. Possible values are 4.2, 4.0, 3.6, and 3.2"
  type        = string
  default     = null
  validation {
    condition     = var.mongo_server_version == null || contains(["3.2", "3.6", "4.0", "4.2"], var.mongo_server_version)
    error_message = "The mongo_server_version must be one of: 3.2, 3.6, 4.0, 4.2."
  }
}

variable "local_authentication_disabled" {
  description = "Disable local authentication methods and ensure only MSI and AAD can be used exclusively for authentication"
  type        = bool
  default     = false
}

variable "default_identity_type" {
  description = "The default identity for accessing Key Vault. Possible values are FirstPartyIdentity, SystemAssignedIdentity or UserAssignedIdentity"
  type        = string
  default     = null
  validation {
    condition     = var.default_identity_type == null || contains(["FirstPartyIdentity", "SystemAssignedIdentity", "UserAssignedIdentity"], var.default_identity_type)
    error_message = "The default_identity_type must be one of: FirstPartyIdentity, SystemAssignedIdentity, UserAssignedIdentity."
  }
}

variable "cors_rules" {
  description = "CORS rules for the Cosmos DB account"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "analytical_storage_type" {
  description = "The schema type of the Analytical Storage for this Cosmos DB account. Possible values are FullFidelity and WellDefined"
  type        = string
  default     = null
  validation {
    condition     = var.analytical_storage_type == null || contains(["FullFidelity", "WellDefined"], var.analytical_storage_type)
    error_message = "The analytical_storage_type must be one of: FullFidelity, WellDefined."
  }
}

variable "capacity" {
  description = "Capacity configuration for the Cosmos DB account (Serverless or Provisioned)"
  type = object({
    total_throughput_limit = number
  })
  default = null
}

variable "create_mode" {
  description = "The creation mode for the Cosmos DB Account. Possible values are Default and Restore"
  type        = string
  default     = "Default"
  validation {
    condition     = contains(["Default", "Restore"], var.create_mode)
    error_message = "The create_mode must be one of: Default, Restore."
  }
}

variable "restore" {
  description = "Restore configuration for the Cosmos DB account when create_mode is Restore"
  type = object({
    source_cosmosdb_account_id = string
    restore_timestamp_in_utc   = string
    database = optional(list(object({
      name             = string
      collection_names = optional(list(string))
    })))
    gremlin_database = optional(list(object({
      name        = string
      graph_names = optional(list(string))
    })))
    tables_to_restore = optional(list(string))
  })
  default = null
}

variable "partition_merge_enabled" {
  description = "Is partition merge enabled for this Cosmos DB account?"
  type        = bool
  default     = false
}

variable "minimal_tls_version" {
  description = "Specifies the minimal TLS version for the Cosmos DB account. Possible values are Tls, Tls11, and Tls12"
  type        = string
  default     = "Tls12"
  validation {
    condition     = contains(["Tls", "Tls11", "Tls12"], var.minimal_tls_version)
    error_message = "The minimal_tls_version must be one of: Tls, Tls11, Tls12."
  }
}

#####################################################
# CloudPosse Label Module Variables
#####################################################

variable "namespace" {
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element. Usually the tenant or customer identifier"
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

variable "delimiter" {
  description = "Delimiter to be used between ID elements. Defaults to `-` (hyphen). Set to `\"\"` to use no delimiter at all"
  type        = string
  default     = null
}

variable "attributes" {
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`, in the order they appear in the list. New attributes are appended to the end of the list. The elements of the list are joined by the `delimiter` and treated as a single ID element"
  type        = list(string)
  default     = []
}

variable "labels_as_tags" {
  description = "Set of labels (ID elements) to include as tags in the `tags` output. Default is to include all labels. Tags with empty values will not be included in the `tags` output. Set to `[]` to suppress all generated tags. Notes: The value of the `name` tag, if included, will be the `id`, not the `name`. Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be changed in later chained modules. Attempts to change it will be silently ignored"
  type        = set(string)
  default     = ["default"]
}

variable "tags" {
  description = "Additional tags (e.g. `{'BusinessUnit': 'XYZ'}). Neither the tag keys nor the tag values will be modified by this module"
  type        = map(string)
  default     = {}
}

variable "additional_tag_map" {
  description = "Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`. This is for some rare cases where resources want additional configuration of tags and therefore take a list of maps with tag key, value, and additional configuration"
  type        = map(string)
  default     = {}
}

variable "label_order" {
  description = "The order in which the labels (ID elements) appear in the `id`. Defaults to [\"namespace\", \"environment\", \"stage\", \"name\", \"attributes\"]. You can omit any of the 6 labels (\"tenant\" is the 6th), but at least one must be present"
  type        = list(string)
  default     = null
}

variable "regex_replace_chars" {
  description = "Terraform regular expression (regex) string. Characters matching the regex will be removed from the ID elements. If not set, `\"/[^a-zA-Z0-9-]/\"` is used to remove all characters other than hyphens, letters and digits"
  type        = string
  default     = null
}

variable "id_length_limit" {
  description = "Limit `id` to this many characters (minimum 6). Set to `0` for unlimited length. Set to `null` for keep the existing setting, which defaults to `0`. Does not affect `id_full`"
  type        = number
  default     = null
  validation {
    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}

variable "label_key_case" {
  description = "Controls the letter case of the `tags` keys (label names) for tags generated by this module. Does not affect keys of tags passed in via the `tags` input. Possible values: `lower`, `title`, `upper`. Default value: `title`"
  type        = string
  default     = null
  validation {
    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  description = "Controls the letter case of ID elements (labels) as included in `id`, set as tag values, and output by this module individually. Does not affect values of tags passed in via the `tags` input. Possible values: `lower`, `title`, `upper` and `none` (no transformation). Set this to `title` and set `delimiter` to `\"\"` to yield Pascal Case IDs. Default value: `lower`"
  type        = string
  default     = null
  validation {
    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "descriptor_formats" {
  description = "Describe additional descriptors to be output in the `descriptors` output map. Map of maps. Keys are names of descriptors. Values are maps of the form `{ format = string labels = list(string) }` (Type is `any` so the map values can later be enhanced to provide additional options.) `format` is a Terraform format string to be passed to the `format()` function. `labels` is a list of labels, in order, to pass to `format()` function. Label values will be normalized before being passed to `format()` so they will be identical to how they appear in `id`. Default is `{}` (`descriptors` output will be empty)"
  type        = any
  default     = {}
}

variable "context" {
  description = "Single object for setting entire context at once. See description of individual variables for details. Leave string and numeric variables as `null` to use default value. Individual variable settings (non-null) override settings in context object, except for attributes, tags, and additional_tag_map, which are merged"
  type        = any
  default = {
    enabled             = true
    namespace           = null
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    labels_as_tags      = ["unset"]
  }
  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}
