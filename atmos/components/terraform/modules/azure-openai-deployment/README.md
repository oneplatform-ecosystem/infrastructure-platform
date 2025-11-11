# Azure OpenAI Model Deployments Module

This module creates Azure OpenAI model deployments within an existing Azure OpenAI Service (Cognitive Services Account). It provides a modular approach to deploying AI models like GPT-4, GPT-3.5, and embedding models with standardized naming conventions and configuration management.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Multiple Deployments**: Deploy multiple models in a single configuration
- **Flexible Scaling**: Support for Standard, GlobalStandard, and ProvisionedManaged scale types
- **Version Management**: Automatic version upgrade options
- **Dynamic Throttling**: Enable/disable dynamic throttling per deployment
- **RAI Policy Support**: Attach Responsible AI policies to deployments
- **Consistent Tagging**: Automatic tag application based on label configuration

## Usage

### Basic Model Deployment
```yaml
components:
  terraform:
    azure-openai-deployment-gpt4:
      metadata:
        component: azure-openai-deployment
      settings:
        depends_on:
          1:
            component: "azure-openai"
      vars:
        name: "gpt4"
        cognitive_account_id: !terraform.output azure-openai.cognitive_account_id
        deployments:
          gpt4:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 10
```

### Multiple Model Deployments
```yaml
components:
  terraform:
    azure-openai-deployments:
      metadata:
        component: azure-openai-deployment
      settings:
        depends_on:
          1:
            component: "azure-openai"
      vars:
        name: "models"
        cognitive_account_id: !terraform.output azure-openai.cognitive_account_id
        deployments:
          gpt4:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 30
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

### Advanced Configuration with Version Upgrade
```yaml
components:
  terraform:
    azure-openai-deployment-gpt4:
      metadata:
        component: azure-openai-deployment
      vars:
        name: "gpt4-prod"
        cognitive_account_id: !terraform.output azure-openai.cognitive_account_id
        deployments:
          gpt4-prod:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 50
            version_upgrade_option: "OnceNewDefaultVersionAvailable"
            dynamic_throttling_enabled: true
```

### Provisioned Managed Deployment
```yaml
components:
  terraform:
    azure-openai-deployment-provisioned:
      metadata:
        component: azure-openai-deployment
      vars:
        name: "gpt4-provisioned"
        cognitive_account_id: !terraform.output azure-openai.cognitive_account_id
        deployments:
          gpt4-high-capacity:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "ProvisionedManaged"
            scale_capacity: 100
            version_upgrade_option: "NoAutoUpgrade"
```

## Naming Convention

Deployment names are defined by the keys in the `deployments` map. The module uses the label module for consistent metadata.

### Examples
| Environment | Stage | Name | Namespace | Module Label |
|-------------|-------|------|-----------|--------------|
| eus | dev | models | lazylabs | eusdevmodelslazylabs |
| eus | prod | gpt4 | lazylabs | eusprodgpt4lazylabs |
| wus | dev | embeddings | lazylabs | wusdevembeddingslazylabs |

## Integration with Other Components

Model deployments can be referenced by applications using Terraform outputs:

```yaml
# Application using specific model deployment
azure-function-app:
  vars:
    app_settings:
      OPENAI_ENDPOINT: !terraform.output azure-openai.cognitive_account_endpoint
      OPENAI_API_KEY: !terraform.output azure-openai.primary_access_key
      GPT4_DEPLOYMENT_NAME: "gpt4"  # From deployments map key
      EMBEDDINGS_DEPLOYMENT_NAME: "embeddings"
