# Azure Content Safety Module

This module creates an Azure Content Safety (Cognitive Services Account) with standardized naming conventions, security configurations, and content moderation capabilities. It enables enterprise-grade detection of harmful content including hate speech, violence, self-harm, and sexual content in both text and images.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Security First**: Default deny public access with network ACL support
- **Content Moderation**: Detect hate, violence, self-harm, and sexual content
- **Multi-modal**: Support for both text and image analysis
- **Managed Identity**: Support for system and user-assigned managed identities
- **Network Isolation**: Virtual network integration and private endpoint support
- **Custom Subdomain**: Unique subdomain for API endpoint access
- **Consistent Tagging**: Automatic tag application based on label configuration

## Features

### Text Analysis
- **Hate Speech**: Detect hateful and discriminatory language
- **Violence**: Identify violent content and threats
- **Self-Harm**: Detect self-harm and suicide-related content
- **Sexual Content**: Identify sexual and adult content
- **Severity Levels**: 0-7 scale for each category
- **Multi-language**: Support for multiple languages

### Image Analysis
- **Hate Symbols**: Detect hate symbols and imagery
- **Violence**: Identify violent and graphic imagery
- **Self-Harm**: Detect self-harm related imagery
- **Sexual Content**: Identify adult and sexual imagery
- **Severity Scoring**: Detailed severity assessment

### Customization
- **Custom Categories**: Define custom content categories
- **Blocklists**: Manage custom term blocklists
- **Thresholds**: Configure severity thresholds
- **Allowlists**: Define exception lists

## Usage

### Basic Azure Content Safety
```yaml
components:
  terraform:
    azure-content-safety:
      vars:
        name: "safety"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S0"
        public_network_access_enabled: false
```

### Azure Content Safety with Managed Identity
```yaml
components:
  terraform:
    azure-content-safety:
      vars:
        name: "safety"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        identity_type: "SystemAssigned"
        public_network_access_enabled: false
```

### Azure Content Safety with Network ACLs
```yaml
components:
  terraform:
    azure-content-safety:
      vars:
        name: "safety"
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

Azure Content Safety names follow the pattern: `{environment}{stage}{name}{namespace}`

### Examples
| Environment | Stage | Name | Namespace | Result |
|-------------|-------|------|-----------|--------|
| eus | dev | safety | lazylabs | eusdevsafetylazylabs |
| eus | prod | moderation | lazylabs | eusprodmoderationlazylabs |
| wus | dev | filter | lazylabs | wusdevfilterlazylabs |

## Integration with Other Components

Azure Content Safety can be referenced by other components using Terraform outputs:

```yaml
# Application using Content Safety endpoint
azure-function-app:
  vars:
    app_settings:
      CONTENT_SAFETY_ENDPOINT: !terraform.output azure-content-safety.cognitive_account_endpoint
      CONTENT_SAFETY_API_KEY: !terraform.output azure-content-safety.primary_access_key
```

## Content Safety Categories

### Hate Content
- Discriminatory language based on protected attributes
- Slurs and derogatory terms
- Hate symbols and imagery
- Severity levels: 0 (safe) to 7 (severe)

### Violence
- Graphic violence descriptions
- Threats and calls to violence
- Violent imagery
- Severity levels: 0 (safe) to 7 (severe)

### Self-Harm
- Self-injury descriptions
- Suicide-related content
- Eating disorders
- Severity levels: 0 (safe) to 7 (severe)

### Sexual Content
- Adult and explicit content
- Sexual solicitation
- Inappropriate imagery
- Severity levels: 0 (safe) to 7 (severe)

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
    ComplianceScope: "coppa,gdpr"
    Owner: "trust-safety-team"
```

