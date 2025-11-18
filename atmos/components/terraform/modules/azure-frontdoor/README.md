# Azure Front Door Component

This Terraform component provisions an Azure Front Door (Standard or Premium) with support for endpoints, origin groups, origins, routes, rules, custom domains, and security policies.

## Features

- **Azure Front Door Profile**: Standard or Premium SKU
- **Endpoints**: Multiple Front Door endpoints with custom configuration
- **Origin Groups**: Configure origin groups with load balancing and health probes
- **Origins**: Support for public and private origins with Private Link
- **Routes**: Path-based routing with caching and custom domain support
- **Rule Sets & Rules**: Advanced traffic routing and manipulation
- **Custom Domains**: HTTPS support with managed or custom certificates
- **Security Policies**: WAF integration (Premium SKU only)
- **Health Probes**: Configurable health monitoring for origins
- **Caching**: Query string caching, compression, and cache behavior
- **SSL/TLS**: Configurable minimum TLS version and certificate management
- **Private Link**: Secure connectivity to private origin services

## Usage

### Basic Example

```yaml
components:
  terraform:
    azure-frontdoor:
      vars:
        enabled: true
        namespace: "myorg"
        environment: "eus"
        stage: "dev"
        name: "cdn"
        resource_group_name: "my-resource-group"
        sku_name: "Standard_AzureFrontDoor"

        endpoints:
          main:
            name: "main-endpoint"
            enabled: true

        origin_groups:
          default:
            name: "default-origin-group"
            load_balancing:
              sample_size: 4
              successful_samples_required: 3
            health_probe:
              protocol: "Https"
              interval_in_seconds: 100
              path: "/health"

        origins:
          web:
            name: "web-origin"
            origin_group_key: "default"
            host_name: "myapp.azurewebsites.net"
            https_port: 443
            http_port: 80

        routes:
          default:
            name: "default-route"
            endpoint_key: "main"
            origin_group_key: "default"
            origin_keys: ["web"]
            patterns_to_match: ["/*"]
            supported_protocols: ["Http", "Https"]
            https_redirect_enabled: true
            cache:
              query_string_caching_behavior: "IgnoreQueryString"
              compression_enabled: true
```

### Advanced Example with Custom Domains and Rules

```yaml
components:
  terraform:
    azure-frontdoor-premium:
      metadata:
        component: azure-frontdoor
      vars:
        enabled: true
        namespace: "myorg"
        environment: "eus"
        stage: "prod"
        name: "cdn"
        resource_group_name: "my-prod-rg"
        sku_name: "Premium_AzureFrontDoor"
        response_timeout_seconds: 120

        endpoints:
          main:
            name: "main-endpoint"
            enabled: true
          api:
            name: "api-endpoint"
            enabled: true

        origin_groups:
          web:
            name: "web-origin-group"
            session_affinity_enabled: true
            load_balancing:
              sample_size: 4
              successful_samples_required: 3
              additional_latency_in_milliseconds: 50
            health_probe:
              protocol: "Https"
              interval_in_seconds: 120
              request_type: "HEAD"
              path: "/health"

          api:
            name: "api-origin-group"
            load_balancing:
              sample_size: 4
              successful_samples_required: 2
            health_probe:
              protocol: "Https"
              interval_in_seconds: 60
              path: "/api/health"

        origins:
          web-primary:
            name: "web-primary"
            origin_group_key: "web"
            host_name: "web-primary.azurewebsites.net"
            priority: 1
            weight: 1000

          web-secondary:
            name: "web-secondary"
            origin_group_key: "web"
            host_name: "web-secondary.azurewebsites.net"
            priority: 2
            weight: 500

          api-origin:
            name: "api-origin"
            origin_group_key: "api"
            host_name: "api.internal.example.com"
            private_link:
              location: "eastus"
              private_link_target_id: "/subscriptions/.../privateLinkServices/..."
              request_message: "Please approve this connection"

        custom_domains:
          www:
            name: "www-domain"
            host_name: "www.example.com"
            tls:
              certificate_type: "ManagedCertificate"
              minimum_tls_version: "TLS12"

          api:
            name: "api-domain"
            host_name: "api.example.com"
            tls:
              certificate_type: "ManagedCertificate"
              minimum_tls_version: "TLS12"

        routes:
          web:
            name: "web-route"
            endpoint_key: "main"
            origin_group_key: "web"
            origin_keys: ["web-primary", "web-secondary"]
            patterns_to_match: ["/*"]
            supported_protocols: ["Http", "Https"]
            https_redirect_enabled: true
            custom_domain_keys: ["www"]
            rule_set_keys: ["security"]
            cache:
              query_string_caching_behavior: "IgnoreQueryString"
              compression_enabled: true
              content_types_to_compress: [
                "text/html",
                "text/css",
                "application/javascript",
                "application/json"
              ]

          api:
            name: "api-route"
            endpoint_key: "api"
            origin_group_key: "api"
            origin_keys: ["api-origin"]
            patterns_to_match: ["/api/*"]
            supported_protocols: ["Https"]
            custom_domain_keys: ["api"]
            cache:
              query_string_caching_behavior: "UseQueryString"
              compression_enabled: false

        rule_sets:
          security:
            name: "security-rules"

        rules:
          add-security-headers:
            name: "add-security-headers"
            rule_set_key: "security"
            order: 1
            actions:
              response_header_action:
                - header_action: "Append"
                  header_name: "X-Content-Type-Options"
                  value: "nosniff"
                - header_action: "Append"
                  header_name: "X-Frame-Options"
                  value: "SAMEORIGIN"
                - header_action: "Append"
                  header_name: "Strict-Transport-Security"
                  value: "max-age=31536000"

        security_policies:
          main:
            name: "main-waf-policy"
            firewall_policy_id: "/subscriptions/.../providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies/..."
            domain_keys: ["www", "api"]
            patterns_to_match: ["/*"]
```

