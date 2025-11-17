# Azure API Management Terraform Module

This Terraform module creates and manages an Azure API Management (APIM) service with configurable SKU, networking, security, and customization settings.

## Features

- Multiple SKU tiers: Consumption, Developer, Basic, Standard, and Premium
- Virtual Network integration (External and Internal modes)
- Private endpoint support for secure network access
- Managed Identity support (System and User Assigned)
- Custom domain configuration for multiple endpoints
- TLS/SSL security configuration with customizable cipher suites
- Multi-region deployments with additional locations
- Availability Zones support for high availability
- Developer portal customization (sign-in, sign-up, delegation)
- Certificate management for backend SSL connections
- Global policy configuration
- CloudPosse label module integration for consistent resource naming and tagging

## Usage

### Basic Configuration (Developer SKU)

```hcl
module "apim_dev" {
  source = "./modules/azure-apim"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Publisher Information (Required)
  publisher_name  = "My Company"
  publisher_email = "admin@mycompany.com"

  # SKU Configuration
  sku_name = "Developer"
  capacity = 1

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "dev"
  name        = "api"
}
```

### Production Configuration with VNet Integration

```hcl
module "apim_prod" {
  source = "./modules/azure-apim"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Publisher Information
  publisher_name  = "My Company"
  publisher_email = "admin@mycompany.com"

  # Premium SKU for VNet integration
  sku_name = "Premium"
  capacity = 1

  # Virtual Network Configuration - Internal mode
  virtual_network_type = "Internal"
  virtual_network_configuration = {
    subnet_id = azurerm_subnet.apim.id
  }

  # Availability Zones
  zones = ["1", "2", "3"]

  # Network Security
  public_network_access_enabled = false

  # Managed Identity
  identity_type = "SystemAssigned"

  # Security Settings
  security = {
    enable_backend_ssl30  = false
    enable_backend_tls10  = false
    enable_backend_tls11  = false
    enable_frontend_ssl30 = false
    enable_frontend_tls10 = false
    enable_frontend_tls11 = false
    triple_des_ciphers_enabled = false
  }

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "prod"
  name        = "api"
}
```

### With Private Endpoint

```hcl
module "apim_private" {
  source = "./modules/azure-apim"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Publisher Information
  publisher_name  = "My Company"
  publisher_email = "admin@mycompany.com"

  # SKU Configuration
  sku_name = "Premium"
  capacity = 1

  # Network Security
  public_network_access_enabled = false

  # Private Endpoint
  create_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id

  private_endpoint_dns_zone_group = {
    name                 = "apim-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.apim.id]
  }

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "prod"
  name        = "api"
}
```

### With Custom Domains and Certificates

```hcl
module "apim_custom_domain" {
  source = "./modules/azure-apim"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Publisher Information
  publisher_name  = "My Company"
  publisher_email = "admin@mycompany.com"

  # SKU Configuration
  sku_name = "Premium"
  capacity = 1

  # Managed Identity for Key Vault access
  identity_type = "SystemAssigned"

  # Custom Hostname Configuration
  hostname_configurations = [
    {
      type         = "proxy"
      host_name    = "api.mycompany.com"
      key_vault_id = azurerm_key_vault_certificate.api_cert.secret_id
      ssl_keyvault_identity_client_id = null
      negotiate_client_certificate    = false
    },
    {
      type         = "developer_portal"
      host_name    = "developer.mycompany.com"
      key_vault_id = azurerm_key_vault_certificate.portal_cert.secret_id
      ssl_keyvault_identity_client_id = null
      negotiate_client_certificate    = false
    },
    {
      type         = "management"
      host_name    = "management.mycompany.com"
      key_vault_id = azurerm_key_vault_certificate.mgmt_cert.secret_id
      ssl_keyvault_identity_client_id = null
      negotiate_client_certificate    = false
    }
  ]

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "prod"
  name        = "api"
}
```

### Multi-Region Deployment

```hcl
module "apim_multiregion" {
  source = "./modules/azure-apim"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Publisher Information
  publisher_name  = "My Company"
  publisher_email = "admin@mycompany.com"

  # Premium SKU required for multi-region
  sku_name = "Premium"
  capacity = 1

  # Primary region zones
  zones = ["1", "2", "3"]

  # Additional Regions
  additional_locations = [
    {
      location = "westus2"
      capacity = 1
      zones    = ["1", "2", "3"]
    },
    {
      location = "northeurope"
      capacity = 1
      zones    = ["1", "2", "3"]
    }
  ]

  # Label Configuration
  namespace   = "lazylabs"
  environment = "global"
  stage       = "prod"
  name        = "api"
}
```

### With Developer Portal Customization

```hcl
module "apim_portal" {
  source = "./modules/azure-apim"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Publisher Information
  publisher_name  = "My Company"
  publisher_email = "admin@mycompany.com"

  # SKU Configuration
  sku_name = "Developer"
  capacity = 1

  # Sign-in Configuration
  sign_in = {
    enabled = true
  }

  # Sign-up Configuration
  sign_up = {
    enabled = true
    terms_of_service = {
      consent_required = true
      enabled          = true
      text             = "Please accept the terms of service to continue."
    }
  }

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "dev"
  name        = "api"
}
```

## SKU Tiers

### Consumption
- Serverless, pay-per-execution model
- Auto-scaling
- No SLA
- Capacity must be 0
- Limited features
- Ideal for: Testing, development, or low-traffic APIs

### Developer
- Single unit, no SLA
- Full feature set except for VNet support and multi-region deployment
- Ideal for: Development and testing environments

### Basic
- 99.95% SLA
- Up to 2 units
- Limited throughput
- No VNet support
- Ideal for: Small production workloads