### Data Protection
- Content submitted may contain harmful material
- Implement secure logging and audit trails
- Follow data retention and deletion policies
- Consider regional data residency requirements
- Document incident response procedures

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
| location | The Azure Region where the Azure Content Safety should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| sku_name | The SKU name for the Azure Content Safety | `string` | `S0` | no |
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
| cognitive_account_id | The ID of the Azure Content Safety |
| cognitive_account_name | The name of the Azure Content Safety |
| cognitive_account_endpoint | The endpoint URL for API access |
| cognitive_account_location | The location of the service |
| primary_access_key | Primary access key (sensitive) |
| secondary_access_key | Secondary access key (sensitive) |
| identity_principal_id | Principal ID of managed identity |
| tags | Tags applied to the service |
| context | Exported context for use by other modules |

## Troubleshooting

### Common Issues

1. **False Positives/Negatives**
   - Adjust severity thresholds for your use case
   - Use custom blocklists for domain-specific terms
   - Implement human review for edge cases
   - Regular testing with representative content

2. **Performance**
   - Text analysis is very fast (<100ms)
   - Image analysis may take 1-2 seconds
   - Implement caching for repeated content
   - Use async processing for bulk moderation

3. **Language Support**
   - Primary support for English
   - Limited support for other languages
   - Consider translation for non-English content
   - Test thoroughly with your target languages

4. **Rate Limiting**
   - API has transaction per second limits
   - Implement exponential backoff retry logic
   - Request quota increases if needed
   - Monitor usage patterns

### Validation
```bash
# Check Azure Content Safety
az cognitiveservices account show \
  --name eusdevsafetylazylabs \
  --resource-group eusdevserviceslazylabs

# Test Content Safety endpoint (analyze text)
curl -X POST "https://eusdevsafetylazylabs.cognitiveservices.azure.com/contentsafety/text:analyze?api-version=2023-10-01" \
  -H "Ocp-Apim-Subscription-Key: {your-key}" \
  -H "Content-Type: application/json" \
  -d '{"text":"Sample text to analyze"}'
```

## Best Practices

### Cost Optimization
- Use S0 tier for production workloads
- Use F0 (free) tier for development and testing
- Cache results for identical content
- Implement pre-filtering to reduce API calls
- Monitor usage patterns

### Security
- Always use managed identities when possible
- Implement network isolation with private endpoints
- Enable Azure Monitor for audit logging
- Secure storage of flagged content
- Implement access controls

### Moderation Strategy
- **Multi-layered**: Combine automated and human moderation
- **Threshold Tuning**: Adjust thresholds based on your community standards
- **Custom Blocklists**: Maintain domain-specific term lists
- **Appeals Process**: Allow users to appeal moderation decisions
- **Transparency**: Clearly communicate moderation policies

### Performance
- Use async processing for bulk moderation
- Implement caching for frequently submitted content
- Pre-filter obvious violations before API calls
- Monitor latency and throughput metrics
- Deploy services close to your users

### Accuracy
- Regular testing with diverse content samples
- Validate results against your moderation policies
- Implement human review for borderline cases
- Track false positive/negative rates
- Continuous model evaluation

### Compliance
- Document moderation policies and procedures
- Implement audit logging for all moderation actions
- Regular compliance reviews
- User privacy protection
- Transparency reports

### Governance
- Tag resources consistently for cost tracking
- Document content moderation policies
- Implement approval workflows for policy changes
- Regular security and compliance reviews
- Track moderation metrics and effectiveness

## Use Cases

### Social Media Platforms
- User-generated content moderation
- Comment filtering
- Profile image screening
- Real-time chat moderation

### E-commerce
- Product review moderation
- Seller communication filtering
- User profile screening
- Marketplace safety

### Gaming
- In-game chat moderation
- Username screening
- User-created content review
- Community safety

### Enterprise Communication
- Internal chat moderation
- Document screening
- Email filtering
- Collaboration platform safety

## Responsible AI Considerations

### Transparency
- Clearly communicate when and how content moderation is used
- Provide explanations for moderation decisions
- Document moderation policies publicly

### Fairness
- Test for bias across different demographics
- Regular fairness evaluations
- Diverse testing datasets
- Inclusive moderation policies

### Privacy
- Minimize data retention
- Secure handling of sensitive content
- User consent and transparency
- Data minimization principles

### Human Oversight
- Human review for critical decisions
- Appeals process for users
- Regular quality audits
- Moderator training and support
