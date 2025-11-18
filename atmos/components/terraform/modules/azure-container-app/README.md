# Azure Container App Component

This Terraform module creates and manages Azure Container Apps and their environments, providing a fully managed serverless container platform.

## Features

- **Container App Environment Management**: Create dedicated or shared environments for container apps
- **Multi-Container Support**: Run multiple containers within a single container app
- **Auto-Scaling**: Support for HTTP, TCP, Azure Queue, and custom scale rules
- **Ingress Configuration**: External and internal ingress with custom domains and TLS
- **Dapr Integration**: Built-in Dapr support for microservices patterns
- **Identity Management**: SystemAssigned and UserAssigned managed identities
- **Secret Management**: Secure secret handling with Key Vault integration
- **Health Probes**: Liveness, readiness, and startup probes for container health
- **Registry Support**: Private container registry authentication
- **Volume Mounts**: Support for persistent and ephemeral volumes
- **Traffic Splitting**: Blue-green and canary deployment patterns
- **Network Integration**: VNet integration with internal load balancing
- **Zone Redundancy**: High availability across availability zones
- **Init Containers**: Support for initialization containers
- **Workload Profiles**: Consumption and dedicated workload profiles

## Usage

### Basic Example

```yaml
components:
  terraform:
    azure-container-app-web:
      metadata:
        component: azure-container-app
      vars:
        enabled: true
        name: "webapp"
        resource_group_name: "myapp-rsg"
        location: "eastus"

        # Use existing environment
        create_environment: false
        environment_id: "/subscriptions/.../containerAppEnvironments/myenv"

        # Container configuration
        containers:
          - name: "web"
            image: "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu: 0.25
            memory: "0.5Gi"

        # Ingress configuration
        ingress:
          external_enabled: true
          target_port: 80
          transport: "auto"
```

### Advanced Example with Environment Creation

```yaml
components:
  terraform:
    azure-container-app-api:
      metadata:
        component: azure-container-app
      vars:
        enabled: true
        name: "api"
        resource_group_name: "myapp-rsg"
        location: "eastus"

        # Create new environment with VNet integration
        create_environment: true
        environment_name: "myapp-env"
        infrastructure_subnet_id: !terraform.output azure-subnet ".subnet_id"
        internal_load_balancer_enabled: true
        zone_redundancy_enabled: true
        log_analytics_workspace_id: !terraform.output azure-log-analytics ".workspace_id"

        # Workload profiles for dedicated resources
        workload_profile:
          - name: "Consumption"
            workload_profile_type: "Consumption"
          - name: "Dedicated-D4"
            workload_profile_type: "D4"
            minimum_count: 1
            maximum_count: 3

        # Use dedicated workload profile
        workload_profile_name: "Dedicated-D4"

        # Revision mode for blue-green deployments
        revision_mode: "Multiple"

        # Scaling configuration
        min_replicas: 2
        max_replicas: 10

        # Multi-container configuration
        containers:
          - name: "api"
            image: "myregistry.azurecr.io/api:v1.0.0"
            cpu: 1.0
            memory: "2Gi"
            env:
              - name: "ASPNETCORE_ENVIRONMENT"
                value: "Production"
              - name: "DATABASE_CONNECTION"
                secret_name: "db-connection-string"
              - name: "API_KEY"
                secret_name: "api-key"
            liveness_probe:
              transport: "HTTP"
              port: 8080
              path: "/health/live"
              interval_seconds: 30
              timeout: 5
              failure_count_threshold: 3
            readiness_probe:
              transport: "HTTP"
              port: 8080
              path: "/health/ready"
              interval_seconds: 10
              timeout: 3
              failure_count_threshold: 3
              success_count_threshold: 1
            startup_probe:
              transport: "HTTP"
              port: 8080
              path: "/health/startup"
              interval_seconds: 5
              timeout: 3
              failure_count_threshold: 12

          - name: "sidecar-logger"
            image: "fluent/fluent-bit:latest"
            cpu: 0.25
            memory: "0.5Gi"
            volume_mounts:
              - name: "logs"
                path: "/var/log"

        # Init containers
        init_containers:
          - name: "migration"
            image: "myregistry.azurecr.io/migration:v1.0.0"
            cpu: 0.5
            memory: "1Gi"
            env:
              - name: "DATABASE_CONNECTION"
                secret_name: "db-connection-string"

        # Ingress with custom domain
        ingress:
          external_enabled: true
          target_port: 8080
          transport: "http"
          allow_insecure_connections: false
          traffic_weight:
            - percentage: 80
              latest_revision: false
              revision_suffix: "v1"
              label: "stable"
            - percentage: 20
              latest_revision: true
              label: "canary"
          custom_domain:
            - name: "api.mycompany.com"
              certificate_binding_type: "SniEnabled"
              certificate_id: !terraform.output azure-certificate ".certificate_id"
          ip_security_restriction:
            - name: "allow-office"
              ip_address_range: "203.0.113.0/24"
              description: "Office IP range"
              action: "Allow"
            - name: "deny-all"
              ip_address_range: "0.0.0.0/0"
              description: "Deny all other traffic"
              action: "Deny"

        # Dapr configuration
        dapr:
          app_id: "myapi"
          app_port: 8080
          app_protocol: "http"

        # Managed identity
        identity_type: "SystemAssigned, UserAssigned"
        identity_ids:
          - !terraform.output azure-user-identity ".identity_id"

        # Container registry
        registry:
          - server: "myregistry.azurecr.io"
            identity: !terraform.output azure-user-identity ".identity_id"

        # Secrets (values should come from secure sources)
        secrets:
          - name: "db-connection-string"
            key_vault_secret_id: !terraform.output azure-keyvault ".secret_id"
            identity: !terraform.output azure-user-identity ".identity_id"
          - name: "api-key"
            value: "${API_KEY}"  # Should be passed securely

        # HTTP-based auto-scaling
        scale_rules:
          - name: "http-rule"
            http:
              concurrent_requests: 100
          - name: "queue-rule"
            azure_queue:
              queue_name: "tasks"
              queue_length: 10
              account_name: "storage-account-connection"
          - name: "custom-rule"
            custom:
              type: "prometheus"
              metadata:
                serverAddress: "http://prometheus:9090"
                metricName: "http_requests_total"
                threshold: "1000"
                query: "sum(rate(http_requests_total[2m]))"
              authentication:
                - secret_name: "prometheus-token"
                  trigger_parameter: "bearerToken"

        # Volumes
        volumes:
          - name: "logs"
            storage_type: "EmptyDir"

        # Tags
        tags:
          Environment: "Production"
          Application: "MyAPI"
          CostCenter: "Engineering"
          ManagedBy: "Terraform"
```

