# Azure Kubernetes Service (AKS) Terraform Module

This Terraform module creates and manages an Azure Kubernetes Service (AKS) cluster with support for advanced features including private clusters, multiple node pools, auto-scaling, monitoring, security features, and more.

## Features

- **Multiple SKU Tiers**: Free, Standard, and Premium tiers
- **Private Cluster Support**: API server accessible only via private IP addresses
- **Multiple Node Pools**: System and user node pools with independent configurations
- **Auto-Scaling**: Horizontal pod autoscaler and cluster autoscaler support
- **Network Flexibility**: Azure CNI, Kubenet, Azure CNI Overlay support
- **Security Features**: Azure AD integration, RBAC, private cluster, authorized IP ranges
- **Monitoring Integration**: Azure Monitor Container Insights support
- **Identity Management**: System-assigned and user-assigned managed identities
- **Workload Identity**: Azure AD Workload Identity for pod authentication
- **Add-ons Support**: Azure Policy, Key Vault Secrets Provider, OMS Agent
- **Upgrade Management**: Automatic channel upgrades and maintenance windows
- **Zone Redundancy**: High availability across availability zones
- **Consistent Naming**: Integration with CloudPosse label module
- **Storage Flexibility**: Support for Azure Disk, File, Blob CSI drivers

## Usage

### Basic AKS Cluster

```yaml
components:
  terraform:
    azure-aks-basic:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-vnet"
          3:
            component: "azure-subnet"
      vars:
        name: "cluster"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        kubernetes_version: "1.28.0"

        default_node_pool:
          name: "system"
          vm_size: "Standard_D2s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          zones: ["1", "2", "3"]
          enable_auto_scaling: true
          min_count: 3
          max_count: 10
          node_count: 3
          max_pods: 30
          os_disk_size_gb: 100
          os_disk_type: "Managed"
          os_sku: "Ubuntu"
          type: "VirtualMachineScaleSets"

        network_profile:
          network_plugin: "azure"
          network_policy: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
```

### Production AKS Cluster with Multiple Node Pools

```yaml
components:
  terraform:
    azure-aks-prod:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-vnet"
          3:
            component: "azure-subnet"
          4:
            component: "azure-log-analytics"
      vars:
        name: "prod"
        attributes: ["cluster"]
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        kubernetes_version: "1.28.0"
        sku_tier: "Standard"

        # System node pool
        default_node_pool:
          name: "system"
          vm_size: "Standard_D4s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          zones: ["1", "2", "3"]
          enable_auto_scaling: true
          min_count: 3
          max_count: 6
          node_count: 3
          max_pods: 30
          os_disk_size_gb: 128
          os_disk_type: "Managed"
          os_sku: "Ubuntu"
          only_critical_addons_enabled: true
          type: "VirtualMachineScaleSets"
          node_labels:
            role: "system"
          upgrade_settings:
            max_surge: "33%"

        # Additional user node pools
        additional_node_pools:
          apps:
            vm_size: "Standard_D8s_v3"
            vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
            zones: ["1", "2", "3"]
            enable_auto_scaling: true
            min_count: 2
            max_count: 10
            node_count: 2
            mode: "User"
            max_pods: 50
            os_disk_size_gb: 256
            os_disk_type: "Managed"
            os_sku: "Ubuntu"
            node_labels:
              workload: "apps"
            upgrade_settings:
              max_surge: "33%"

          memory:
            vm_size: "Standard_E8s_v3"
            vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
            zones: ["1", "2"]
            enable_auto_scaling: true
            min_count: 1
            max_count: 5
            node_count: 1
            mode: "User"
            max_pods: 30
            node_labels:
              workload: "memory-intensive"
            node_taints:
              - "workload=memory:NoSchedule"

        # Network configuration
        network_profile:
          network_plugin: "azure"
          network_policy: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
          load_balancer_profile:
            managed_outbound_ip_count: 2

        # Azure AD RBAC
        azure_ad_rbac:
          managed: true
          azure_rbac_enabled: true
          admin_group_object_ids:
            - "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

        # Monitoring
        oms_agent:
          log_analytics_workspace_id: !terraform.output azure-log-analytics ".workspace_id"
          msi_auth_for_monitoring_enabled: true

        # Security
        azure_policy_enabled: true
        workload_identity_enabled: true
        oidc_issuer_enabled: true

        # Upgrades
        automatic_channel_upgrade: "stable"
        node_os_channel_upgrade: "NodeImage"
```

