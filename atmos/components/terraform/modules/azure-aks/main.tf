####################
# Label Module
####################

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled     = var.enabled
  namespace   = var.namespace
  tenant      = var.tenant
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags

  label_order         = var.label_order
  regex_replace_chars = var.regex_replace_chars
  id_length_limit     = var.id_length_limit
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case

  additional_tag_map = var.additional_tag_map
  context            = var.context
}

####################
# Random Suffix (for global uniqueness)
####################

resource "random_string" "suffix" {
  count   = var.enabled && var.add_random_suffix ? 1 : 0
  length  = 4
  special = false
  upper   = false
}

locals {
  aks_name = var.enabled ? (
    var.add_random_suffix ?
    "${module.label.id}${try(random_string.suffix[0].result, "")}" :
    coalesce(var.cluster_name, module.label.id)
  ) : ""
}

####################
# Azure Kubernetes Service
####################

resource "azurerm_kubernetes_cluster" "this" {
  count = var.enabled ? 1 : 0

  name                = local.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = coalesce(var.dns_prefix, local.aks_name)
  kubernetes_version  = var.kubernetes_version

  # SKU Configuration
  sku_tier = var.sku_tier

  # Node Resource Group
  node_resource_group = var.node_resource_group

  # Private Cluster Configuration
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  # API Server Access
  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [var.api_server_access_profile] : []
    content {
      authorized_ip_ranges     = api_server_access_profile.value.authorized_ip_ranges
      subnet_id                = api_server_access_profile.value.subnet_id
      vnet_integration_enabled = api_server_access_profile.value.vnet_integration_enabled
    }
  }

  # Default Node Pool
  default_node_pool {
    name                         = var.default_node_pool.name
    vm_size                      = var.default_node_pool.vm_size
    vnet_subnet_id               = var.default_node_pool.vnet_subnet_id
    zones                        = var.default_node_pool.zones
    enable_auto_scaling          = var.default_node_pool.enable_auto_scaling
    enable_host_encryption       = var.default_node_pool.enable_host_encryption
    enable_node_public_ip        = var.default_node_pool.enable_node_public_ip
    max_pods                     = var.default_node_pool.max_pods
    node_labels                  = var.default_node_pool.node_labels
    node_taints                  = var.default_node_pool.node_taints
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    orchestrator_version         = var.default_node_pool.orchestrator_version
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    os_sku                       = var.default_node_pool.os_sku
    pod_subnet_id                = var.default_node_pool.pod_subnet_id
    scale_down_mode              = var.default_node_pool.scale_down_mode
    type                         = var.default_node_pool.type
    ultra_ssd_enabled            = var.default_node_pool.ultra_ssd_enabled

    # Auto-scaling configuration
    min_count  = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count  = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
    node_count = var.default_node_pool.enable_auto_scaling ? null : var.default_node_pool.node_count

    # Upgrade settings
    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings != null ? [var.default_node_pool.upgrade_settings] : []
      content {
        max_surge = upgrade_settings.value.max_surge
      }
    }

    tags = module.label.tags
  }

  # Identity
  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  # Network Profile
  network_profile {
    network_plugin    = var.network_profile.network_plugin
    network_mode      = var.network_profile.network_mode
    network_policy    = var.network_profile.network_policy
    dns_service_ip    = var.network_profile.dns_service_ip
    service_cidr      = var.network_profile.service_cidr
    pod_cidr          = var.network_profile.pod_cidr
    outbound_type     = var.network_profile.outbound_type
    load_balancer_sku = var.network_profile.load_balancer_sku

    # Load Balancer Profile
    dynamic "load_balancer_profile" {
      for_each = var.network_profile.load_balancer_profile != null ? [var.network_profile.load_balancer_profile] : []
      content {
        idle_timeout_in_minutes     = load_balancer_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count   = load_balancer_profile.value.managed_outbound_ip_count
        managed_outbound_ipv6_count = load_balancer_profile.value.managed_outbound_ipv6_count
        outbound_ip_address_ids     = load_balancer_profile.value.outbound_ip_address_ids
        outbound_ip_prefix_ids      = load_balancer_profile.value.outbound_ip_prefix_ids
        outbound_ports_allocated    = load_balancer_profile.value.outbound_ports_allocated
      }
    }
  }

  # Azure Active Directory RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_ad_rbac != null ? [var.azure_ad_rbac] : []
    content {
      managed                = azure_active_directory_role_based_access_control.value.managed
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
    }
  }

  # RBAC
  role_based_access_control_enabled = var.role_based_access_control_enabled
  local_account_disabled            = var.local_account_disabled

  # Auto Scaler Profile
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      expander                         = auto_scaler_profile.value.expander
      max_graceful_termination_sec     = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time       = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage           = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay           = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add       = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete    = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure   = auto_scaler_profile.value.scale_down_delay_after_failure
      scan_interval                    = auto_scaler_profile.value.scan_interval
      scale_down_unneeded              = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready               = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      empty_bulk_delete_max            = auto_scaler_profile.value.empty_bulk_delete_max
      skip_nodes_with_local_storage    = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  # Azure Monitor
  dynamic "oms_agent" {
    for_each = var.oms_agent != null ? [var.oms_agent] : []
    content {
      log_analytics_workspace_id      = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = oms_agent.value.msi_auth_for_monitoring_enabled
    }
  }

  # Azure Policy
  azure_policy_enabled = var.azure_policy_enabled

  # Note: http_application_routing_enabled is deprecated in AzureRM v4.x
  # HTTP Application Routing add-on is being retired and should not be used for new deployments
  # Use Azure Application Gateway Ingress Controller (AGIC) or nginx ingress controller instead

  # Key Vault Secrets Provider
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  # Kubelet Identity
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [var.kubelet_identity] : []
    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }

  # Linux Profile
  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [var.linux_profile] : []
    content {
      admin_username = linux_profile.value.admin_username

      ssh_key {
        key_data = linux_profile.value.ssh_key
      }
    }
  }

  # Windows Profile
  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []
    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
      license        = windows_profile.value.license
    }
  }

  # Maintenance Window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  # Automatic Channel Upgrade
  automatic_channel_upgrade = var.automatic_channel_upgrade

  # Node OS Channel Upgrade
  node_os_channel_upgrade = var.node_os_channel_upgrade

  # Image Cleaner
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  # Workload Identity
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled

  # Disk Encryption
  disk_encryption_set_id = var.disk_encryption_set_id

  # Run Command
  run_command_enabled = var.run_command_enabled

  # Storage Profile
  dynamic "storage_profile" {
    for_each = var.storage_profile != null ? [var.storage_profile] : []
    content {
      blob_driver_enabled         = storage_profile.value.blob_driver_enabled
      disk_driver_enabled         = storage_profile.value.disk_driver_enabled
      disk_driver_version         = storage_profile.value.disk_driver_version
      file_driver_enabled         = storage_profile.value.file_driver_enabled
      snapshot_controller_enabled = storage_profile.value.snapshot_controller_enabled
    }
  }

  tags = module.label.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to Kubernetes version as it may be managed outside Terraform
      kubernetes_version,
      default_node_pool[0].orchestrator_version
    ]
  }
}

