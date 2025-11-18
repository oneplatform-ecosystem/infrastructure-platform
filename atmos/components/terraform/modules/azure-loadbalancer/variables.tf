variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "location" {
  description = "The Azure Region where the Load Balancer should exist"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the Load Balancer should exist"
  type        = string
}

variable "loadbalancer_name" {
  description = "Specifies the name of the Load Balancer. If not provided, the name will be generated using the label module"
  type        = string
  default     = null
}

variable "sku" {
  description = "The SKU of the Azure Load Balancer. Accepted values are Basic, Standard and Gateway"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Gateway"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Gateway"
  }
}

variable "sku_tier" {
  description = "The SKU tier of this Load Balancer. Possible values are Global and Regional"
  type        = string
  default     = "Regional"
  validation {
    condition     = contains(["Global", "Regional"], var.sku_tier)
    error_message = "SKU tier must be one of: Global, Regional"
  }
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Load Balancer should exist"
  type        = string
  default     = null
}

variable "frontend_ip_configurations" {
  description = "List of frontend IP configurations for the Load Balancer"
  type = list(object({
    name                                               = string
    zones                                              = optional(list(string))
    subnet_id                                          = optional(string)
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
    private_ip_address                                 = optional(string)
    private_ip_address_allocation                      = optional(string)
    private_ip_address_version                         = optional(string)
    public_ip_address_id                               = optional(string)
    public_ip_prefix_id                                = optional(string)
  }))
  default = []
}

variable "backend_address_pools" {
  description = "Map of backend address pools for the Load Balancer"
  type = map(object({
    name = string
    tunnel_interfaces = optional(list(object({
      identifier = number
      type       = string
      protocol   = string
      port       = number
    })))
  }))
  default = {}
}

variable "probes" {
  description = "Map of health probes for the Load Balancer"
  type = map(object({
    name                = string
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number)
    number_of_probes    = optional(number)
    probe_threshold     = optional(number)
  }))
  default = {}
}

variable "load_balancing_rules" {
  description = "Map of load balancing rules for the Load Balancer"
  type = map(object({
    name                           = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    backend_address_pool_keys      = list(string)
    probe_key                      = optional(string)
    enable_floating_ip             = optional(bool)
    enable_tcp_reset               = optional(bool)
    disable_outbound_snat          = optional(bool)
    idle_timeout_in_minutes        = optional(number)
    load_distribution              = optional(string)
  }))
  default = {}
}

variable "nat_rules" {
  description = "Map of inbound NAT rules for the Load Balancer"
  type = map(object({
    name                           = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    idle_timeout_in_minutes        = optional(number)
    enable_floating_ip             = optional(bool)
    enable_tcp_reset               = optional(bool)
  }))
  default = {}
}

variable "nat_pools" {
  description = "Map of NAT pools for the Load Balancer"
  type = map(object({
    name                           = string
    protocol                       = string
    frontend_port_start            = number
    frontend_port_end              = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    idle_timeout_in_minutes        = optional(number)
    floating_ip_enabled            = optional(bool)
    tcp_reset_enabled              = optional(bool)
  }))
  default = {}
}

variable "outbound_rules" {
  description = "Map of outbound rules for the Load Balancer (Standard SKU only)"
  type = map(object({
    name                            = string
    protocol                        = string
    backend_address_pool_key        = string
    frontend_ip_configuration_names = list(string)
    allocated_outbound_ports        = optional(number)
    idle_timeout_in_minutes         = optional(number)
    enable_tcp_reset                = optional(bool)
  }))
  default = {}
}

# CloudPosse Label Module Variables
variable "namespace" {
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
  type        = string
  default     = null
}

variable "tenant" {
  description = "ID element. Usually used to indicate the tenant identifier"
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
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`, in the order they appear in the list"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to be used between ID elements. Defaults to `-` (hyphen)"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`) to add to the resource tags"
  type        = map(string)
  default     = {}
}

variable "regex_replace_chars" {
  description = "Terraform regular expression (regex) string. Characters matching the regex will be removed from the ID elements. If not set, `\"/[^a-zA-Z0-9-]/\"` is used to remove all characters other than hyphens, letters and digits"
  type        = string
  default     = null
}

variable "label_order" {
  description = "The order in which the labels (ID elements) appear in the `id`. Defaults to [\"namespace\", \"environment\", \"stage\", \"name\", \"attributes\"]. You can omit any of the 6 labels (\"tenant\" is the 6th), but at least one must be present"
  type        = list(string)
  default     = null
}

variable "label_key_case" {
  description = "Controls the letter case of the `tags` keys (label names) for tags generated by this module. Does not affect keys of tags passed in via the `tags` input. Possible values: `lower`, `title`, `upper`. Default value: `title`"
  type        = string
  default     = null
}

variable "label_value_case" {
  description = "Controls the letter case of ID elements (labels) as included in `id`, set as tag values, and output by this module individually. Does not affect values of tags passed in via the `tags` input. Possible values: `lower`, `title`, `upper` and `none` (no transformation). Set this to `title` and set `delimiter` to `\"\"` to yield Pascal Case IDs. Default value: `lower`"
  type        = string
  default     = null
}

variable "id_length_limit" {
  description = "Limit `id` to this many characters (minimum 6). Set to `0` for unlimited length. Set to `null` for keep the existing setting, which defaults to `0`. Does not affect `id_full`"
  type        = number
  default     = null
}
