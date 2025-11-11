# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VARIABLES
# These variables are expected to be passed in by the operator
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# MODULE CONTROL VARIABLES
# These variables control whether the module creates resources
# ---------------------------------------------------------------------------------------------------------------------

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module
# ---------------------------------------------------------------------------------------------------------------------

variable "cognitive_account_id" {
  description = "The ID of the Azure OpenAI Service (Cognitive Account) where the models will be deployed"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# MODEL DEPLOYMENT VARIABLES
# These variables configure the AI model deployments
# ---------------------------------------------------------------------------------------------------------------------

variable "deployments" {
  description = <<-EOT
    Map of AI model deployments to create in the Azure OpenAI Service.
    Each deployment requires:
    - model_format: The format of the model (e.g., 'OpenAI')
    - model_name: The name of the model (e.g., 'gpt-4', 'gpt-35-turbo', 'text-embedding-ada-002')
    - model_version: The version of the model (e.g., '0613', '1106')
    - scale_type: The type of scaling (e.g., 'Standard')
    - scale_capacity: The capacity for scaling (optional, default: 1)
    - scale_tier: The tier for scaling (optional)
    - scale_size: The size for scaling (optional)
    - scale_family: The family for scaling (optional)
    - rai_policy_name: The name of the RAI policy (optional)
    - version_upgrade_option: The version upgrade option (optional, e.g., 'OnceCurrentVersionExpired', 'OnceNewDefaultVersionAvailable', 'NoAutoUpgrade')
    - dynamic_throttling_enabled: Whether dynamic throttling is enabled (optional, default: false)
  EOT
  type = map(object({
    model_format                 = string
    model_name                   = string
    model_version                = string
    scale_type                   = string
    scale_capacity               = optional(number, 1)
    scale_tier                   = optional(string)
    scale_size                   = optional(string)
    scale_family                 = optional(string)
    rai_policy_name              = optional(string)
    version_upgrade_option       = optional(string, "OnceCurrentVersionExpired")
    dynamic_throttling_enabled   = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.deployments : contains(
        ["Standard", "GlobalStandard", "ProvisionedManaged"],
        v.scale_type
      )
    ])
    error_message = "The scale_type must be one of: Standard, GlobalStandard, or ProvisionedManaged."
  }

  validation {
    condition = alltrue([
      for k, v in var.deployments : v.version_upgrade_option == null ? true : contains(
        ["OnceCurrentVersionExpired", "OnceNewDefaultVersionAvailable", "NoAutoUpgrade"],
        v.version_upgrade_option
      )
    ])
    error_message = "The version_upgrade_option must be one of: OnceCurrentVersionExpired, OnceNewDefaultVersionAvailable, or NoAutoUpgrade."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LABEL MODULE VARIABLES
# These variables are used by the label module to generate consistent names and tags
# ---------------------------------------------------------------------------------------------------------------------

variable "namespace" {
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'lazylabs' to help ensure generated IDs are globally unique"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for"
  type        = string
  default     = null
}

variable "environment" {
  description = "ID element. Usually used for region e.g. 'eus' for East US, 'wus' for West US"
  type        = string
  default     = null
}

variable "stage" {
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'dev', 'UAT'"
  type        = string
  default     = null
}

variable "name" {
  description = "ID element. Usually the component or solution name, e.g. 'app' or 'cluster'"
  type        = string
  default     = null
}

variable "attributes" {
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`, in the order they appear in the list. New attributes are appended to the end of the list. The elements of the list are joined by the `delimiter` and treated as a single ID element."
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = <<-EOT
    Delimiter to be used between ID elements.
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.
  EOT
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).\nNeither the tag keys nor the tag values will be modified by this module."
  type        = map(string)
  default     = {}
}

variable "regex_replace_chars" {
  description = <<-EOT
    Terraform regular expression (regex) string.
    Characters matching the regex will be removed from the ID elements.
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
  EOT
  type        = string
  default     = null
}

variable "label_order" {
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.
  EOT
  type        = list(string)
  default     = null
}

variable "label_key_case" {
  description = <<-EOT
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
    Does not affect keys of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper`.
    Default value: `title`.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.label_key_case == null ? true : contains(
      ["lower", "title", "upper"],
      var.label_key_case
    )
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  description = <<-EOT
    Controls the letter case of ID elements (labels) as included in `id`,
    set as tag values, and output by this module individually.
    Does not affect values of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
    Set to `null` to use the value from the context.
    Default value: `lower`.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.label_value_case == null ? true : contains(
      ["lower", "title", "upper", "none"],
      var.label_value_case
    )
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "id_length_limit" {
  description = <<-EOT
    Limit `id` to this many characters (minimum 6).
    Set to `0` for unlimited length.
    Set to `null` for keep the existing setting, which defaults to `0`.
    Does not affect `id_full`.
  EOT
  type        = number
  default     = null

  validation {
    condition = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}