### Private Link Origin Example

```yaml
origins:
  storage:
    name: "storage-origin"
    origin_group_key: "storage"
    host_name: "mystorageaccount.blob.core.windows.net"
    private_link:
      location: "eastus"
      private_link_target_id: "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/mystorageaccount"
      target_type: "blob"
      request_message: "Front Door connection request"
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 4.20.0 |

## Inputs

### Core Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| resource_group_name | Name of the resource group where the Front Door will be created | `string` | n/a | yes |
| custom_name | Custom name for the Front Door Profile (overrides label module generated name) | `string` | `null` | no |
| sku_name | SKU name for the Front Door Profile (Standard_AzureFrontDoor or Premium_AzureFrontDoor) | `string` | `"Standard_AzureFrontDoor"` | no |
| response_timeout_seconds | Response timeout in seconds (16-240) | `number` | `120` | no |

### Front Door Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| endpoints | Map of Front Door endpoints to create | `map(object)` | `{}` | no |
| origin_groups | Map of origin groups for the Front Door | `map(object)` | `{}` | no |
| origins | Map of origins for the Front Door origin groups | `map(object)` | `{}` | no |
| routes | Map of routes for the Front Door | `map(object)` | `{}` | no |
| rule_sets | Map of rule sets for the Front Door | `map(object)` | `{}` | no |
| rules | Map of rules for the Front Door rule sets | `map(object)` | `{}` | no |
| custom_domains | Map of custom domains for the Front Door | `map(object)` | `{}` | no |
| security_policies | Map of security policies for the Front Door (Premium SKU only) | `map(object)` | `{}` | no |

### Label Module Variables

Standard Cloud Posse label module variables are supported:
- `namespace`
- `tenant`
- `environment`
- `stage`
- `name`
- `attributes`
- `tags`
- `delimiter`
- `label_order`
- `regex_replace_chars`
- `id_length_limit`
- `label_key_case`
- `label_value_case`
- `context`

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Front Door Profile |
| name | The name of the Front Door Profile |
| resource_group_name | The name of the resource group |
| sku_name | The SKU name of the Front Door Profile |
| resource_guid | The resource GUID of the Front Door Profile |
| endpoints | Map of Front Door endpoints |
| endpoint_host_names | Map of endpoint keys to their host names |
| origin_groups | Map of Front Door origin groups |
| origins | Map of Front Door origins |
| routes | Map of Front Door routes |
| rule_sets | Map of Front Door rule sets |
| rules | Map of Front Door rules |
| custom_domains | Map of Front Door custom domains |
| security_policies | Map of Front Door security policies |
| tags | Tags applied to the Front Door Profile |
| context | Context from the label module |

## SKU Differences

### Standard SKU
- Basic WAF capabilities
- HTTP/HTTPS load balancing
- SSL offload
- Custom domains with managed certificates
- Caching and compression
- Rules engine
- Analytics and logs

### Premium SKU
- All Standard SKU features
- Advanced WAF with managed rules and bot protection
- Private Link support to origin services
- Enhanced analytics and diagnostics
- Increased performance limits

## Notes

- Front Door endpoint names must be globally unique
- Custom domains require DNS validation before use
- Private Link requires Premium SKU
- Security policies (WAF) require Premium SKU for advanced features
- Health probe intervals should be balanced between responsiveness and origin load
- SSL/TLS certificates can be managed by Azure or customer-provided

## References

- [Azure Front Door Documentation](https://docs.microsoft.com/en-us/azure/frontdoor/)
- [Terraform azurerm_cdn_frontdoor_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile)
- [Cloud Posse Label Module](https://github.com/cloudposse/terraform-null-label)
