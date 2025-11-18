variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

# ==============================================================================
# Cloud Posse Label Module Variables
# ==============================================================================

variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation"
  type        = string
  default     = null
}

variable "tenant" {
  description = "Account Name or unique account unique id e.g., apps or management or aws account id"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'"
  type        = string
  default     = null
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
  type        = string
  default     = null
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Additional attributes (e.g. `1`)"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to be used between namespace, environment, stage, name and attributes"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
  type        = map(string)
  default     = {}
}

variable "additional_tag_map" {
  description = "Additional tags for appending to tags_as_list_of_maps"
  type        = map(string)
  default     = {}
}

variable "regex_replace_chars" {
  description = "Regex to replace chars with empty string in namespace, environment, stage and name"
  type        = string
  default     = "/[^a-zA-Z0-9-]/"
}

variable "label_order" {
  description = "The naming order of the id output and Name tag"
  type        = list(string)
  default     = []
}

variable "id_length_limit" {
  description = "Limit `id` to this many characters. Set to `0` for unlimited length"
  type        = number
  default     = 0
}

variable "label_key_case" {
  description = "The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`"
  type        = string
  default     = "lower"
}

variable "label_value_case" {
  description = "The letter case of output label values (also used in `tags` and `id`)"
  type        = string
  default     = "lower"
}

variable "context" {
  description = "Single object for setting entire context at once"
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
  }
}

# ==============================================================================
# Azure Front Door Variables
# ==============================================================================

variable "resource_group_name" {
  description = "Name of the resource group where the Front Door will be created"
  type        = string
}

variable "custom_name" {
  description = "Custom name for the Front Door Profile (overrides label module generated name)"
  type        = string
  default     = null
}

variable "sku_name" {
  description = "SKU name for the Front Door Profile. Possible values include: Standard_AzureFrontDoor, Premium_AzureFrontDoor"
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "SKU name must be either Standard_AzureFrontDoor or Premium_AzureFrontDoor"
  }
}

variable "response_timeout_seconds" {
  description = "Response timeout in seconds. Possible values are between 16 and 240 seconds"
  type        = number
  default     = 120

  validation {
    condition     = var.response_timeout_seconds >= 16 && var.response_timeout_seconds <= 240
    error_message = "Response timeout must be between 16 and 240 seconds"
  }
}

