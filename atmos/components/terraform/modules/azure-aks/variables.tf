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
# Azure Kubernetes Service Variables
####################

variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster"
  type        = string
}

variable "location" {
  description = "The Azure Region where the AKS cluster should exist"
  type        = string
}

variable "cluster_name" {
  description = "Override the AKS cluster name. If not provided, the name will be generated using the label module"
  type        = string
  default     = null
}

variable "add_random_suffix" {
  description = "Add a random suffix to the AKS cluster name for uniqueness"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be one of: Free, Standard, Premium"
  }
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster. If not provided, the cluster name will be used"
  type        = string
  default     = null
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist"
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Either the ID of Private DNS Zone which should be delegated to this Cluster, or System to have AKS manage this"
  type        = string
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Specifies whether a Public FQDN for this Private Cluster should be added"
  type        = bool
  default     = false
}

variable "api_server_access_profile" {
  description = "API Server Access Profile configuration. Note: In v4.x, vnet_integration_enabled is deprecated - VNet integration is automatic when subnet_id is provided"
  type = object({
    authorized_ip_ranges = list(string)
    subnet_id            = string
  })
  default = null
}

####################
# Default Node Pool Configuration
####################

variable "default_node_pool" {
  description = "Default node pool configuration. Note: In v4.x, node_taints is not supported in default_node_pool - only in additional node pools"
  type = object({
    name                         = string
    vm_size                      = string
    vnet_subnet_id               = string
    zones                        = list(string)
    enable_auto_scaling          = bool
    enable_host_encryption       = bool
    enable_node_public_ip        = bool
    max_pods                     = number
    node_labels                  = map(string)
    only_critical_addons_enabled = bool
    orchestrator_version         = string
    os_disk_size_gb              = number
    os_disk_type                 = string
    os_sku                       = string
    pod_subnet_id                = string
    scale_down_mode              = string
    type                         = string
    ultra_ssd_enabled            = bool
    node_count                   = number
    min_count                    = number
    max_count                    = number
    upgrade_settings = object({
      max_surge = string
    })
  })
}

####################
# Additional Node Pools
####################

variable "additional_node_pools" {
  description = "Map of additional node pools to create"
  type = map(object({
    vm_size                      = string
    vnet_subnet_id               = string
    zones                        = list(string)
    enable_auto_scaling          = bool
    enable_host_encryption       = bool
    enable_node_public_ip        = bool
    max_pods                     = number
    mode                         = string
    node_labels                  = map(string)
    node_taints                  = list(string)
    orchestrator_version         = string
    os_disk_size_gb              = number
    os_disk_type                 = string
    os_sku                       = string
    os_type                      = string
    pod_subnet_id                = string
    priority                     = string
    proximity_placement_group_id = string
    scale_down_mode              = string
    snapshot_id                  = string
    spot_max_price               = number
    ultra_ssd_enabled            = bool
    node_count                   = number
    min_count                    = number
    max_count                    = number
    tags                         = map(string)
    upgrade_settings = object({
      max_surge = string
    })
  }))
  default = {}
}

####################
# Identity Configuration
####################

variable "identity_type" {
  description = "The type of identity used for the managed cluster. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned"
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned"
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster"
  type        = list(string)
  default     = []
}

####################
# Network Configuration
####################

variable "network_profile" {
  description = "Network profile configuration for the AKS cluster"
  type = object({
    network_plugin    = string
    network_mode      = string
    network_policy    = string
    dns_service_ip    = string
    service_cidr      = string
    pod_cidr          = string
    outbound_type     = string
    load_balancer_sku = string
    load_balancer_profile = object({
      idle_timeout_in_minutes     = number
      managed_outbound_ip_count   = number
      managed_outbound_ipv6_count = number
      outbound_ip_address_ids     = list(string)
      outbound_ip_prefix_ids      = list(string)
      outbound_ports_allocated    = number
    })
  })
}

####################
# Azure AD RBAC Configuration
####################

variable "azure_ad_rbac" {
  description = "Azure Active Directory role-based access control configuration. Note: In v4.x, managed is deprecated - Azure AD integration is always managed"
  type = object({
    tenant_id              = string
    admin_group_object_ids = list(string)
    azure_rbac_enabled     = bool
  })
  default = null
}

variable "role_based_access_control_enabled" {
  description = "Whether Role Based Access Control for the Kubernetes Cluster should be enabled"
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "If true local accounts will be disabled"
  type        = bool
  default     = false
}