### Private AKS Cluster

```yaml
components:
  terraform:
    azure-aks-private:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-vnet"
          3:
            component: "azure-subnet"
          4:
            component: "azure-private-dns-zone"
      vars:
        name: "private"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"

        # Private cluster configuration
        private_cluster_enabled: true
        private_dns_zone_id: !terraform.output azure-private-dns-zone ".id"
        private_cluster_public_fqdn_enabled: false

        # API server access restrictions
        api_server_access_profile:
          authorized_ip_ranges:
            - "203.0.113.0/24"
            - "198.51.100.0/24"
          subnet_id: null
          vnet_integration_enabled: false

        default_node_pool:
          name: "system"
          vm_size: "Standard_D4s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          zones: ["1", "2", "3"]
          enable_auto_scaling: true
          min_count: 3
          max_count: 6
          node_count: 3
          enable_node_public_ip: false

        network_profile:
          network_plugin: "azure"
          network_policy: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
          outbound_type: "userDefinedRouting"
```

### AKS with Spot Node Pools

```yaml
components:
  terraform:
    azure-aks-spot:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-subnet"
      vars:
        name: "costopt"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"

        default_node_pool:
          name: "system"
          vm_size: "Standard_D2s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          enable_auto_scaling: true
          min_count: 2
          max_count: 4
          node_count: 2

        additional_node_pools:
          spot:
            vm_size: "Standard_D8s_v3"
            vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
            enable_auto_scaling: true
            min_count: 0
            max_count: 10
            node_count: 2
            priority: "Spot"
            spot_max_price: -1  # Pay up to on-demand price
            mode: "User"
            node_labels:
              kubernetes.azure.com/scalesetpriority: "spot"
            node_taints:
              - "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"

        network_profile:
          network_plugin: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
```

### AKS with Windows Node Pools

```yaml
components:
  terraform:
    azure-aks-windows:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-subnet"
      vars:
        name: "windows"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"

        # Windows profile required for Windows node pools
        windows_profile:
          admin_username: "azureuser"
          admin_password: "P@ssw0rd1234!"  # Use secure password from Key Vault
          license: "Windows_Server"

        default_node_pool:
          name: "system"
          vm_size: "Standard_D2s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          enable_auto_scaling: true
          min_count: 2
          max_count: 4
          os_sku: "Ubuntu"

        additional_node_pools:
          winsrv:
            vm_size: "Standard_D4s_v3"
            vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
            os_type: "Windows"
            os_sku: "Windows2022"
            enable_auto_scaling: true
            min_count: 1
            max_count: 5
            mode: "User"

        network_profile:
          network_plugin: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
```

### AKS with Key Vault Secrets Provider

```yaml
components:
  terraform:
    azure-aks-keyvault:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-subnet"
      vars:
        name: "secure"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"

        default_node_pool:
          name: "system"
          vm_size: "Standard_D2s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          enable_auto_scaling: true
          min_count: 2
          max_count: 4

        # Enable Key Vault Secrets Provider
        key_vault_secrets_provider:
          secret_rotation_enabled: true
          secret_rotation_interval: "2m"

        # Enable workload identity for pods
        workload_identity_enabled: true
        oidc_issuer_enabled: true

        network_profile:
          network_plugin: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
```

### AKS with Maintenance Window