### Example with Existing Environment

```yaml
components:
  terraform:
    azure-container-app-worker:
      metadata:
        component: azure-container-app
      vars:
        enabled: true
        name: "worker"
        resource_group_name: "myapp-rsg"
        location: "eastus"

        # Use existing environment
        create_environment: false
        environment_id: !terraform.output azure-container-app-api ".environment_id"

        # Worker container
        containers:
          - name: "worker"
            image: "myregistry.azurecr.io/worker:v1.0.0"
            cpu: 2.0
            memory: "4Gi"
            env:
              - name: "QUEUE_CONNECTION"
                secret_name: "queue-connection"

        # No ingress needed for background worker
        ingress: null

        # Scale based on queue length
        min_replicas: 1
        max_replicas: 20
        scale_rules:
          - name: "queue-scale"
            azure_queue:
              queue_name: "tasks"
              queue_length: 5
              account_name: "storage-connection"

        # Managed identity for Azure services
        identity_type: "SystemAssigned"

        # Registry authentication
        registry:
          - server: "myregistry.azurecr.io"
            identity: "system"

        # Secrets
        secrets:
          - name: "queue-connection"
            key_vault_secret_id: !terraform.output azure-keyvault ".queue_secret_id"
```

### Simple Single Container Example

```yaml
components:
  terraform:
    azure-container-app-hello:
      metadata:
        component: azure-container-app
      vars:
        enabled: true
        name: "hello"
        resource_group_name: "demo-rsg"
        location: "eastus"

        # Create simple environment
        create_environment: true
        log_analytics_workspace_id: !terraform.output azure-log-analytics ".workspace_id"

        # Single container
        containers:
          - name: "hello-world"
            image: "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu: 0.25
            memory: "0.5Gi"

        # Public ingress
        ingress:
          external_enabled: true
          target_port: 80
```

## Container App Environment

The module can either create a new Container App Environment or use an existing one:

### Create New Environment

Set `create_environment = true` and configure:
- `environment_name`: Custom name (optional)
- `infrastructure_subnet_id`: VNet integration (optional)
- `internal_load_balancer_enabled`: Internal LB mode
- `zone_redundancy_enabled`: High availability
- `log_analytics_workspace_id`: Logging and monitoring
- `workload_profile`: Consumption or dedicated compute

