# Azure OpenAI Service Module

This module creates an Azure OpenAI Service (Cognitive Services Account) with standardized naming conventions, security configurations, and AI model deployment capabilities. It enables enterprise-grade deployment of OpenAI models like GPT-4, GPT-3.5, and embedding models.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Security First**: Default deny public access with network ACL support
- **Model Deployments**: Automated deployment of AI models (GPT-4, GPT-3.5, embeddings)
- **Managed Identity**: Support for system and user-assigned managed identities
- **Network Isolation**: Virtual network integration and private endpoint support
- **Custom Subdomain**: Unique subdomain for API endpoint access
- **Consistent Tagging**: Automatic tag application based on label configuration

## Usage

### Basic Azure OpenAI Service
```yaml
components:
  terraform:
    azure-openai:
      vars:
        name: "openai"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S0"
        public_network_access_enabled: false
```

### Azure OpenAI with Model Deployments
```yaml
components:
  terraform:
    azure-openai:
      vars:
        name: "openai"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S0"
        model_deployments:
          gpt4:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 10
          gpt35turbo:
            model_format: "OpenAI"
            model_name: "gpt-35-turbo"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 20
          embeddings:
            model_format: "OpenAI"
            model_name: "text-embedding-ada-002"
            model_version: "2"
            scale_type: "Standard"
            scale_capacity: 10
```

### Azure OpenAI with Managed Identity
```yaml
components:
  terraform:
    azure-openai:
      vars:
        name: "openai"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        identity_type: "SystemAssigned"
        public_network_access_enabled: false
```

### Azure OpenAI with Network ACLs
```yaml
components:
  terraform:
    azure-openai:
      vars:
        name: "openai"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        public_network_access_enabled: false
        network_acls:
          default_action: "Deny"
          ip_rules:
            - "203.0.113.0/24"
          subnet_id: "/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}"
```

## Naming Convention

Azure OpenAI Service names follow the pattern: `{environment}{stage}{name}{namespace}`

### Examples
| Environment | Stage | Name | Namespace | Result |
|-------------|-------|------|-----------|--------|
| eus | dev | openai | lazylabs | eusdevopenailazylabs |
| eus | prod | ai | lazylabs | eusprodailazylabs |
| wus | dev | cognitive | lazylabs | wusdevcognitivelazylabs |

## Integration with Other Components

Azure OpenAI Service can be referenced by other components using Terraform outputs:

```yaml
# Application using OpenAI endpoint
azure-function-app:
  vars:
    app_settings:
      OPENAI_ENDPOINT: !terraform.output azure-openai.cognitive_account_endpoint
      OPENAI_API_KEY: !terraform.output azure-openai.primary_access_key
```

## AI Model Deployment

### Supported Models

**GPT Models:**
- `gpt-4` - Most capable model for complex tasks
- `gpt-4-32k` - Extended context window version
- `gpt-35-turbo` - Fast and efficient for most tasks
- `gpt-35-turbo-16k` - Extended context version

**Embedding Models:**
- `text-embedding-ada-002` - Latest embedding model

### Model Deployment Example
```yaml
model_deployments:
  production-gpt4:
    model_format: "OpenAI"
    model_name: "gpt-4"
    model_version: "0613"
    scale_type: "Standard"
    scale_capacity: 30  # Higher capacity for production

  dev-gpt35:
    model_format: "OpenAI"
    model_name: "gpt-35-turbo"
    model_version: "0613"
    scale_type: "Standard"
    scale_capacity: 10  # Lower capacity for development
```

## Security Best Practices

### Network Security
```yaml
vars:
  # Disable public access
  public_network_access_enabled: false

  # Configure network ACLs
  network_acls:
    default_action: "Deny"
    ip_rules:
      - "10.0.0.0/8"  # Allow internal network
    subnet_id: "/subscriptions/.../subnets/private-subnet"
```

### Identity and Access Management
```yaml
vars:
  # Use managed identity for authentication
  identity_type: "SystemAssigned"

  # Tags for governance
  tags:
    Environment: "production"
    DataClassification: "confidential"
    ComplianceScope: "gdpr,hipaa"
    Owner: "ai-platform-team"
```