### Standard
- 99.95% SLA
- Up to 4 units
- Higher throughput
- No VNet support
- Ideal for: Medium production workloads

### Premium
- 99.99% SLA
- Unlimited units
- Maximum throughput
- All features including:
  - VNet integration (Internal/External)
  - Multi-region deployment
  - Availability Zones
  - Self-hosted gateways
  - Cache options
- Ideal for: Enterprise production workloads requiring high availability

## Virtual Network Integration

### None
- Default configuration
- API Management is accessible from the internet
- No VNet integration

### External
- APIM deployed in VNet
- Gateway and developer portal accessible from internet
- Backend services can be in VNet or internet

### Internal
- APIM deployed in VNet
- All endpoints only accessible from within VNet
- Requires private endpoints or VPN/ExpressRoute for access
- Maximum security

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| location | The Azure Region where the API Management Service should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the API Management Service | `string` | n/a | yes |
| publisher_name | The name of publisher/company | `string` | n/a | yes |
| publisher_email | The email of publisher/company | `string` | n/a | yes |
| sku_name | The SKU of the API Management Service | `string` | `"Developer"` | no |
| capacity | The number of deployed units of the SKU | `number` | `1` | no |
| virtual_network_type | The type of virtual network configuration | `string` | `"None"` | no |
| public_network_access_enabled | Whether public network access is allowed | `bool` | `true` | no |
| identity_type | The type of Managed Identity | `string` | `null` | no |
| zones | A list of Availability Zones | `list(string)` | `null` | no |

For a complete list of inputs, see [variables.tf](variables.tf).

## Outputs

| Name | Description |
|------|-------------|
| api_management_id | The ID of the API Management Service |
| api_management_name | The name of the API Management Service |
| gateway_url | The URL of the Gateway |
| gateway_regional_url | The regional URL of the Gateway |
| management_api_url | The URL for the Management API |
| portal_url | The URL for the Publisher Portal |
| developer_portal_url | The URL for the Developer Portal |
| scm_url | The URL for the SCM endpoint |
| public_ip_addresses | The Public IP addresses |
| private_ip_addresses | The Private IP addresses |
| principal_id | The Principal ID of the System Assigned Managed Identity |

For a complete list of outputs, see [outputs.tf](outputs.tf).

## Best Practices

### Security

1. **Use Managed Identity**: Enable System Assigned or User Assigned Managed Identity for secure access to Azure resources
2. **Disable Weak TLS Versions**: Set `enable_frontend_tls10` and `enable_frontend_tls11` to `false`
3. **Use Private Endpoints**: For production workloads, use private endpoints and disable public network access
4. **Enable Client Certificates**: Use `client_certificate_enabled = true` for enhanced API security
5. **VNet Integration**: Use Internal VNet mode for maximum security
6. **Custom Domains with HTTPS**: Always use custom domains with valid SSL certificates

### High Availability

1. **Use Premium SKU**: Required for enterprise-grade availability features
2. **Enable Availability Zones**: Deploy across multiple zones for zone redundancy
3. **Multi-Region Deployment**: Use additional locations for global distribution and disaster recovery
4. **Capacity Planning**: Scale units based on expected load

### Performance

1. **Choose Appropriate SKU**: Match SKU to workload requirements
2. **Use Caching**: Configure caching policies for frequently accessed APIs
3. **Optimize Policies**: Keep policies lightweight and efficient
4. **Monitor Metrics**: Use Azure Monitor and Application Insights

### Cost Optimization

1. **Right-Size SKU**: Start with Developer for non-production, Basic/Standard for small production workloads
2. **Use Consumption Tier**: For low-traffic or sporadic APIs
3. **Auto-scaling**: Configure auto-scaling for Standard and Premium SKUs
4. **Monitor Usage**: Regularly review capacity and scale down if possible

## Common Use Cases

### API Gateway for Microservices

Use APIM as a central gateway for microservices:
- Route requests to appropriate backend services
- Apply authentication and authorization policies
- Implement rate limiting and quotas
- Transform requests and responses

### API Product Management

Organize and manage API products:
- Create products with different subscription tiers
- Control access to APIs through subscriptions
- Implement usage quotas and rate limits per product
- Provide developer portal for self-service

### Legacy System Integration

Modernize legacy systems:
- Expose legacy SOAP services as REST APIs
- Transform XML to JSON
- Add modern authentication mechanisms
- Provide consistent API interface

### Partner Integration

Secure external partner access:
- Isolate external-facing APIs in VNet
- Use subscription keys and OAuth 2.0
- Implement IP filtering and rate limiting
- Provide dedicated developer portal

## Related Documentation

- [Azure API Management Documentation](https://docs.microsoft.com/azure/api-management/)
- [APIM Pricing](https://azure.microsoft.com/pricing/details/api-management/)
- [APIM Best Practices](https://docs.microsoft.com/azure/api-management/api-management-best-practices)
- [VNet Integration](https://docs.microsoft.com/azure/api-management/api-management-using-with-vnet)
- [Multi-Region Deployment](https://docs.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region)

## Notes

- **Deployment Time**: API Management service can take 30-45 minutes to provision
- **SKU Changes**: Changing SKU may require downtime
- **Consumption SKU**: Requires capacity = 0, does not support all features
- **VNet Integration**: Only available with Premium SKU (Internal/External modes)
- **Multi-Region**: Only available with Premium SKU
- **Custom Domains**: Certificates must be in Key Vault or provided as base64-encoded strings
- **Developer Portal**: Legacy portal deprecated, use new developer portal
- **Pricing**: Premium SKU is significantly more expensive than other tiers

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | >= 4.0.0 |
| random | >= 3.0.0 |