```

## AI Model Deployment

### Supported Models

**GPT Models:**
- `gpt-4` - Most capable model for complex tasks
- `gpt-4-32k` - Extended context window version
- `gpt-4-turbo` - Latest turbo variant
- `gpt-35-turbo` - Fast and efficient for most tasks
- `gpt-35-turbo-16k` - Extended context version

**Embedding Models:**
- `text-embedding-ada-002` - Latest embedding model
- `text-embedding-3-small` - Smaller, faster embedding model
- `text-embedding-3-large` - Larger, more capable embedding model

**Model Versions:**
- Check Azure documentation for available versions
- Common versions: `0613`, `1106`, `0125`
- Use `version_upgrade_option` to manage upgrades

### Scale Types

**Standard:**
- Pay-as-you-go pricing
- Automatic scaling based on demand
- Suitable for most workloads

**GlobalStandard:**
- Global deployment for better availability
- Automatic routing to available regions
- Enhanced SLA

**ProvisionedManaged:**
- Reserved capacity for predictable performance
- Higher upfront cost, lower per-token cost
- Best for high-volume, consistent workloads

### Version Upgrade Options

- `OnceCurrentVersionExpired` (default) - Upgrade when current version expires
- `OnceNewDefaultVersionAvailable` - Upgrade immediately when new default available
- `NoAutoUpgrade` - Manual upgrades only

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
| cognitive_account_id | The ID of the Azure OpenAI Service | `string` | n/a | yes |
| deployments | Map of AI model deployments to create | `map(object)` | `{}` | no |
| namespace | ID element. Usually an abbreviation of your organization name | `string` | `null` | no |
| environment | ID element. Usually used for region (e.g. 'eus', 'wus') | `string` | `null` | no |
| stage | ID element. Usually used to indicate role (e.g. 'prod', 'dev') | `string` | `null` | no |
| name | ID element. Usually the component or solution name | `string` | `null` | no |
| attributes | ID element. Additional attributes to add to ID | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

### Deployments Object Structure

```hcl
deployments = {
  deployment-name = {
    model_format                 = string  # Required: "OpenAI"
    model_name                   = string  # Required: e.g., "gpt-4", "gpt-35-turbo"
    model_version                = string  # Required: e.g., "0613", "1106"
    scale_type                   = string  # Required: "Standard", "GlobalStandard", or "ProvisionedManaged"
    scale_capacity               = number  # Optional: Default 1
    scale_tier                   = string  # Optional
    scale_size                   = string  # Optional
    scale_family                 = string  # Optional
    rai_policy_name              = string  # Optional: RAI policy name
    version_upgrade_option       = string  # Optional: Default "OnceCurrentVersionExpired"
    dynamic_throttling_enabled   = bool    # Optional: Default false
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| deployments | Map of deployed AI models with complete metadata |
| deployment_ids | Map of deployment names to their IDs |
| deployment_names | List of all deployment names |
| deployment_endpoints | Map of deployment names to cognitive account IDs |
| tags | Tags applied to the deployments |
| context | Exported context for use by other modules |
| id | Disambiguated ID from label module |
| enabled | Whether this module is enabled |

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
          1:
            component: "azure-resource-group"
      vars:
        name: "openai"
        location: "East US"
        resource_group_name: !terraform.output azure-resource-group.resource_group_name

    # Model Deployments
    azure-openai-deployment-prod:
      metadata:
        component: azure-openai-deployment
      settings:
        depends_on:
          1:
            component: "azure-openai"
      vars:
        name: "prod-models"
        cognitive_account_id: !terraform.output azure-openai.cognitive_account_id
        deployments:
          gpt4:
            model_format: "OpenAI"
            model_name: "gpt-4"
            model_version: "0613"
            scale_type: "Standard"
            scale_capacity: 30
            version_upgrade_option: "OnceNewDefaultVersionAvailable"
          embeddings:
            model_format: "OpenAI"
            model_name: "text-embedding-ada-002"
            model_version: "2"
            scale_type: "Standard"
            scale_capacity: 20
```

### Environment-Specific Deployments
```yaml
# Development environment - lower capacity
azure-openai-deployment-dev:
  metadata:
    component: azure-openai-deployment
  vars:
    name: "dev-models"
    cognitive_account_id: !terraform.output azure-openai-dev.cognitive_account_id
    deployments:
      gpt35turbo:
        model_format: "OpenAI"
        model_name: "gpt-35-turbo"
        model_version: "0613"
        scale_type: "Standard"
        scale_capacity: 10

# Production environment - higher capacity
azure-openai-deployment-prod:
  metadata:
    component: azure-openai-deployment
  vars:
    name: "prod-models"
    cognitive_account_id: !terraform.output azure-openai-prod.cognitive_account_id
    deployments:
      gpt4:
        model_format: "OpenAI"
        model_name: "gpt-4"
        model_version: "0613"
        scale_type: "ProvisionedManaged"
        scale_capacity: 100
```

## Troubleshooting

### Common Issues

1. **Quota Limitations**
   - Azure OpenAI has regional quota limits for model deployments
   - Request quota increases through Azure Portal
   - Consider distributing deployments across multiple regions

2. **Model Version Not Available**
   - Check model availability in your region using Azure Portal
   - Verify model version string matches available versions
   - Some models are in limited preview or specific regions

3. **Deployment Conflicts**
   - Each deployment name must be unique within an OpenAI service
   - Check for existing deployments before creating new ones
   - Use descriptive names to avoid conflicts

4. **Capacity Constraints**
   - Total capacity across all deployments is subject to quota
   - Monitor capacity usage across deployments
   - Adjust capacity based on actual usage patterns

### Validation
```bash
# Validate the deployment configuration
./scripts/validate-component.sh azure-openai-deployment core-eus-dev

# List model deployments
az cognitiveservices account deployment list \
  --name eusdevopenailazylabs \
  --resource-group eusdevserviceslazylabs

# Show specific deployment
az cognitiveservices account deployment show \
  --name eusdevopenailazylabs \
  --resource-group eusdevserviceslazylabs \
  --deployment-name gpt4
```

## Best Practices

### Deployment Strategy
- Separate deployments by use case or application
- Use descriptive deployment names
- Start with lower capacity and scale based on usage
- Plan for separate dev/test/prod deployments

### Capacity Planning
- Monitor token usage to right-size capacity
- Use appropriate scale types for workload patterns
- Consider ProvisionedManaged for high-volume, predictable workloads
- Scale capacity during business hours if needed

### Version Management
- Use `OnceCurrentVersionExpired` for stability
- Test new versions in dev before production
- Use `NoAutoUpgrade` for critical production deployments
- Document model versions in use

### Cost Optimization
- Right-size deployment capacity based on actual usage
- Use appropriate models for tasks (GPT-3.5 vs GPT-4)
- Monitor unused deployments and remove them
- Consider GlobalStandard for geo-distributed applications

### Governance
- Tag deployments consistently for cost tracking
- Document deployment purpose and usage
- Implement approval workflows for production deployments
- Regular review of deployment configurations and capacity

## Migration Guide

### Migrating from Embedded Deployments

If you previously used the `azure-openai` module with embedded `model_deployments`, you can migrate to this standalone module:

**Before (embedded):**
```yaml
azure-openai:
  vars:
    model_deployments:
      gpt4:
        model_format: "OpenAI"
        model_name: "gpt-4"
        model_version: "0613"
        scale_type: "Standard"
        scale_capacity: 10
```

**After (standalone):**
```yaml
azure-openai:
  vars:
    # Remove model_deployments from here

azure-openai-deployment:
  metadata:
    component: azure-openai-deployment
  settings:
    depends_on:
      1:
        component: "azure-openai"
  vars:
    cognitive_account_id: !terraform.output azure-openai.cognitive_account_id
    deployments:
      gpt4:
        model_format: "OpenAI"
        model_name: "gpt-4"
        model_version: "0613"
        scale_type: "Standard"
        scale_capacity: 10
```

**Benefits of standalone module:**
- Independent lifecycle management
- Easier to manage multiple deployment groups
- Better separation of concerns
- Can update deployments without touching OpenAI service configuration
