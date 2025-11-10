####################
# Label Module Variables
####################

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation, e.g., 'eg' or 'cp'"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment, e.g., 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'"
  type        = string
  default     = null
}

variable "stage" {
  description = "Stage, e.g., 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
  type        = string
  default     = null
}

variable "name" {
  description = "Solution name, e.g., 'app' or 'jenkins'"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Additional attributes (e.g., `['shared', 'private']`)"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags (e.g., `{'BusinessUnit': 'XYZ'}`).\nNeither the tag keys nor the tag values will be modified by this module."
  type        = map(string)
  default     = {}
}

variable "additional_tag_map" {
  description = "Additional tags for appending to tags_as_list_of_maps. Not added to `tags`."
  type        = map(string)
  default     = {}
}

variable "label_order" {
  description = "The naming order of the id output and Name tag. Defaults to [\"namespace\", \"environment\", \"stage\", \"name\", \"attributes\"]"
  type        = list(string)
  default     = null
}

variable "regex_replace_chars" {
  description = "Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. If not set, `\"/[^a-zA-Z0-9-]/\"` is used to remove all characters other than hyphens, letters and digits."
  type        = string
  default     = null
}

variable "id_length_limit" {
  description = "Limit `id` to this many characters (minimum 6). Set to `0` for unlimited length. Set to `null` for default, which is `0`. Does not affect `id_full`."
  type        = number
  default     = null
}

variable "label_key_case" {
  description = "The letter case of label keys (`tag` names) (i.e., `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`. Possible values: `lower`, `title`, `upper`. Default value: `title`."
  type        = string
  default     = null
}

variable "label_value_case" {
  description = "The letter case of output label values (also used in `tags` and `id`). Possible values: `lower`, `title`, `upper` and `none` (no transformation). Default value: `lower`."
  type        = string
  default     = null
}

variable "context" {
  description = "Single object for setting entire context at once. See description of individual variables for details. Leave string and numeric variables as `null` to use default value. Individual variable settings (non-null) override settings in context object, except for attributes, tags, and additional_tag_map, which are merged."
  type = object({
    enabled             = bool
    namespace           = string
    tenant              = string
    environment         = string
    stage               = string
    name                = string
    delimiter           = string
    attributes          = list(string)
    tags                = map(string)
    additional_tag_map  = map(string)
    regex_replace_chars = string
    label_order         = list(string)
    id_length_limit     = number
    label_key_case      = string
    label_value_case    = string
  })
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
  }
}

####################
# Azure Container Registry Variables
####################

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Registry"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Container Registry should exist"
  type        = string
}

variable "container_registry_name" {
  description = "Override the Container Registry name. If not provided, the name will be generated using the label module"
  type        = string
  default     = null
}

variable "add_random_suffix" {
  description = "Add a random suffix to the Container Registry name for global uniqueness"
  type        = bool
  default     = true
}

variable "sku" {
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium"
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry. Only available for Premium SKU"
  type        = bool
  default     = true
}

variable "quarantine_policy_enabled" {
  description = "Boolean value that indicates whether quarantine policy is enabled. Only available for Premium SKU"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for this Container Registry. Only available for Premium SKU"
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "Boolean value that indicates whether export policy is enabled. Only available for Premium SKU"
  type        = bool
  default     = true
}

variable "anonymous_pull_enabled" {
  description = "Whether allows anonymous (unauthenticated) pull access to this Container Registry. Only available for Standard and Premium SKUs"
  type        = bool
  default     = false
}

variable "data_endpoint_enabled" {
  description = "Whether to enable dedicated data endpoints for this Container Registry. Only available for Premium SKU"
  type        = bool
  default     = false
}

variable "network_rule_bypass_option" {
  description = "Whether to allow trusted Azure services to access a network restricted Container Registry. Possible values are None and AzureServices"
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["None", "AzureServices"], var.network_rule_bypass_option)
    error_message = "network_rule_bypass_option must be either None or AzureServices"
  }
}

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)"
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned"
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry. Required when identity_type is UserAssigned or SystemAssigned, UserAssigned"
  type        = list(string)
  default     = []
}

variable "encryption" {
  description = "Encryption configuration block. Only available for Premium SKU"
  type = object({
    enabled            = bool
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

variable "georeplications" {
  description = "List of georeplications. Only available for Premium SKU"
  type = list(object({
    location                  = string
    zone_redundancy_enabled   = bool
    regional_endpoint_enabled = bool
    tags                      = map(string)
  }))
  default = []
}

variable "network_rule_set" {
  description = "Network rule set configuration. Only available for Premium SKU"
  type = object({
    default_action               = string
    ip_rules                     = list(object({
      action   = string
      ip_range = string
    }))
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "retention_policy" {
  description = "Retention policy for untagged manifests. Only available for Premium SKU"
  type = object({
    days    = number
    enabled = bool
  })
  default = null
}

variable "trust_policy" {
  description = "Trust policy for signed images. Only available for Premium SKU"
  type = object({
    enabled = bool
  })
  default = null
}

variable "scope_maps" {
  description = "Map of scope maps to create. Each scope map defines repository permissions"
  type = map(object({
    actions = list(string)
  }))
  default = {}
}

variable "tokens" {
  description = "Map of tokens to create. Each token references a scope map"
  type = map(object({
    scope_map_name = string
    enabled        = bool
  }))
  default = {}
}

variable "webhooks" {
  description = "Map of webhooks to create for the Container Registry"
  type = map(object({
    service_uri    = string
    status         = string
    scope          = string
    actions        = list(string)
    custom_headers = map(string)
  }))
  default = {}
}