```yaml
components:
  terraform:
    azure-aks-maintenance:
      metadata:
        component: azure-aks
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-subnet"
      vars:
        name: "managed"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"

        default_node_pool:
          name: "system"
          vm_size: "Standard_D2s_v3"
          vnet_subnet_id: !terraform.output azure-subnet ".subnet_id"
          enable_auto_scaling: true
          min_count: 3
          max_count: 6

        # Maintenance window - updates only on weekends
        maintenance_window:
          allowed:
            - day: "Saturday"
              hours: [0, 1, 2, 3, 4, 5]
            - day: "Sunday"
              hours: [0, 1, 2, 3, 4, 5]
          not_allowed:
            - start: "2024-12-20T00:00:00Z"
              end: "2024-12-27T00:00:00Z"  # Holiday freeze

        automatic_channel_upgrade: "stable"
        node_os_channel_upgrade: "NodeImage"

        network_profile:
          network_plugin: "azure"
          service_cidr: "10.100.0.0/16"
          dns_service_ip: "10.100.0.10"
          load_balancer_sku: "standard"
```

## SKU Tier Comparison

| Feature | Free | Standard | Premium |
|---------|------|----------|---------|
| SLA | None | 99.95% (with AZ) | 99.95% (with AZ) |
| API Server Uptime | Best effort | Guaranteed | Guaranteed |
| Max Node Pools | 100 | 100 | 100 |
| Max Nodes per Cluster | 1000 | 5000 | 5000 |
| Best For | Dev/Test | Production | Enterprise |

## Network Plugin Comparison

| Feature | Kubenet | Azure CNI | Azure CNI Overlay |
|---------|---------|-----------|-------------------|
| Pod IP Source | NAT | VNet | Overlay Network |
| IP Address Efficiency | High | Low | High |
| Performance | Good | Best | Good |
| Network Policy | Calico | Azure/Calico | Azure/Calico |
| Windows Support | ❌ | ✅ | ✅ |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | >= 4.0.0 |
| random | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.0.0 |
| random | >= 3.0.0 |

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| resource_group_name | The name of the resource group | `string` |
| location | The Azure Region | `string` |
| default_node_pool | Default node pool configuration | `object` |
| network_profile | Network profile configuration | `object` |

### Label Module Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enabled | Set to false to prevent module from creating resources | `bool` | `true` |
| namespace | Organization name abbreviation | `string` | `null` |
| environment | Environment name | `string` | `null` |
| stage | Stage (e.g., prod, dev) | `string` | `null` |
| name | Solution name | `string` | `null` |
| attributes | Additional attributes | `list(string)` | `[]` |
| delimiter | Delimiter for ID elements | `string` | `"-"` |
| tags | Additional tags | `map(string)` | `{}` |

### AKS Cluster Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_name | Override the cluster name | `string` | `null` |
| add_random_suffix | Add random suffix for uniqueness | `bool` | `false` |
| kubernetes_version | Kubernetes version | `string` | `null` |
| sku_tier | SKU tier (Free, Standard, Premium) | `string` | `"Free"` |
| dns_prefix | DNS prefix | `string` | `null` |
| node_resource_group | Node resource group name | `string` | `null` |
| private_cluster_enabled | Enable private cluster | `bool` | `false` |
| private_dns_zone_id | Private DNS zone ID | `string` | `null` |
| api_server_access_profile | API server access configuration | `object` | `null` |
| additional_node_pools | Additional node pools | `map(object)` | `{}` |
| identity_type | Managed identity type | `string` | `"SystemAssigned"` |
| identity_ids | User-assigned identity IDs | `list(string)` | `[]` |
| azure_ad_rbac | Azure AD RBAC configuration | `object` | `null` |
| role_based_access_control_enabled | Enable RBAC | `bool` | `true` |
| local_account_disabled | Disable local accounts | `bool` | `false` |
| auto_scaler_profile | Auto scaler configuration | `object` | `null` |
| oms_agent | Azure Monitor configuration | `object` | `null` |
| azure_policy_enabled | Enable Azure Policy add-on | `bool` | `false` |
| key_vault_secrets_provider | Key Vault Secrets Provider config | `object` | `null` |
| workload_identity_enabled | Enable workload identity | `bool` | `false` |
| oidc_issuer_enabled | Enable OIDC issuer | `bool` | `false` |
| automatic_channel_upgrade | Automatic upgrade channel | `string` | `null` |
| node_os_channel_upgrade | Node OS upgrade channel | `string` | `null` |
| maintenance_window | Maintenance window configuration | `object` | `null` |
| disk_encryption_set_id | Disk encryption set ID | `string` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the Kubernetes Cluster |
| cluster_name | The name of the Kubernetes Cluster |
| cluster_fqdn | The FQDN of the Kubernetes Cluster |
| private_fqdn | The private FQDN |
| kube_config | Raw Kubernetes config (sensitive) |
| kube_admin_config | Raw Kubernetes admin config (sensitive) |
| host | Kubernetes cluster server host (sensitive) |
| node_resource_group | Node resource group name |
| identity_principal_id | System assigned identity principal ID |
| kubelet_identity_object_id | Kubelet identity object ID |
| kubelet_identity_client_id | Kubelet identity client ID |
| oidc_issuer_url | OIDC issuer URL |
| current_kubernetes_version | Current Kubernetes version |
| additional_node_pool_ids | Map of node pool IDs |
| tags | Applied tags |
| context | Exported label context |