### Access Key Management
- Rotate access keys regularly
- Use managed identities instead of access keys when possible
- Store keys in Azure Key Vault
- Implement least privilege access

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | = 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | = 4.23.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| location | The Azure Region where the Azure OpenAI Service should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| sku_name | The SKU name for the Azure OpenAI Service | `string` | `S0` | no |
| custom_subdomain_name | Custom subdomain name (uses label ID if not provided) | `string` | `null` | no |
| public_network_access_enabled | Whether public network access is allowed | `bool` | `false` | no |
| network_acls | Network rules restricting access | `object` | `null` | no |
| identity_type | Type of Managed Identity (SystemAssigned, UserAssigned) | `string` | `null` | no |
| identity_ids | List of User Assigned Managed Identity IDs | `list(string)` | `null` | no |
| model_deployments | Map of AI model deployments to create | `map(object)` | `{}` | no |
| namespace | ID element. Usually an abbreviation of your organization name | `string` | `null` | no |
| environment | ID element. Usually used for region (e.g. 'eus', 'wus') | `string` | `null` | no |
| stage | ID element. Usually used to indicate role (e.g. 'prod', 'dev') | `string` | `null` | no |
| name | ID element. Usually the component or solution name | `string` | `null` | no |
| attributes | ID element. Additional attributes to add to ID | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cognitive_account_id | The ID of the Azure OpenAI Service |
| cognitive_account_name | The name of the Azure OpenAI Service |
| cognitive_account_endpoint | The endpoint URL for API access |
| cognitive_account_location | The location of the service |
| primary_access_key | Primary access key (sensitive) |
| secondary_access_key | Secondary access key (sensitive) |
| identity_principal_id | Principal ID of managed identity |
| model_deployments | Map of deployed AI models |
| tags | Tags applied to the service |
| context | Exported context for use by other modules |

## Examples

### Complete Stack Integration
```yaml
components:
  terraform:
    # Resource group
    azure-resource-group:
      vars:
        name: "ai-services"
        location: "East US"

    # Azure OpenAI Service
    azure-openai:
      settings:
        depends_on:
          - azure-resource-group
      vars:
        name: "openai"
        location: "East US"
        resource_group_name: "${var.environment}${var.stage}${components.terraform.azure-resource-group.vars.name}${var.namespace}"
        identity_type: "SystemAssigned"
        model_deployments:
          gpt4:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 10
```

## Troubleshooting

### Common Issues

1. **Quota Limitations**
   - Azure OpenAI has regional quota limits
   - Request quota increases through Azure Portal
   - Consider distributing load across regions

2. **Model Version Not Available**
   - Check model availability in your region
   - Verify model version string is correct
   - Some models are in limited preview

3. **Network Connectivity Issues**
   - Verify network ACLs are correctly configured
   - Check subnet service endpoints are enabled
   - Ensure private endpoint DNS resolution is working

4. **Authentication Failures**
   - Verify managed identity has correct permissions
   - Check access keys are correctly retrieved
   - Ensure token generation is working

### Validation
```bash
# Validate the Azure OpenAI component
./scripts/validate-component.sh azure-openai core-eus-dev

# Check Azure OpenAI Service
az cognitiveservices account show \
  --name eusdevopenailazylabs \
  --resource-group eusdevserviceslazylabs

# List model deployments
az cognitiveservices account deployment list \
  --name eusdevopenailazylabs \
  --resource-group eusdevserviceslazylabs
```

## Best Practices

### Model Deployment Strategy
- Start with lower capacity and scale up based on usage
- Deploy multiple models for different use cases
- Use separate services for dev/test/prod environments
- Monitor token usage and adjust capacity accordingly

### Cost Optimization
- Right-size model deployments based on actual usage
- Use appropriate models for tasks (don't always use GPT-4)
- Implement caching strategies in your applications
- Monitor and optimize prompt design

### Security
- Always use managed identities when possible
- Implement network isolation with private endpoints
- Enable Azure Monitor for audit logging
- Implement rate limiting in applications

### Governance
- Tag resources consistently for cost tracking
- Implement approval workflows for production deployments
- Document model usage and performance metrics
- Regular security and compliance reviews
