# Azure Container Registry (ACR) Terraform Module

This Terraform module creates and manages an Azure Container Registry with support for advanced features including geo-replication, network rules, private endpoints, webhooks, and more.

## Features

- **Multiple SKU Support**: Basic, Standard, and Premium tiers
- **Geo-Replication**: Replicate registry across multiple Azure regions (Premium SKU)
- **Network Security**: Network rules, private endpoints, and firewall rules (Premium SKU)
- **Identity Management**: System-assigned and user-assigned managed identities
- **Encryption**: Customer-managed key encryption (Premium SKU)
- **Access Control**: Scope maps and tokens for fine-grained access control
- **Webhooks**: Event-driven notifications for registry operations
- **Retention Policies**: Automatic cleanup of untagged manifests (Premium SKU)
- **Trust Policies**: Content trust for signed images (Premium SKU)
- **Zone Redundancy**: High availability across availability zones (Premium SKU)
- **Consistent Naming**: Integration with CloudPosse label module
- **Global Uniqueness**: Optional random suffix for unique naming

## Usage

### Basic Container Registry

```yaml
components:
  terraform:
    azure-acr-basic:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
      vars:
        name: "containers"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Basic"
        admin_enabled: false
```

### Standard Container Registry with Admin Access

```yaml
components:
  terraform:
    azure-acr-standard:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
      vars:
        name: "devregistry"
        attributes: ["dev"]
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Standard"
        admin_enabled: true
        anonymous_pull_enabled: false
```

### Premium Container Registry with Network Rules

```yaml
components:
  terraform:
    azure-acr-premium:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-subnet"
      vars:
        name: "prodregistry"
        attributes: ["prod"]
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Premium"
        admin_enabled: false
        public_network_access_enabled: false
        zone_redundancy_enabled: true

        network_rule_set:
          default_action: "Deny"
          ip_rules:
            - action: "Allow"
              ip_range: "203.0.113.0/24"
          virtual_network_subnet_ids:
            - !terraform.output azure-subnet ".subnet_id"
```

### Premium Container Registry with Geo-Replication

```yaml
components:
  terraform:
    azure-acr-geo:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
      vars:
        name: "globalregistry"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Premium"
        zone_redundancy_enabled: true

        georeplications:
          - location: "westus2"
            zone_redundancy_enabled: true
            regional_endpoint_enabled: true
            tags: {}
          - location: "westeurope"
            zone_redundancy_enabled: true
            regional_endpoint_enabled: true
            tags: {}
```

### Premium Container Registry with Encryption

```yaml
components:
  terraform:
    azure-acr-encrypted:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-keyvault"
          3:
            component: "azure-user-assigned-identity"
      vars:
        name: "secure"
        attributes: ["encrypted"]
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Premium"

        identity_type: "UserAssigned"
        identity_ids:
          - !terraform.output azure-user-assigned-identity ".id"

        encryption:
          enabled: true
          key_vault_key_id: !terraform.output azure-keyvault ".key_id"
          identity_client_id: !terraform.output azure-user-assigned-identity ".client_id"
```

### Container Registry with Webhooks

```yaml
components:
  terraform:
    azure-acr-webhooks:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
      vars:
        name: "cicd"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Standard"

        webhooks:
          deployment-webhook:
            service_uri: "https://webhook.site/unique-url"
            status: "enabled"
            scope: "myapp:*"
            actions: ["push", "delete"]
            custom_headers:
              Authorization: "Bearer token123"
```

### Container Registry with Tokens and Scope Maps

```yaml
components:
  terraform:
    azure-acr-tokens:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
      vars:
        name: "apps"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Premium"

        scope_maps:
          readonly-scope:
            actions:
              - "repositories/*/content/read"
              - "repositories/*/metadata/read"

          app1-scope:
            actions:
              - "repositories/app1/content/read"
              - "repositories/app1/content/write"
              - "repositories/app1/metadata/read"

        tokens:
          readonly-token:
            scope_map_name: "readonly-scope"
            enabled: true

          app1-token:
            scope_map_name: "app1-scope"
            enabled: true
```

### Container Registry with Retention Policy

```yaml
components:
  terraform:
    azure-acr-retention:
      metadata:
        component: azure-acr
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
      vars:
        name: "cleanup"
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        sku: "Premium"

        retention_policy:
          days: 30
          enabled: true

        trust_policy:
          enabled: true
```

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GiB | 100 GiB | 500 GiB |
| Webhooks | 2 | 10 | 500 |
| Geo-replication | ❌ | ❌ | ✅ |
| Network Rules | ❌ | ❌ | ✅ |
| Private Endpoints | ❌ | ❌ | ✅ |
| Customer-managed keys | ❌ | ❌ | ✅ |
| Zone Redundancy | ❌ | ❌ | ✅ |
| Content Trust | ❌ | ❌ | ✅ |
| Retention Policies | ❌ | ❌ | ✅ |
| Anonymous Pull | ❌ | ✅ | ✅ |
| Tokens/Scope Maps | ✅ | ✅ | ✅ |

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