variable "endpoints" {
  description = "Map of Front Door endpoints to create"
  type = map(object({
    name    = string
    enabled = optional(bool, true)
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "origin_groups" {
  description = "Map of origin groups for the Front Door"
  type = map(object({
    name                     = string
    session_affinity_enabled = optional(bool, false)
    load_balancing = object({
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
      additional_latency_in_milliseconds = optional(number, 50)
    })
    health_probe = optional(object({
      protocol            = string # Http or Https
      interval_in_seconds = number
      request_type        = optional(string, "HEAD") # HEAD or GET
      path                = optional(string, "/")
    }))
  }))
  default = {}
}

variable "origins" {
  description = "Map of origins for the Front Door origin groups"
  type = map(object({
    name                           = string
    origin_group_key               = string
    enabled                        = optional(bool, true)
    certificate_name_check_enabled = optional(bool, true)
    host_name                      = string
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    origin_host_header             = optional(string)
    priority                       = optional(number, 1)
    weight                         = optional(number, 1000)
    private_link = optional(object({
      request_message        = optional(string)
      target_type            = optional(string)
      location               = string
      private_link_target_id = string
    }))
  }))
  default = {}
}

variable "routes" {
  description = "Map of routes for the Front Door"
  type = map(object({
    name                   = string
    endpoint_key           = string
    origin_group_key       = string
    origin_keys            = list(string)
    enabled                = optional(bool, true)
    forwarding_protocol    = optional(string, "HttpsOnly") # HttpOnly, HttpsOnly, MatchRequest
    https_redirect_enabled = optional(bool, true)
    patterns_to_match      = list(string)
    supported_protocols    = list(string) # Http, Https
    custom_domain_keys     = optional(list(string))
    link_to_default_domain = optional(bool, true)
    rule_set_keys          = optional(list(string))
    cache = optional(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString") # IgnoreQueryString, UseQueryString, IgnoreSpecifiedQueryStrings, IncludeSpecifiedQueryStrings
      query_strings                 = optional(list(string))
      compression_enabled           = optional(bool, true)
      content_types_to_compress     = optional(list(string))
    }))
  }))
  default = {}
}

variable "rule_sets" {
  description = "Map of rule sets for the Front Door"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "rules" {
  description = "Map of rules for the Front Door rule sets"
  type = map(object({
    name              = string
    rule_set_key      = string
    order             = number
    behavior_on_match = optional(string, "Continue") # Continue or Stop
    actions = object({
      route_configuration_override_action = optional(object({
        cache_duration                = optional(string)
        origin_group_key              = optional(string)
        forwarding_protocol           = optional(string) # HttpOnly, HttpsOnly, MatchRequest
        query_string_caching_behavior = optional(string) # IgnoreQueryString, UseQueryString, IgnoreSpecifiedQueryStrings, IncludeSpecifiedQueryStrings
        query_string_parameters       = optional(list(string))
        compression_enabled           = optional(bool)
        cache_behavior                = optional(string) # HonorOrigin, OverrideAlways, OverrideIfOriginMissing
      }))
      url_redirect_action = optional(object({
        redirect_type        = string                           # Moved, Found, TemporaryRedirect, PermanentRedirect
        redirect_protocol    = optional(string, "MatchRequest") # MatchRequest, Http, Https
        query_string         = optional(string)
        destination_path     = optional(string)
        destination_hostname = string
        destination_fragment = optional(string)
      }))
      url_rewrite_action = optional(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, false)
      }))
      request_header_action = optional(list(object({
        header_action = string # Append, Overwrite, Delete
        header_name   = string
        value         = optional(string)
      })))
      response_header_action = optional(list(object({
        header_action = string # Append, Overwrite, Delete
        header_name   = string
        value         = optional(string)
      })))
    })
    conditions = optional(object({
      remote_address_condition = optional(object({
        operator         = optional(string, "IPMatch") # IPMatch
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      }))
      request_method_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string) # GET, POST, PUT, DELETE, HEAD, OPTIONS, TRACE
      }))
      query_string_condition = optional(object({
        operator         = string # Any, Equal, Contains, BeginsWith, EndsWith, LessThan, LessThanOrEqual, GreaterThan, GreaterThanOrEqual, RegEx
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string)) # Lowercase, Uppercase, Trim, UrlDecode, UrlEncode, RemoveNulls
      }))
      post_args_condition = optional(object({
        post_args_name   = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_uri_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_header_condition = optional(object({
        header_name      = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_body_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
        transforms       = optional(list(string))
      }))
      request_scheme_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string), ["HTTP"]) # HTTP or HTTPS
      }))
      url_path_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_file_extension_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
        transforms       = optional(list(string))
      }))
      url_filename_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
        transforms       = optional(list(string))
      }))
      http_version_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string) # 2.0, 1.1, 1.0, 0.9
      }))
      cookies_condition = optional(object({
        cookie_name      = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      is_device_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string), ["Mobile"]) # Mobile or Desktop
      }))
      socket_address_condition = optional(object({
        operator         = optional(string, "IPMatch")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      }))
      client_port_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      server_port_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      host_name_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
        transforms       = optional(list(string))
      }))
      ssl_protocol_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string) # TLSv1, TLSv1.1, TLSv1.2, TLSv1.3
      }))
    }))
  }))
  default = {}
}

variable "custom_domains" {
  description = "Map of custom domains for the Front Door"
  type = map(object({
    name        = string
    dns_zone_id = optional(string)
    host_name   = string
    tls = optional(object({
      certificate_type        = optional(string, "ManagedCertificate") # ManagedCertificate, CustomerCertificate
      minimum_tls_version     = optional(string, "TLS12")              # TLS10, TLS12
      cdn_frontdoor_secret_id = optional(string)
    }))
  }))
  default = {}
}

variable "security_policies" {
  description = "Map of security policies for the Front Door (Premium SKU only)"
  type = map(object({
    name               = string
    firewall_policy_id = string
    domain_keys        = optional(list(string))
    patterns_to_match  = list(string)
  }))
  default = {}
}
