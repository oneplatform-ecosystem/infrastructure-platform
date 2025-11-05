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
# Azure Application Gateway Variables
# ==============================================================================

variable "resource_group_name" {
  description = "Name of the resource group where the Application Gateway will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the Application Gateway will be created"
  type        = string
}

variable "custom_name" {
  description = "Custom name for the Application Gateway (overrides label module generated name)"
  type        = string
  default     = null
}

variable "sku" {
  description = "SKU configuration for Application Gateway"
  type = object({
    name     = string # Standard_Small, Standard_Medium, Standard_Large, WAF_Medium, WAF_Large, Standard_v2, WAF_v2
    tier     = string # Standard, Standard_v2, WAF, WAF_v2
    capacity = number # For v2 SKUs, set to null and use autoscale_configuration
  })
  default = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
}

variable "autoscale_configuration" {
  description = "Autoscale configuration for Application Gateway v2 SKUs"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "gateway_ip_configuration" {
  description = "Gateway IP configuration. Subnet ID is required"
  type = object({
    name      = string
    subnet_id = string
  })
}

variable "frontend_port" {
  description = "Frontend port configuration"
  type = list(object({
    name = string
    port = number
  }))
  default = [
    {
      name = "http"
      port = 80
    },
    {
      name = "https"
      port = 443
    }
  ]
}

variable "public_ip_address_id" {
  description = "ID of the public IP address for the Application Gateway frontend"
  type        = string
  default     = null
}

variable "private_ip_address" {
  description = "Private IP address for the Application Gateway frontend (optional)"
  type        = string
  default     = null
}

variable "private_ip_address_allocation" {
  description = "Allocation method for private IP address (Dynamic or Static)"
  type        = string
  default     = "Dynamic"
}

variable "backend_address_pool" {
  description = "Backend address pool configuration"
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  default = [
    {
      name         = "default-backend-pool"
      fqdns        = []
      ip_addresses = []
    }
  ]
}

variable "backend_http_settings" {
  description = "Backend HTTP settings configuration"
  type = list(object({
    name                                = string
    cookie_based_affinity               = string # Enabled or Disabled
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    port                                = number
    protocol                            = string # Http or Https
    request_timeout                     = number
    probe_name                          = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    host_name                           = optional(string)
    trusted_root_certificate_names      = optional(list(string))
  }))
  default = [
    {
      name                  = "default-http-settings"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 30
    }
  ]
}

variable "http_listener" {
  description = "HTTP listener configuration"
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string # Http or Https
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    require_sni                    = optional(bool)
    ssl_certificate_name           = optional(string)
    firewall_policy_id             = optional(string)
  }))
  default = [
    {
      name                           = "default-http-listener"
      frontend_ip_configuration_name = "public-frontend"
      frontend_port_name             = "http"
      protocol                       = "Http"
    }
  ]
}

variable "request_routing_rule" {
  description = "Request routing rule configuration"
  type = list(object({
    name                        = string
    rule_type                   = string # Basic or PathBasedRouting
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
    priority                    = number
  }))
  default = [
    {
      name                       = "default-routing-rule"
      rule_type                  = "Basic"
      http_listener_name         = "default-http-listener"
      backend_address_pool_name  = "default-backend-pool"
      backend_http_settings_name = "default-http-settings"
      priority                   = 100
    }
  ]
}

variable "probe" {
  description = "Health probe configuration"
  type = list(object({
    name                                      = string
    protocol                                  = string # Http or Https
    path                                      = string
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    pick_host_name_from_backend_http_settings = optional(bool)
    host                                      = optional(string)
    port                                      = optional(number)
    match = optional(object({
      body        = optional(string)
      status_code = list(string)
    }))
  }))
  default = []
}

variable "ssl_certificate" {
  description = "SSL certificate configuration"
  type = list(object({
    name                = string
    data                = optional(string) # Base64-encoded PFX certificate
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "trusted_root_certificate" {
  description = "Trusted root certificate configuration for backend authentication"
  type = list(object({
    name                = string
    data                = optional(string) # Base64-encoded certificate
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "ssl_policy" {
  description = "SSL policy configuration"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string) # Predefined or Custom
    policy_name          = optional(string) # AppGwSslPolicy20170401S, etc.
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string) # TLSv1_0, TLSv1_1, TLSv1_2, TLSv1_3
  })
  default = null
}

variable "url_path_map" {
  description = "URL path map configuration for path-based routing"
  type = list(object({
    name                                = string
    default_backend_address_pool_name   = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    path_rule = list(object({
      name                        = string
      paths                       = list(string)
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      firewall_policy_id          = optional(string)
    }))
  }))
  default = []
}

variable "redirect_configuration" {
  description = "Redirect configuration"
  type = list(object({
    name                 = string
    redirect_type        = string # Permanent, Temporary, Found, SeeOther
    target_listener_name = optional(string)
    target_url           = optional(string)
    include_path         = optional(bool)
    include_query_string = optional(bool)
  }))
  default = []
}

variable "rewrite_rule_set" {
  description = "Rewrite rule set configuration"
  type = list(object({
    name = string
    rewrite_rule = list(object({
      name          = string
      rule_sequence = number
      condition = optional(list(object({
        variable    = string
        pattern     = string
        ignore_case = optional(bool)
        negate      = optional(bool)
      })))
      request_header_configuration = optional(list(object({
        header_name  = string
        header_value = string
      })))
      response_header_configuration = optional(list(object({
        header_name  = string
        header_value = string
      })))
      url = optional(object({
        path         = optional(string)
        query_string = optional(string)
        components   = optional(string) # path_only, query_string_only, path_and_query_string
        reroute      = optional(bool)
      }))
    }))
  }))
  default = []
}

variable "waf_configuration" {
  description = "Web Application Firewall configuration (for WAF_v2 SKU)"
  type = object({
    enabled                  = bool
    firewall_mode            = string # Detection or Prevention
    rule_set_type            = string # OWASP
    rule_set_version         = string # 3.0, 3.1, 3.2
    file_upload_limit_mb     = optional(number)
    request_body_check       = optional(bool)
    max_request_body_size_kb = optional(number)
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(number))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector_match_operator = optional(string)
      selector                = optional(string)
    })))
  })
  default = null
}

variable "firewall_policy_id" {
  description = "ID of the Web Application Firewall Policy to associate with the Application Gateway"
  type        = string
  default     = null
}

variable "zones" {
  description = "Availability zones for the Application Gateway (e.g., ['1', '2', '3'])"
  type        = list(string)
  default     = null
}

variable "enable_http2" {
  description = "Enable HTTP2 for the Application Gateway"
  type        = bool
  default     = true
}

variable "force_firewall_policy_association" {
  description = "Force the association of the Firewall Policy to all HTTP listeners"
  type        = bool
  default     = false
}

variable "identity" {
  description = "Managed identity configuration for Application Gateway"
  type = object({
    type         = string       # SystemAssigned, UserAssigned
    identity_ids = list(string) # Required for UserAssigned
  })
  default = null
}
