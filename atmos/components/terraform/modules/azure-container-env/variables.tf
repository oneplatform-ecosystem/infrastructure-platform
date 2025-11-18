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
# Azure Container App Environment Variables
####################

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container App Environment"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Container App Environment should exist"
  type        = string
}

variable "container_app_environment_name" {
  description = "Override the Container App Environment name. If not provided, the name will be generated using the label module"
  type        = string
  default     = null
}

variable "add_random_suffix" {
  description = "Add a random suffix to the Container App Environment name for uniqueness"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to use for logging"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "The ID of the Subnet for infrastructure components. This is used to deploy the Container App Environment in a VNET"
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Should the Container Environment operate in Internal Load Balancing Mode? Defaults to false"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Should the Container App Environment be created with Zone Redundancy enabled? Defaults to false"
  type        = bool
  default     = false
}

variable "dapr_application_insights_connection_string" {
  description = "Application Insights connection string used by Dapr to export Service to Service communication telemetry"
  type        = string
  default     = null
  sensitive   = true
}

variable "workload_profiles" {
  description = "List of workload profiles for the Container App Environment. Workload profiles determine the compute resources available to container apps"
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number)
    maximum_count         = optional(number)
  }))
  default = []
}

variable "mutual_tls_enabled" {
  description = "Should mutual TLS authentication be enabled for the Container App Environment? Defaults to false"
  type        = bool
  default     = false
}