## Best Practices

### Security

1. **Enable Private Cluster**: Restrict API server access for production
2. **Use Azure AD Integration**: Enable managed Azure AD RBAC
3. **Disable Local Accounts**: Force Azure AD authentication
4. **Enable Workload Identity**: Use for pod-to-Azure authentication
5. **Use Network Policies**: Restrict pod-to-pod communication
6. **Enable Azure Policy**: Enforce security policies
7. **Use Authorized IP Ranges**: Limit API server access

### High Availability

1. **Use Standard/Premium SKU**: Get SLA guarantee
2. **Enable Zone Redundancy**: Spread nodes across availability zones
3. **Multiple Node Pools**: Separate system and user workloads
4. **Enable Auto-Scaling**: Handle load variations
5. **Configure Maintenance Windows**: Control update timing

### Performance

1. **Use Azure CNI**: Better network performance
2. **Optimize Node Sizes**: Match VM size to workload
3. **Configure Max Pods**: Balance density and performance
4. **Use Proximity Placement Groups**: Reduce latency
5. **Enable Accelerated Networking**: Improve network throughput

### Cost Optimization

1. **Use Free Tier**: For dev/test environments
2. **Enable Cluster Autoscaler**: Scale down when not needed
3. **Use Spot Instances**: For fault-tolerant workloads
4. **Right-size Node Pools**: Don't over-provision
5. **Monitor Resource Usage**: Identify optimization opportunities

## Common Use Cases

### Development Cluster

```yaml
azure-aks-dev:
  vars:
    name: "dev"
    sku_tier: "Free"
    default_node_pool:
      enable_auto_scaling: true
      min_count: 1
      max_count: 3
      vm_size: "Standard_B2s"
```

### Production Cluster

```yaml
azure-aks-prod:
  vars:
    name: "prod"
    sku_tier: "Standard"
    private_cluster_enabled: true
    azure_policy_enabled: true
    workload_identity_enabled: true
    default_node_pool:
      enable_auto_scaling: true
      min_count: 3
      max_count: 10
      zones: ["1", "2", "3"]
```

### Multi-Tenant Cluster

```yaml
azure-aks-multitenant:
  vars:
    name: "shared"
    sku_tier: "Standard"
    azure_ad_rbac:
      managed: true
      azure_rbac_enabled: true
    additional_node_pools:
      tenant1:
        mode: "User"
        node_taints: ["tenant=1:NoSchedule"]
      tenant2:
        mode: "User"
        node_taints: ["tenant=2:NoSchedule"]
```

## Related Documentation

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [AKS Network Concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [AKS Security Best Practices](https://docs.microsoft.com/en-us/azure/aks/concepts-security)
- [AKS Workload Identity](https://docs.microsoft.com/en-us/azure/aks/workload-identity-overview)

## Notes

- System node pools should run only critical system pods
- Windows node pools require a Windows profile to be configured
- Private clusters require additional DNS configuration
- Spot node pools should only be used for interruptible workloads
- Node pool names must start with a lowercase letter and contain only lowercase letters and numbers
- Maximum 12 characters for node pool names
- Cluster autoscaler and horizontal pod autoscaler work together
- Consider using maintenance windows for production clusters
- Workload identity is the recommended approach for pod authentication to Azure services