####################
# Auto Scaler Configuration
####################

variable "auto_scaler_profile" {
  description = "Auto scaler profile configuration"
  type = object({
    balance_similar_node_groups      = bool
    expander                         = string
    max_graceful_termination_sec     = number
    max_node_provisioning_time       = string
    max_unready_nodes                = number
    max_unready_percentage           = number
    new_pod_scale_up_delay           = string
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scan_interval                    = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
    empty_bulk_delete_max            = number
    skip_nodes_with_local_storage    = bool
    skip_nodes_with_system_pods      = bool
  })
  default = null
}

####################
# Monitoring and Add-ons
####################

variable "oms_agent" {
  description = "OMS Agent (Azure Monitor) configuration"
  type = object({
    log_analytics_workspace_id      = string
    msi_auth_for_monitoring_enabled = bool
  })
  default = null
}

variable "azure_policy_enabled" {
  description = "Should Azure Policy Add-On be enabled?"
  type        = bool
  default     = false
}

# Note: http_application_routing_enabled is deprecated in AzureRM v4.x
# The HTTP Application Routing add-on is being retired by Azure
# Migrate to Azure Application Gateway Ingress Controller (AGIC) or nginx ingress controller
variable "http_application_routing_enabled" {
  description = "DEPRECATED: HTTP Application Routing add-on is being retired. Use AGIC or nginx ingress instead. This variable is ignored in provider v4.x"
  type        = bool
  default     = false
}

####################
# Key Vault Secrets Provider
####################

variable "key_vault_secrets_provider" {
  description = "Key Vault Secrets Provider configuration"
  type = object({
    secret_rotation_enabled  = bool
    secret_rotation_interval = string
  })
  default = null
}

####################
# Kubelet Identity
####################

variable "kubelet_identity" {
  description = "Kubelet identity configuration"
  type = object({
    client_id                 = string
    object_id                 = string
    user_assigned_identity_id = string
  })
  default = null
}

####################
# Linux Profile
####################

variable "linux_profile" {
  description = "Linux profile configuration for SSH access"
  type = object({
    admin_username = string
    ssh_key        = string
  })
  default = null
}

####################
# Windows Profile
####################

variable "windows_profile" {
  description = "Windows profile configuration for Windows node pools"
  type = object({
    admin_username = string
    admin_password = string
    license        = string
  })
  default = null
}

####################
# Maintenance Window
####################

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = list(object({
      start = string
      end   = string
    }))
  })
  default = null
}

####################
# Upgrade Configuration
####################

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable"
  type        = string
  default     = null

  validation {
    condition     = var.automatic_channel_upgrade == null || contains(["patch", "rapid", "node-image", "stable", "none"], var.automatic_channel_upgrade)
    error_message = "automatic_channel_upgrade must be one of: patch, rapid, node-image, stable, none"
  }
}

variable "node_os_channel_upgrade" {
  description = "The upgrade channel for the node OS. Possible values are NodeImage, None, SecurityPatch and Unmanaged"
  type        = string
  default     = null

  validation {
    condition     = var.node_os_channel_upgrade == null || contains(["NodeImage", "None", "SecurityPatch", "Unmanaged"], var.node_os_channel_upgrade)
    error_message = "node_os_channel_upgrade must be one of: NodeImage, None, SecurityPatch, Unmanaged"
  }
}

####################
# Image Cleaner
####################

variable "image_cleaner_enabled" {
  description = "Specifies whether Image Cleaner is enabled"
  type        = bool
  default     = false
}

variable "image_cleaner_interval_hours" {
  description = "Specifies the interval in hours when images should be cleaned up"
  type        = number
  default     = 48
}

####################
# Workload Identity
####################

variable "workload_identity_enabled" {
  description = "Specifies whether Azure AD Workload Identity should be enabled for the Cluster"
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable or Disable the OIDC issuer URL"
  type        = bool
  default     = false
}

####################
# Security
####################

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used for the Nodes and Volumes"
  type        = string
  default     = null
}

variable "run_command_enabled" {
  description = "Whether to enable run command for the cluster"
  type        = bool
  default     = true
}

####################
# Storage Profile
####################

variable "storage_profile" {
  description = "Storage profile configuration. Note: In v4.x, disk_driver_version is deprecated - version is managed automatically"
  type = object({
    blob_driver_enabled         = bool
    disk_driver_enabled         = bool
    file_driver_enabled         = bool
    snapshot_controller_enabled = bool
  })
  default = null
}
