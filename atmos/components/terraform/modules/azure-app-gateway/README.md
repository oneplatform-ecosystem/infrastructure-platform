# Azure Application Gateway Terraform Module

This Terraform module creates and manages an Azure Application Gateway with comprehensive configuration options.

## Features

- **Standard and WAF SKUs**: Support for both Standard_v2 and WAF_v2 SKUs with autoscaling
- **Flexible Frontend Configuration**: Public and/or private frontend IP configurations
- **Advanced Routing**: Path-based routing, URL rewriting, and redirect configurations
- **SSL/TLS Termination**: SSL certificate management with Key Vault integration
- **Health Probes**: Custom health probes for backend monitoring
- **Web Application Firewall**: Optional WAF with OWASP rule sets
- **High Availability**: Support for availability zones and autoscaling
- **Managed Identity**: System-assigned or user-assigned managed identities
- **Consistent Naming**: Uses Cloud Posse label module for standardized naming
- **Conditional Creation**: Enable/disable resource creation without destroying state

## Usage

### Basic Configuration

```yaml
components:
  terraform:
    azure-app-gateway:
      settings:
        depends_on:
          1:
            component: "azure-resource-group"
          2:
            component: "azure-vnet"
          3:
            component: "azure-subnet"
          4:
            component: "azure-public-ip"
      vars:
        enabled: true
        name: "web"

        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        location: "eastus"

        sku:
          name: "Standard_v2"
          tier: "Standard_v2"
          capacity: null

        autoscale_configuration:
          min_capacity: 2
          max_capacity: 10

        gateway_ip_configuration:
          name: "gateway-ip-config"
          subnet_id: !terraform.output azure-subnet-appgw ".subnet_id"

        public_ip_address_id: !terraform.output azure-public-ip-appgw ".public_ip_id"

        backend_address_pool:
          - name: "web-backend-pool"
            fqdns: ["webapp.azurewebsites.net"]

        backend_http_settings:
          - name: "web-http-settings"
            cookie_based_affinity: "Disabled"
            port: 80
            protocol: "Http"
            request_timeout: 30
            probe_name: "web-health-probe"

        http_listener:
          - name: "web-http-listener"
            frontend_ip_configuration_name: "public-frontend"
            frontend_port_name: "http"
            protocol: "Http"

        request_routing_rule:
          - name: "web-routing-rule"
            rule_type: "Basic"
            http_listener_name: "web-http-listener"
            backend_address_pool_name: "web-backend-pool"
            backend_http_settings_name: "web-http-settings"
            priority: 100

        probe:
          - name: "web-health-probe"
            protocol: "Http"
            path: "/health"
            interval: 30
            timeout: 30
            unhealthy_threshold: 3
            pick_host_name_from_backend_http_settings: true
            match:
              status_code: ["200-399"]
```

### HTTPS with SSL Certificate

```yaml
components:
  terraform:
    azure-app-gateway-https:
      vars:
        name: "secure"

        frontend_port:
          - name: "https"
            port: 443

        ssl_certificate:
          - name: "web-ssl-cert"
            key_vault_secret_id: "https://keyvault.vault.azure.net/secrets/ssl-cert/version"

        http_listener:
          - name: "https-listener"
            frontend_ip_configuration_name: "public-frontend"
            frontend_port_name: "https"
            protocol: "Https"
            ssl_certificate_name: "web-ssl-cert"
            require_sni: true
            host_name: "www.example.com"

        request_routing_rule:
          - name: "https-routing-rule"
            rule_type: "Basic"
            http_listener_name: "https-listener"
            backend_address_pool_name: "web-backend-pool"
            backend_http_settings_name: "web-http-settings"
            priority: 100

        ssl_policy:
          policy_type: "Predefined"
          policy_name: "AppGwSslPolicy20220101S"

        identity:
          type: "UserAssigned"
          identity_ids: [!terraform.output azure-user-assigned-identity ".id"]
```