### Use Existing Environment

Set `create_environment = false` and provide:
- `environment_id`: Resource ID of existing environment

## Container Configuration

Each container in the `containers` list supports:

- **Basic Settings**: name, image, cpu, memory
- **Commands**: args, command
- **Environment Variables**: Plain values or secret references
- **Health Probes**: liveness, readiness, startup
- **Volume Mounts**: Mount volumes into containers

## Ingress Options

Ingress configuration supports:

- **Exposure**: External or internal
- **Transport**: HTTP, HTTP/2, TCP, auto
- **Custom Domains**: Multiple domains with TLS
- **Traffic Splitting**: Percentage-based routing
- **IP Restrictions**: Allow/deny rules

## Scaling

The module supports multiple scaling strategies:

- **HTTP Scaling**: Based on concurrent HTTP requests
- **TCP Scaling**: Based on concurrent TCP connections
- **Azure Queue**: Scale based on Azure Storage Queue length
- **Custom**: Integration with KEDA scalers (Prometheus, Kafka, etc.)

## Dapr Integration

Enable Dapr sidecars for:
- Service-to-service invocation
- State management
- Pub/sub messaging
- Bindings and triggers

## Identity and Security

- **Managed Identity**: SystemAssigned or UserAssigned
- **Key Vault Integration**: Reference secrets from Key Vault
- **Container Registry**: Authenticate with managed identity or credentials
- **Network Security**: VNet integration and private endpoints

## Monitoring and Logging

- **Log Analytics**: Integrated logging and monitoring
- **Application Insights**: APM and telemetry
- **Health Probes**: Built-in health monitoring

## Inputs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/container_app) | resource |
| [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/container_app_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Container App should exist | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Container App | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_fqdn"></a> [container\_app\_fqdn](#output\_container\_app\_fqdn) | The FQDN of the Container App's ingress |
| <a name="output_container_app_id"></a> [container\_app\_id](#output\_container\_app\_id) | The ID of the Container App |
| <a name="output_container_app_name"></a> [container\_app\_name](#output\_container\_app\_name) | The name of the Container App |
| <a name="output_container_app_url"></a> [container\_app\_url](#output\_container\_app\_url) | The URL of the Container App (HTTPS) |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The ID of the Container App Environment |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources |
<!-- END_TF_DOCS -->

## Best Practices

1. **Environment Sharing**: Share Container App Environments across multiple apps to reduce costs
2. **Resource Limits**: Set appropriate CPU and memory limits based on workload
3. **Health Probes**: Always configure health probes for production workloads
4. **Scaling**: Configure auto-scaling based on your application's metrics
5. **Secrets**: Use Key Vault integration for sensitive data
6. **Identity**: Use managed identities instead of connection strings
7. **Networking**: Use VNet integration for private workloads
8. **Monitoring**: Enable Log Analytics for observability
9. **Revisions**: Use multiple revision mode for blue-green deployments
10. **Init Containers**: Use init containers for database migrations and setup tasks

## Common Use Cases

### Web API with Database

Deploy a containerized API with auto-scaling, health checks, and database connectivity using managed identity.

### Background Worker

Run background job processors that scale based on queue length without public ingress.

### Microservices with Dapr

Deploy microservices architecture with Dapr for service discovery, state management, and pub/sub.

### Multi-Container Application

Run application containers with sidecar containers for logging, monitoring, or service mesh.

## Troubleshooting

### Container Fails to Start

- Check container logs in Log Analytics
- Verify image name and registry credentials
- Ensure resource limits are adequate
- Check startup probe configuration

### Scaling Issues

- Review scale rule configuration
- Check metrics source (queue, HTTP, custom)
- Verify min/max replica settings
- Monitor scaling events in logs

### Connectivity Problems

- Verify ingress configuration
- Check VNet and subnet settings
- Review IP security restrictions
- Validate custom domain and certificate

## Related Components

- `azure-acr`: Azure Container Registry for private images
- `azure-log-analytics`: Centralized logging and monitoring
- `azure-keyvault`: Secret management
- `azure-vnet`: Virtual network for VNet integration
- `azure-user-identity`: User-assigned managed identities

## References

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Azure Container Apps Best Practices](https://learn.microsoft.com/en-us/azure/container-apps/plan)
- [Dapr on Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview)
- [KEDA Scalers](https://keda.sh/docs/scalers/)