####################
# Additional Node Pools
####################

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.enabled ? var.additional_node_pools : {}

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this[0].id
  vm_size               = each.value.vm_size
  vnet_subnet_id        = each.value.vnet_subnet_id

  # Node configuration
  zones                        = each.value.zones
  enable_auto_scaling          = each.value.enable_auto_scaling
  enable_host_encryption       = each.value.enable_host_encryption
  enable_node_public_ip        = each.value.enable_node_public_ip
  max_pods                     = each.value.max_pods
  mode                         = each.value.mode
  node_labels                  = each.value.node_labels
  node_taints                  = each.value.node_taints
  orchestrator_version         = each.value.orchestrator_version
  os_disk_size_gb              = each.value.os_disk_size_gb
  os_disk_type                 = each.value.os_disk_type
  os_sku                       = each.value.os_sku
  os_type                      = each.value.os_type
  pod_subnet_id                = each.value.pod_subnet_id
  priority                     = each.value.priority
  proximity_placement_group_id = each.value.proximity_placement_group_id
  scale_down_mode              = each.value.scale_down_mode
  snapshot_id                  = each.value.snapshot_id
  spot_max_price               = each.value.spot_max_price
  ultra_ssd_enabled            = each.value.ultra_ssd_enabled

  # Auto-scaling configuration
  min_count  = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count  = each.value.enable_auto_scaling ? each.value.max_count : null
  node_count = each.value.enable_auto_scaling ? null : each.value.node_count

  # Upgrade settings
  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? [each.value.upgrade_settings] : []
    content {
      max_surge = upgrade_settings.value.max_surge
    }
  }

  tags = merge(module.label.tags, each.value.tags)

  lifecycle {
    ignore_changes = [
      # Ignore changes to orchestrator version as it may be managed outside Terraform
      orchestrator_version
    ]
  }
}