### WAF Configuration

```yaml
components:
  terraform:
    azure-app-gateway-waf:
      vars:
        name: "waf"

        sku:
          name: "WAF_v2"
          tier: "WAF_v2"
          capacity: null

        waf_configuration:
          enabled: true
          firewall_mode: "Prevention"
          rule_set_type: "OWASP"
          rule_set_version: "3.2"
          file_upload_limit_mb: 100
          request_body_check: true
          max_request_body_size_kb: 128
          disabled_rule_group:
            - rule_group_name: "REQUEST-920-PROTOCOL-ENFORCEMENT"
              rules: [920300, 920330]
```

### Path-Based Routing

```yaml
components:
  terraform:
    azure-app-gateway-path:
      vars:
        name: "pathrouting"

        backend_address_pool:
          - name: "api-backend-pool"
            ip_addresses: ["10.0.1.10", "10.0.1.11"]
          - name: "web-backend-pool"
            ip_addresses: ["10.0.1.20", "10.0.1.21"]

        backend_http_settings:
          - name: "api-http-settings"
            cookie_based_affinity: "Disabled"
            port: 8080
            protocol: "Http"
            request_timeout: 30
          - name: "web-http-settings"
            cookie_based_affinity: "Enabled"
            port: 80
            protocol: "Http"
            request_timeout: 30

        url_path_map:
          - name: "main-path-map"
            default_backend_address_pool_name: "web-backend-pool"
            default_backend_http_settings_name: "web-http-settings"
            path_rule:
              - name: "api-path-rule"
                paths: ["/api/*"]
                backend_address_pool_name: "api-backend-pool"
                backend_http_settings_name: "api-http-settings"

        request_routing_rule:
          - name: "path-routing-rule"
            rule_type: "PathBasedRouting"
            http_listener_name: "http-listener"
            url_path_map_name: "main-path-map"
            priority: 100
```

### URL Rewriting

```yaml
components:
  terraform:
    azure-app-gateway-rewrite:
      vars:
        name: "rewrite"

        rewrite_rule_set:
          - name: "security-headers"
            rewrite_rule:
              - name: "add-security-headers"
                rule_sequence: 100
                response_header_configuration:
                  - header_name: "X-Frame-Options"
                    header_value: "DENY"
                  - header_name: "X-Content-Type-Options"
                    header_value: "nosniff"
                  - header_name: "Strict-Transport-Security"
                    header_value: "max-age=31536000; includeSubDomains"

        request_routing_rule:
          - name: "routing-with-rewrite"
            rule_type: "Basic"
            http_listener_name: "http-listener"
            backend_address_pool_name: "backend-pool"
            backend_http_settings_name: "http-settings"
            rewrite_rule_set_name: "security-headers"
            priority: 100
```

### Multi-Region with Private Frontend

```yaml
components:
  terraform:
    azure-app-gateway-private:
      vars:
        name: "internal"

        public_ip_address_id: null
        private_ip_address: "10.0.2.10"
        private_ip_address_allocation: "Static"

        http_listener:
          - name: "private-listener"
            frontend_ip_configuration_name: "private-frontend"
            frontend_port_name: "http"
            protocol: "Http"
```

### High Availability with Availability Zones

```yaml
components:
  terraform:
    azure-app-gateway-ha:
      vars:
        name: "ha"

        zones: ["1", "2", "3"]

        autoscale_configuration:
          min_capacity: 3
          max_capacity: 20
```

## Naming Convention

The module uses the Cloud Posse label module to generate consistent names:

**Pattern**: `{namespace}{environment}{stage}{name}`

**Examples**:
- `lalbappgweus` (lalb + appgw + eus)
- `lalbwebappgweusdev` (lalb + webappgw + eus + dev)
- `lalbapigweusprod` (lalb + apigw + eus + prod)

**Custom Naming**: Use `custom_name` variable to override the generated name:
```yaml
vars:
  custom_name: "my-custom-appgw-name"
```

