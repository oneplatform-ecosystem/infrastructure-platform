variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "location" {
  description = "The Azure Region where the API Management Service should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the API Management Service"
  type        = string
}

variable "api_management_name" {
  description = "Custom name for the API Management Service. If not specified, the module will use the ID from the label module"
  type        = string
  default     = null
}

# Publisher Information (Required)
variable "publisher_name" {
  description = "The name of publisher/company"
  type        = string
}

variable "publisher_email" {
  description = "The email of publisher/company"
  type        = string
}

# SKU Configuration
variable "sku_name" {
  description = "The SKU of the API Management Service. Possible values are Consumption, Developer, Basic, Standard and Premium"
  type        = string
  default     = "Developer"
  validation {
    condition     = contains(["Consumption", "Developer", "Basic", "Standard", "Premium"], var.sku_name)
    error_message = "The sku_name must be one of: Consumption, Developer, Basic, Standard, Premium."
  }
}

variable "capacity" {
  description = "The number of deployed units of the SKU. For Consumption SKU capacity must be 0"
  type        = number
  default     = 1
  validation {
    condition     = var.capacity >= 0
    error_message = "The capacity must be greater than or equal to 0."
  }
}

# Virtual Network Configuration
variable "virtual_network_type" {
  description = "The type of virtual network configuration. Possible values are None, External and Internal"
  type        = string
  default     = "None"
  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "The virtual_network_type must be one of: None, External, Internal."
  }
}

variable "virtual_network_configuration" {
  description = "Virtual network configuration for API Management"
  type = object({
    subnet_id = string
  })
  default = null
}

# Network and Security
variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the API Management service"
  type        = bool
  default     = true
}

variable "public_ip_address_id" {
  description = "ID of a standard SKU IPv4 Public IP for VNet integration"
  type        = string
  default     = null
}

variable "gateway_disabled" {
  description = "Disable the gateway in the main region? This is only supported when additional_locations are set"
  type        = bool
  default     = false
}

variable "min_api_version" {
  description = "The minimum API version to allow"
  type        = string
  default     = null
}

# Zones
variable "zones" {
  description = "A list of Availability Zones in which this API Management service should be located. Changing this forces a new resource to be created"
  type        = list(string)
  default     = null
}

# Identity Configuration
variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the API Management Service. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned"
  type        = string
  default     = null
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "The identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned to the API Management Service"
  type        = list(string)
  default     = null
}

# Client Certificate
variable "client_certificate_enabled" {
  description = "Enforce a client certificate to be presented on each request to the gateway?"
  type        = bool
  default     = false
}

# Protocols and Security Policy
variable "protocols" {
  description = "Protocols configuration for API Management"
  type = object({
    enable_http2 = optional(bool)
  })
  default = null
}

variable "security" {
  description = "Security configuration for API Management"
  type = object({
    enable_backend_ssl30                                = optional(bool)
    enable_backend_tls10                                = optional(bool)
    enable_backend_tls11                                = optional(bool)
    enable_frontend_ssl30                               = optional(bool)
    enable_frontend_tls10                               = optional(bool)
    enable_frontend_tls11                               = optional(bool)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool)
    triple_des_ciphers_enabled                          = optional(bool)
  })
  default = null
}

# Sign-in and Sign-up
variable "sign_in" {
  description = "Sign-in settings for the developer portal"
  type = object({
    enabled = bool
  })
  default = null
}

variable "sign_up" {
  description = "Sign-up settings for the developer portal"
  type = object({
    enabled = bool
    terms_of_service = object({
      consent_required = bool
      enabled          = bool
      text             = optional(string)
    })
  })
  default = null
}

# Delegation
variable "delegation" {
  description = "Delegation settings for developer portal"
  type = object({
    subscriptions_enabled     = optional(bool)
    user_registration_enabled = optional(bool)
    url                       = optional(string)
    validation_key            = optional(string)
  })
  default = null
}

# Tenant Access
variable "tenant_access" {
  description = "Tenant access configuration"
  type = object({
    enabled = bool
  })
  default = null
}

# Hostname Configuration
variable "hostname_configurations" {
  description = "Custom hostname configurations for API Management endpoints"
  type = list(object({
    type                       = string # management, portal, developer_portal, proxy, scm, gateway
    host_name                  = string
    key_vault_id              = optional(string)
    certificate               = optional(string)
    certificate_password      = optional(string)
    negotiate_client_certificate = optional(bool)
    ssl_keyvault_identity_client_id = optional(string)
  }))
  default = []
}

# Certificates
variable "certificates" {
  description = "List of certificates to be used by API Management"
  type = list(object({
    encoded_certificate  = string
    certificate_password = optional(string)
    store_name           = string
  }))
  default = []
}

# Additional Locations (for multi-region deployments)
variable "additional_locations" {
  description = "List of additional Azure regions to deploy API Management"
  type = list(object({
    location             = string
    capacity             = optional(number)
    zones                = optional(list(string))
    public_ip_address_id = optional(string)
    virtual_network_configuration = optional(object({
      subnet_id = string
    }))
    gateway_disabled = optional(bool)
  }))
  default = []
}

# Policy Configuration
variable "policy" {
  description = "Global policy configuration for API Management"
  type = object({
    xml_content = optional(string)
    xml_link    = optional(string)
  })
  default = null
}

# Notification Sender Email
variable "notification_sender_email" {
  description = "Email address from which the notification will be sent"
  type        = string
  default     = null
}

# Private Endpoint Configuration
variable "create_private_endpoint" {
  description = "Whether to create a private endpoint for the API Management Service"
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
  description = "Private DNS zone group configuration for API Management private endpoint"
  type = object({
    name                 = string
    private_dns_zone_ids = list(string)
  })
  default = null
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
