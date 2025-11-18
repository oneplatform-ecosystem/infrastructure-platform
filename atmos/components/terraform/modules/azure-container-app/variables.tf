# General Variables
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container App"
  type        = string
}

variable "location" {
  description = "The Azure region where the Container App should exist"
  type        = string
}

# Container App Environment Variables
variable "create_environment" {
  description = "Whether to create a new Container App Environment. If false, environment_id must be provided"
  type        = bool
  default     = true
}

variable "environment_name" {
  description = "Custom name for the Container App Environment. If not provided, will use the label module generated ID with '-env' suffix"
  type        = string
  default     = null
}

variable "environment_id" {
  description = "The ID of an existing Container App Environment. Required if create_environment is false"
  type        = string
  default     = null
}

variable "infrastructure_subnet_id" {
  description = "The subnet ID for the Container App Environment infrastructure"
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Should the Container App Environment operate in Internal Load Balancing Mode?"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Should the Container App Environment be zone redundant?"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for the Container App Environment"
  type        = string
  default     = null
}

variable "workload_profile" {
  description = "Workload profiles for the Container App Environment"
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number)
    maximum_count         = optional(number)
  }))
  default = []
}

# Container App Variables
variable "container_app_name" {
  description = "Custom name for the Container App. If not provided, will use the label module generated ID"
  type        = string
  default     = null
}

variable "revision_mode" {
  description = "The revision mode for the Container App. Possible values are Single and Multiple"
  type        = string
  default     = "Single"
  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "Revision mode must be either Single or Multiple"
  }
}

variable "workload_profile_name" {
  description = "The name of the workload profile to use for the Container App"
  type        = string
  default     = null
}

# Template Configuration
variable "min_replicas" {
  description = "The minimum number of replicas for the Container App"
  type        = number
  default     = 1
  validation {
    condition     = var.min_replicas >= 0 && var.min_replicas <= 300
    error_message = "Min replicas must be between 0 and 300"
  }
}

variable "max_replicas" {
  description = "The maximum number of replicas for the Container App"
  type        = number
  default     = 10
  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 300
    error_message = "Max replicas must be between 1 and 300"
  }
}

# Container Configuration
variable "containers" {
  description = "List of containers to run in the Container App"
  type = list(object({
    name    = string
    image   = string
    cpu     = number
    memory  = string
    args    = optional(list(string))
    command = optional(list(string))
    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })))
    liveness_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      host                    = optional(string)
      interval_seconds        = optional(number, 10)
      timeout                 = optional(number, 1)
      failure_count_threshold = optional(number, 3)
      initial_delay           = optional(number, 0)
      header = optional(list(object({
        name  = string
        value = string
      })))
    }))
    readiness_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      host                    = optional(string)
      interval_seconds        = optional(number, 10)
      timeout                 = optional(number, 1)
      failure_count_threshold = optional(number, 3)
      success_count_threshold = optional(number, 3)
      header = optional(list(object({
        name  = string
        value = string
      })))
    }))
    startup_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      host                    = optional(string)
      interval_seconds        = optional(number, 10)
      timeout                 = optional(number, 1)
      failure_count_threshold = optional(number, 3)
      header = optional(list(object({
        name  = string
        value = string
      })))
    }))
    volume_mounts = optional(list(object({
      name = string
      path = string
    })))
  }))
  default = []
}

# Ingress Configuration
variable "ingress" {
  description = "Ingress configuration for the Container App"
  type = object({
    external_enabled           = optional(bool, false)
    target_port                = number
    transport                  = optional(string, "auto")
    allow_insecure_connections = optional(bool, false)
    exposed_port               = optional(number)
    traffic_weight = optional(list(object({
      label           = optional(string)
      latest_revision = optional(bool, false)
      revision_suffix = optional(string)
      percentage      = number
    })))
    custom_domain = optional(list(object({
      name                     = string
      certificate_binding_type = optional(string)
      certificate_id           = optional(string)
    })))
    ip_security_restriction = optional(list(object({
      name             = string
      ip_address_range = string
      description      = optional(string)
      action           = string
    })))
  })
  default = null
}

# Dapr Configuration
variable "dapr" {
  description = "Dapr configuration for the Container App"
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string, "http")
  })
  default = null
}

# Identity Configuration
variable "identity_type" {
  description = "The type of Managed Service Identity. Possible values are SystemAssigned, UserAssigned"
  type        = string
  default     = null
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be either SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned"
  }
}

variable "identity_ids" {
  description = "A list of User Assigned Managed Identity IDs to be assigned to this Container App"
  type        = list(string)
  default     = null
}

# Registry Configuration
variable "registry" {
  description = "Container registry configuration for the Container App"
  type = list(object({
    server               = string
    username             = optional(string)
    password_secret_name = optional(string)
    identity             = optional(string)
  }))
  default = []
}

# Secrets Configuration
variable "secrets" {
  description = "Secrets for the Container App. Note: values are sensitive"
  type = list(object({
    name                = string
    value               = optional(string)
    identity            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default   = []
  sensitive = true
}

# Scale Rules
variable "scale_rules" {
  description = "Scale rules for the Container App"
  type = list(object({
    name = string
    azure_queue = optional(object({
      queue_name   = string
      queue_length = number
      account_name = string
    }))
    custom = optional(object({
      type     = string
      metadata = map(string)
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })))
    }))
    http = optional(object({
      concurrent_requests = number
    }))
    tcp = optional(object({
      concurrent_requests = number
    }))
  }))
  default = []
}

# Volume Configuration
variable "volumes" {
  description = "Volumes for the Container App"
  type = list(object({
    name         = string
    storage_type = optional(string, "EmptyDir")
    storage_name = optional(string)
  }))
  default = []
}

# Init Containers
variable "init_containers" {
  description = "Init containers for the Container App"
  type = list(object({
    name    = string
    image   = string
    cpu     = optional(number)
    memory  = optional(string)
    args    = optional(list(string))
    command = optional(list(string))
    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })))
    volume_mounts = optional(list(object({
      name = string
      path = string
    })))
  }))
  default = []
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