## Integration with Other Components

### Dependencies

Application Gateway requires:
1. **Resource Group** (`azure-resource-group`)
2. **Virtual Network** (`azure-vnet`)
3. **Dedicated Subnet** (`azure-subnet`) - Cannot be shared with other resources
4. **Public IP** (`azure-public-ip`) - Optional, for public frontend
5. **Key Vault** (`azure-keyvault`) - Optional, for SSL certificates
6. **User Assigned Identity** - Optional, for Key Vault access

### Reference Example

```yaml
components:
  terraform:
    azure-subnet-appgw:
      vars:
        name: "appgw"
        address_prefixes: ["10.0.2.0/24"]
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        virtual_network_name: !terraform.output azure-vnet ".vnet_name"

    azure-public-ip-appgw:
      vars:
        name: "appgw"
        allocation_method: "Static"
        sku: "Standard"
        zones: ["1", "2", "3"]

    azure-app-gateway:
      settings:
        depends_on:
          1:
            component: "azure-subnet-appgw"
          2:
            component: "azure-public-ip-appgw"
      vars:
        gateway_ip_configuration:
          subnet_id: !terraform.output azure-subnet-appgw ".subnet_id"
        public_ip_address_id: !terraform.output azure-public-ip-appgw ".public_ip_id"
```

## Subnet Requirements

Application Gateway requires a **dedicated subnet** with specific requirements:

- **Subnet Size**: Minimum /27 (32 addresses), recommended /26 (64 addresses) or larger
- **Reserved Addresses**: Azure reserves 5 addresses per subnet
- **Instance Requirements**: Each Application Gateway instance requires 1 IP address
- **Autoscaling**: Plan for maximum autoscale capacity + reserved addresses
- **No Sharing**: Subnet cannot contain other Azure resources

**Capacity Planning Example**:
```
Max instances: 20
Reserved addresses: 5
Total required: 25 addresses
Recommended subnet: /26 (64 addresses)
```

## SSL/TLS Configuration

### Using Key Vault for Certificates

**Prerequisites**:
1. Store certificate in Key Vault as a secret (PFX format)
2. Configure managed identity for Application Gateway
3. Grant identity "Get" permission on Key Vault secrets

**Configuration**:
```yaml
vars:
  identity:
    type: "UserAssigned"
    identity_ids: ["<identity-resource-id>"]

  ssl_certificate:
    - name: "my-cert"
      key_vault_secret_id: "https://<keyvault>.vault.azure.net/secrets/<cert-name>/<version>"
```

### Using Certificate Data

**For Development/Testing Only**:
```yaml
vars:
  ssl_certificate:
    - name: "dev-cert"
      data: "<base64-encoded-pfx>"
      password: "<certificate-password>"
```

## Security Best Practices

1. **Use WAF_v2 SKU** for production workloads requiring web application firewall
2. **Enable HTTPS** for all public-facing applications
3. **Use Strong SSL Policy**: `AppGwSslPolicy20220101S` or custom with TLS 1.2+
4. **Key Vault Integration**: Store certificates in Key Vault, not inline
5. **Managed Identity**: Use managed identities for Key Vault access
6. **Network Security Groups**: Control inbound traffic to Application Gateway subnet
7. **Health Probes**: Configure custom health probes for all backend pools
8. **Private Backends**: Use private endpoints for backend connections
9. **Availability Zones**: Deploy across zones for high availability
10. **Monitoring**: Enable diagnostic settings and Application Insights

## Performance Considerations

### Autoscaling Configuration

```yaml
vars:
  sku:
    name: "Standard_v2"
    tier: "Standard_v2"
    capacity: null  # Required for autoscaling

  autoscale_configuration:
    min_capacity: 2  # Minimum instances
    max_capacity: 10 # Maximum instances
```

**Guidelines**:
- Set `min_capacity` to handle baseline traffic
- Set `max_capacity` based on peak traffic requirements
- Scaling operations take 6-7 minutes
- Plan for traffic spikes accordingly