### Container Registry Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| container_registry_name | Override the registry name | `string` | `null` |
| add_random_suffix | Add random suffix for uniqueness | `bool` | `true` |
| sku | SKU name (Basic, Standard, Premium) | `string` | `"Standard"` |
| admin_enabled | Enable admin user | `bool` | `false` |
| public_network_access_enabled | Enable public network access | `bool` | `true` |
| quarantine_policy_enabled | Enable quarantine policy | `bool` | `false` |
| zone_redundancy_enabled | Enable zone redundancy | `bool` | `false` |
| export_policy_enabled | Enable export policy | `bool` | `true` |
| anonymous_pull_enabled | Allow anonymous pulls | `bool` | `false` |
| data_endpoint_enabled | Enable dedicated data endpoints | `bool` | `false` |
| network_rule_bypass_option | Network rule bypass (None, AzureServices) | `string` | `"AzureServices"` |
| identity_type | Managed identity type | `string` | `null` |
| identity_ids | User-assigned identity IDs | `list(string)` | `[]` |
| encryption | Encryption configuration | `object` | `null` |
| georeplications | Geo-replication locations | `list(object)` | `[]` |
| network_rule_set | Network rules configuration | `object` | `null` |
| retention_policy | Retention policy configuration | `object` | `null` |
| trust_policy | Trust policy configuration | `object` | `null` |
| scope_maps | Scope maps for access control | `map(object)` | `{}` |
| tokens | Access tokens | `map(object)` | `{}` |
| webhooks | Webhook configurations | `map(object)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| container_registry_id | The ID of the Container Registry |
| container_registry_name | The name of the Container Registry |
| login_server | The URL for logging into the registry |
| admin_username | Admin username (sensitive) |
| admin_password | Admin password (sensitive) |
| identity_principal_id | Managed identity principal ID |
| identity_tenant_id | Managed identity tenant ID |
| sku | The SKU name |
| resource_group_name | Resource group name |
| location | Azure region |
| scope_map_ids | Map of scope map IDs |
| token_ids | Map of token IDs |
| webhook_ids | Map of webhook IDs |
| tags | Applied tags |
| context | Exported label context |

## Best Practices

### Security

1. **Disable Admin User**: Use Azure AD authentication instead of admin credentials
2. **Use Private Endpoints**: Restrict network access for production registries
3. **Enable Quarantine**: Scan images before making them available
4. **Use Content Trust**: Sign and verify images for security
5. **Enable RBAC**: Use Azure RBAC for fine-grained access control

### High Availability

1. **Use Premium SKU**: Required for production workloads
2. **Enable Zone Redundancy**: Protect against datacenter failures
3. **Configure Geo-Replication**: Distribute registries globally
4. **Enable Retention Policies**: Automatic cleanup of old images

### Performance

1. **Use Dedicated Data Endpoints**: Improve pull performance (Premium)
2. **Regional Replication**: Reduce latency for global deployments
3. **Anonymous Pull**: Enable for public images when appropriate

### Cost Optimization

1. **Start with Standard**: Upgrade to Premium when needed
2. **Use Retention Policies**: Automatically clean up unused images
3. **Monitor Storage**: Review and delete unused repositories

## Common Use Cases

### CI/CD Pipeline Registry

```yaml
azure-acr-cicd:
  vars:
    name: "cicd"
    sku: "Standard"
    admin_enabled: true  # For pipeline authentication
    webhooks:
      build-trigger:
        service_uri: "https://pipeline.company.com/webhook"
        actions: ["push"]
```

### Production Application Registry

```yaml
azure-acr-prod:
  vars:
    name: "prod"
    sku: "Premium"
    admin_enabled: false
    public_network_access_enabled: false
    zone_redundancy_enabled: true
    quarantine_policy_enabled: true
    retention_policy:
      days: 90
      enabled: true
    trust_policy:
      enabled: true
```

### Multi-Region Deployment

```yaml
azure-acr-global:
  vars:
    name: "global"
    sku: "Premium"
    location: "eastus"
    georeplications:
      - location: "westus2"
        zone_redundancy_enabled: true
      - location: "westeurope"
        zone_redundancy_enabled: true
      - location: "southeastasia"
        zone_redundancy_enabled: true
```

## Related Documentation

- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [ACR Best Practices](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-best-practices)
- [ACR Authentication](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication)
- [ACR Geo-Replication](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-geo-replication)

## Notes

- Container Registry names must be globally unique across Azure
- By default, a 4-character random suffix is added to ensure uniqueness
- Premium SKU is required for most advanced features
- Network rules only apply to Premium SKU registries
- Geo-replication is only available in Premium SKU
- Consider using private endpoints for production workloads
- Admin credentials should be disabled in production environments
