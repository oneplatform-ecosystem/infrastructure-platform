# Azure Document Intelligence Module

This module creates an Azure Document Intelligence (formerly Form Recognizer) with standardized naming conventions, security configurations, and document processing capabilities. It enables enterprise-grade document analysis, data extraction from forms, receipts, invoices, and custom documents.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Security First**: Default deny public access with network ACL support
- **Document Processing**: Form recognition, layout analysis, custom model training
- **Managed Identity**: Support for system and user-assigned managed identities
- **Network Isolation**: Virtual network integration and private endpoint support
- **Custom Subdomain**: Unique subdomain for API endpoint access
- **Consistent Tagging**: Automatic tag application based on label configuration

## Usage

### Basic Azure Document Intelligence
```yaml
components:
  terraform:
    azure-document-intelligence:
      vars:
        name: "docintel"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S0"
        public_network_access_enabled: false
```

### Azure Document Intelligence with Managed Identity
```yaml
components:
  terraform:
    azure-document-intelligence:
      vars:
        name: "docintel"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        identity_type: "SystemAssigned"
        public_network_access_enabled: false
```

### Azure Document Intelligence with Network ACLs
```yaml
components:
  terraform:
    azure-document-intelligence:
      vars:
        name: "docintel"
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

Azure Document Intelligence names follow the pattern: `{environment}{stage}{name}{namespace}`

### Examples
| Environment | Stage | Name | Namespace | Result |
|-------------|-------|------|-----------|--------|
| eus | dev | docintel | lazylabs | eusdevdocintellazylabs |
| eus | prod | forms | lazylabs | eusprodformslazylabs |
| wus | dev | ocr | lazylabs | wusdevocrlazylabs |

## Integration with Other Components

Azure Document Intelligence can be referenced by other components using Terraform outputs:

```yaml
# Application using Document Intelligence endpoint
azure-function-app:
  vars:
    app_settings:
      DOCUMENT_INTELLIGENCE_ENDPOINT: !terraform.output azure-document-intelligence.cognitive_account_endpoint
      DOCUMENT_INTELLIGENCE_API_KEY: !terraform.output azure-document-intelligence.primary_access_key
```

## Document Intelligence Capabilities

### Prebuilt Models
- **Invoices**: Extract key data from invoices
- **Receipts**: Parse receipt information
- **Business Cards**: Extract contact information
- **ID Documents**: Process passports, driver's licenses
- **W-2 Forms**: Extract tax form data
- **Health Insurance Cards**: Parse insurance information

### Layout Analysis
- Extract text, tables, and structure
- Detect selection marks (checkboxes, radio buttons)
- Identify document layout and reading order
- OCR with high accuracy

### Custom Models
- Train custom models on your documents
- Supervised learning with labeled data
- Unsupervised clustering for similar documents
- Composite models for complex scenarios

### Read API
- Extract printed and handwritten text
- Multi-page document support
- High-accuracy OCR
- 164 languages supported

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
    ComplianceScope: "gdpr,hipaa,pci"
    Owner: "document-processing-team"
```

### Data Protection
- Documents may contain PII and sensitive data
- Implement secure document storage
- Use encryption at rest and in transit
- Follow data retention and deletion policies
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
| location | The Azure Region where the Azure Document Intelligence should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| sku_name | The SKU name for the Azure Document Intelligence | `string` | `S0` | no |
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
| cognitive_account_id | The ID of the Azure Document Intelligence |
| cognitive_account_name | The name of the Azure Document Intelligence |
| cognitive_account_endpoint | The endpoint URL for API access |
| cognitive_account_location | The location of the service |
| primary_access_key | Primary access key (sensitive) |
| secondary_access_key | Secondary access key (sensitive) |
| identity_principal_id | Principal ID of managed identity |
| tags | Tags applied to the service |
| context | Exported context for use by other modules |

## Troubleshooting

### Common Issues

1. **Document Format Issues**
   - Supported formats: PDF, JPEG, PNG, BMP, TIFF
   - Check document size limits (varies by model)
   - Ensure document quality is sufficient for OCR
   - Verify document is not password-protected

2. **Custom Model Training**
   - Minimum 5 sample documents required
   - Samples should represent document variations
   - Label data consistently
   - Use Storage Account for training data

3. **Extraction Accuracy**
   - Document quality affects accuracy
   - Consider document preprocessing
   - Review and improve training data
   - Test with representative samples

4. **Rate Limiting**
   - API has transaction per second limits
   - Implement exponential backoff retry logic
   - Request quota increases if needed
   - Use async processing for large volumes

### Validation
```bash
# Check Azure Document Intelligence
az cognitiveservices account show \
  --name eusdevdocintellazylabs \
  --resource-group eusdevserviceslazylabs

# Test Document Intelligence endpoint (analyze layout)
curl -X POST "https://eusdevdocintellazylabs.cognitiveservices.azure.com/formrecognizer/v3.0/layout/analyze" \
  -H "Ocp-Apim-Subscription-Key: {your-key}" \
  -H "Content-Type: application/json" \
  -d '{"urlSource":"https://example.com/document.pdf"}'
```

## Best Practices

### Cost Optimization
- Use S0 tier for production workloads
- Use F0 (free) tier for development and testing
- Batch process documents when possible
- Monitor page processing usage
- Use prebuilt models before custom models

### Security
- Always use managed identities when possible
- Implement network isolation with private endpoints
- Enable Azure Monitor for audit logging
- Secure document storage locations
- Implement document retention policies

### Performance
- Use async processing for batch operations
- Optimize document size and format
- Implement retry logic with exponential backoff
- Monitor processing times and queue lengths
- Consider regional deployments for global users

### Accuracy
- Validate extraction results for your use case
- Train custom models with representative data
- Implement human-in-the-loop review for critical data
- Regularly retrain models with new samples
- Test with edge cases and variations

### Model Management
- Version control your custom models
- Document model performance metrics
- Implement A/B testing for model improvements
- Archive and backup training data
- Regular model evaluation and updates

### Governance
- Tag resources consistently for cost tracking
- Document data processing and retention policies
- Implement approval workflows for production deployments
- Regular security and compliance reviews
- Track model performance and accuracy metrics
