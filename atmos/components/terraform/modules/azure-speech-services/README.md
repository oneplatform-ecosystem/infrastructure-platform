# Azure Speech Services Module

This module creates an Azure Speech Services (Cognitive Services Account) with standardized naming conventions, security configurations, and speech capabilities. It enables enterprise-grade speech-to-text, text-to-speech, speech translation, and speaker recognition services.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Security First**: Default deny public access with network ACL support
- **Speech Capabilities**: Speech-to-text, text-to-speech, translation, and speaker recognition
- **Managed Identity**: Support for system and user-assigned managed identities
- **Network Isolation**: Virtual network integration and private endpoint support
- **Custom Subdomain**: Unique subdomain for API endpoint access
- **Consistent Tagging**: Automatic tag application based on label configuration

## Usage

### Basic Azure Speech Services
```yaml
components:
  terraform:
    azure-speech-services:
      vars:
        name: "speech"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S0"
        public_network_access_enabled: false
```

### Azure Speech Services with Managed Identity
```yaml
components:
  terraform:
    azure-speech-services:
      vars:
        name: "speech"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        identity_type: "SystemAssigned"
        public_network_access_enabled: false
```

### Azure Speech Services with Network ACLs
```yaml
components:
  terraform:
    azure-speech-services:
      vars:
        name: "speech"
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

Azure Speech Services names follow the pattern: `{environment}{stage}{name}{namespace}`

### Examples
| Environment | Stage | Name | Namespace | Result |
|-------------|-------|------|-----------|--------|
| eus | dev | speech | lazylabs | eusdevspeechlazylabs |
| eus | prod | voice | lazylabs | eusprodvoicelazylabs |
| wus | dev | stt | lazylabs | wusdevstllazylabs |

## Integration with Other Components

Azure Speech Services can be referenced by other components using Terraform outputs:

```yaml
# Application using Speech Services endpoint
azure-function-app:
  vars:
    app_settings:
      SPEECH_ENDPOINT: !terraform.output azure-speech-services.cognitive_account_endpoint
      SPEECH_API_KEY: !terraform.output azure-speech-services.primary_access_key
```

## Speech Capabilities

### Speech-to-Text
- Real-time and batch transcription
- Custom speech models
- Pronunciation assessment
- Multi-language support

### Text-to-Speech
- Neural text-to-speech voices
- Custom neural voices
- SSML support
- Audio content creation

### Speech Translation
- Real-time speech translation
- Multi-language support
- Conversation transcription

### Speaker Recognition
- Speaker verification
- Speaker identification
- Voice profile management

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
| location | The Azure Region where the Azure Speech Services should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| sku_name | The SKU name for the Azure Speech Services | `string` | `S0` | no |
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
| cognitive_account_id | The ID of the Azure Speech Services |
| cognitive_account_name | The name of the Azure Speech Services |
| cognitive_account_endpoint | The endpoint URL for API access |
| cognitive_account_location | The location of the service |
| primary_access_key | Primary access key (sensitive) |
| secondary_access_key | Secondary access key (sensitive) |
| identity_principal_id | Principal ID of managed identity |
| tags | Tags applied to the service |
| context | Exported context for use by other modules |

## Troubleshooting

### Common Issues

1. **Region Availability**
   - Not all features are available in all regions
   - Check Azure Speech Services regional availability
   - Consider using multiple regions for redundancy

2. **Quota Limitations**
   - Speech Services have concurrent request limits
   - Request quota increases through Azure Portal
   - Monitor usage to avoid throttling

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
# Check Azure Speech Services
az cognitiveservices account show \
  --name eusdevspeechlazylabs \
  --resource-group eusdevserviceslazylabs

# Test Speech Services endpoint
curl -X POST "https://eusdevspeechlazylabs.cognitiveservices.azure.com/sts/v1.0/issueToken" \
  -H "Ocp-Apim-Subscription-Key: {your-key}"
```

## Best Practices

### Cost Optimization
- Use S0 tier for production workloads
- Use F0 (free) tier for development and testing
- Monitor usage to optimize capacity
- Implement caching strategies in applications

### Security
- Always use managed identities when possible
- Implement network isolation with private endpoints
- Enable Azure Monitor for audit logging
- Implement rate limiting in applications

### Performance
- Deploy services close to your users
- Use batch processing for large-scale transcription
- Implement retry logic with exponential backoff
- Monitor latency and throughput metrics

### Governance
- Tag resources consistently for cost tracking
- Implement approval workflows for production deployments
- Document speech service usage patterns
- Regular security and compliance reviews
