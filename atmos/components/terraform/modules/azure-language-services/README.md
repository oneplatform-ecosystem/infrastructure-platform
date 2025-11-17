# Azure Language Services Module

This module creates an Azure Language Services (Cognitive Services Account) with standardized naming conventions, security configurations, and natural language processing capabilities. It enables enterprise-grade text analytics, sentiment analysis, entity recognition, key phrase extraction, and language detection.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Security First**: Default deny public access with network ACL support
- **NLP Capabilities**: Sentiment analysis, entity recognition, key phrase extraction, language detection
- **Managed Identity**: Support for system and user-assigned managed identities
- **Network Isolation**: Virtual network integration and private endpoint support
- **Custom Subdomain**: Unique subdomain for API endpoint access
- **Consistent Tagging**: Automatic tag application based on label configuration

## Usage

### Basic Azure Language Services
```yaml
components:
  terraform:
    azure-language-services:
      vars:
        name: "language"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S"
        public_network_access_enabled: false
```

### Azure Language Services with Managed Identity
```yaml
components:
  terraform:
    azure-language-services:
      vars:
        name: "language"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        identity_type: "SystemAssigned"
        public_network_access_enabled: false
```

### Azure Language Services with Network ACLs
```yaml
components:
  terraform:
    azure-language-services:
      vars:
        name: "language"
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

Azure Language Services names follow the pattern: `{environment}{stage}{name}{namespace}`

### Examples
| Environment | Stage | Name | Namespace | Result |
|-------------|-------|------|-----------|--------|
| eus | dev | language | lazylabs | eusdevlanguagelazylabs |
| eus | prod | nlp | lazylabs | eusprodnlplazylabs |
| wus | dev | text | lazylabs | wusdevtextlazylabs |

## Integration with Other Components

Azure Language Services can be referenced by other components using Terraform outputs:

```yaml
# Application using Language Services endpoint
azure-function-app:
  vars:
    app_settings:
      LANGUAGE_ENDPOINT: !terraform.output azure-language-services.cognitive_account_endpoint
      LANGUAGE_API_KEY: !terraform.output azure-language-services.primary_access_key
```

## Language Capabilities

### Sentiment Analysis
- Detect positive, negative, neutral, or mixed sentiment
- Sentence-level sentiment scoring
- Opinion mining
- Multi-language support

### Entity Recognition
- Named Entity Recognition (NER)
- Personal Identifiable Information (PII) detection
- Health entity extraction
- Custom entity extraction

### Key Phrase Extraction
- Automatic key phrase identification
- Main talking points extraction
- Multi-language support

### Language Detection
- Automatic language identification
- Script detection
- Confidence scoring

### Text Analytics for Health
- Medical entity extraction
- Relation extraction
- Entity linking to medical ontologies

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
    Owner: "nlp-platform-team"
```

### Data Protection
- Language Services processes text data - ensure PII compliance
- Use PII detection features for sensitive data
- Implement data retention policies
- Consider regional data residency requirements

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
| location | The Azure Region where the Azure Language Services should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| sku_name | The SKU name for the Azure Language Services | `string` | `S` | no |
| custom_subdomain_name | Custom subdomain name (uses label ID if not provided) | `string` | `null` | no |
| public_network_access_enabled | Whether public network access is allowed | `bool` | `false` | no |
| network_acls | Network rules restricting access | `object` | `null` | no |
| identity_type | Type of Managed Identity (SystemAssigned, UserAssigned) | `string` | `null` | no |
| identity_ids | List of User Assigned Managed Identity IDs | `list(string)` | `null` | no |
| namespace | ID element. Usually an abbreviation of your organization name | `string` | `null` | no |
| environment | ID element. Usually used for region (e.g. 'eus', 'wus') | `string` | `null` | no |
| stage | ID element. Usually used to indicate role (e.g. 'prod', 'dev') | `string` | `null` | no |
| name | ID element. Usually the component or solution name | `string` | `null` | no |
| attributes | ID element. Additional attributes to add to ID | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cognitive_account_id | The ID of the Azure Language Services |
| cognitive_account_name | The name of the Azure Language Services |
| cognitive_account_endpoint | The endpoint URL for API access |
| cognitive_account_location | The location of the service |
| primary_access_key | Primary access key (sensitive) |
| secondary_access_key | Secondary access key (sensitive) |
| identity_principal_id | Principal ID of managed identity |
| tags | Tags applied to the service |
| context | Exported context for use by other modules |

## Troubleshooting

### Common Issues

1. **Character Limits**
   - Text Analytics has document size limits
   - Split large documents into smaller chunks
   - Check API documentation for current limits

2. **Language Support**
   - Not all features support all languages
   - Check language availability for specific features
   - Plan for unsupported language scenarios

3. **Rate Limiting**
   - API has transaction per second limits
   - Implement exponential backoff retry logic
   - Request quota increases if needed

4. **PII Detection Accuracy**
   - Review and validate PII detection results
   - Consider custom entity models for domain-specific PII
   - Implement additional validation layers

### Validation
```bash
# Check Azure Language Services
az cognitiveservices account show \
  --name eusdevlanguagelazylabs \
  --resource-group eusdevserviceslazylabs

# Test Language Services endpoint (sentiment analysis)
curl -X POST "https://eusdevlanguagelazylabs.cognitiveservices.azure.com/text/analytics/v3.1/sentiment" \
  -H "Ocp-Apim-Subscription-Key: {your-key}" \
  -H "Content-Type: application/json" \
  -d '{"documents":[{"id":"1","text":"Great product!"}]}'
```

## Best Practices

### Cost Optimization
- Use S tier for production workloads
- Use F0 (free) tier for development and testing
- Batch process documents when possible
- Monitor usage to optimize capacity

### Security
- Always use managed identities when possible
- Implement network isolation with private endpoints
- Enable Azure Monitor for audit logging
- Use PII detection to protect sensitive data

### Performance
- Batch multiple documents in single requests
- Implement caching for repeated analyses
- Use asynchronous processing for large volumes
- Monitor latency and throughput metrics

### Accuracy
- Validate results for your specific domain
- Consider custom models for specialized text
- Implement human-in-the-loop review for critical decisions
- Regularly review and update entity models

### Governance
- Tag resources consistently for cost tracking
- Document data processing and retention policies
- Implement approval workflows for production deployments
- Regular security and compliance reviews