### Connection Draining

Backend HTTP settings support connection draining for graceful shutdowns:
```yaml
backend_http_settings:
  - name: "settings"
    request_timeout: 30  # Seconds to wait for response
```

## Troubleshooting

### Common Issues

**Issue**: Application Gateway creation fails with "Subnet is not empty"
- **Solution**: Ensure subnet is dedicated to Application Gateway only

**Issue**: Backend health probe fails
- **Solution**:
  - Verify backend is reachable from Application Gateway subnet
  - Check NSG rules allow health probe traffic (source: GatewayManager)
  - Validate probe path returns expected status code

**Issue**: SSL certificate error from Key Vault
- **Solution**:
  - Verify managed identity has "Get" permission on Key Vault secrets
  - Ensure certificate is stored as secret (not certificate object)
  - Check Key Vault firewall allows access from Application Gateway

**Issue**: Backend returns 502 Bad Gateway
- **Solution**:
  - Check backend health status in portal
  - Verify backend HTTP settings match backend configuration
  - Review backend application logs
  - Ensure backend certificate is trusted (for HTTPS backends)

**Issue**: Routing rule conflicts
- **Solution**: Ensure routing rule priorities are unique and do not overlap

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 4.23.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| label | cloudposse/label/null | 0.25.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| resource_group_name | Name of the resource group where the Application Gateway will be created | `string` | n/a | yes |
| location | Azure region where the Application Gateway will be created | `string` | n/a | yes |
| gateway_ip_configuration | Gateway IP configuration. Subnet ID is required | `object` | n/a | yes |
| sku | SKU configuration for Application Gateway | `object` | Standard_v2 | no |
| autoscale_configuration | Autoscale configuration for Application Gateway v2 SKUs | `object` | `null` | no |
| public_ip_address_id | ID of the public IP address for the Application Gateway frontend | `string` | `null` | no |
| private_ip_address | Private IP address for the Application Gateway frontend | `string` | `null` | no |
| backend_address_pool | Backend address pool configuration | `list(object)` | default pool | no |
| backend_http_settings | Backend HTTP settings configuration | `list(object)` | default settings | no |
| http_listener | HTTP listener configuration | `list(object)` | default listener | no |
| request_routing_rule | Request routing rule configuration | `list(object)` | default rule | no |
| probe | Health probe configuration | `list(object)` | `[]` | no |
| ssl_certificate | SSL certificate configuration | `list(object)` | `[]` | no |
| waf_configuration | Web Application Firewall configuration | `object` | `null` | no |
| zones | Availability zones for the Application Gateway | `list(string)` | `null` | no |

See `variables.tf` for complete input documentation.

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Application Gateway |
| name | The name of the Application Gateway |
| resource_group_name | The name of the resource group |
| location | The Azure region where the Application Gateway is deployed |
| backend_address_pool | Backend address pool configuration |
| backend_http_settings | Backend HTTP settings configuration |
| frontend_ip_configuration | Frontend IP configuration |
| frontend_port | Frontend port configuration |
| http_listener | HTTP listener configuration |
| request_routing_rule | Request routing rule configuration |
| tags | Tags applied to the Application Gateway |

See `outputs.tf` for complete output documentation.

## Examples

See the [Usage](#usage) section above for comprehensive examples including:
- Basic HTTP configuration
- HTTPS with SSL termination
- WAF configuration
- Path-based routing
- URL rewriting
- Private frontend configuration
- High availability with zones

## References

- [Azure Application Gateway Documentation](https://learn.microsoft.com/en-us/azure/application-gateway/)
- [Application Gateway Features](https://learn.microsoft.com/en-us/azure/application-gateway/features)
- [Web Application Firewall on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)
- [SSL Termination and End-to-End SSL](https://learn.microsoft.com/en-us/azure/application-gateway/ssl-overview)
