# Azure Computer Vision Module

This module creates an Azure Computer Vision (Cognitive Services Account) with standardized naming conventions, security configurations, and image analysis capabilities. It enables enterprise-grade image analysis, OCR, object detection, face detection, and spatial analysis.

## Features

- **Standardized Naming**: Uses cloudposse/label for consistent resource naming
- **Conditional Creation**: Enable/disable with `var.enabled` flag
- **Security First**: Default deny public access with network ACL support
- **Vision Capabilities**: Image analysis, OCR, object detection, face detection, spatial analysis
- **Managed Identity**: Support for system and user-assigned managed identities
- **Network Isolation**: Virtual network integration and private endpoint support
- **Custom Subdomain**: Unique subdomain for API endpoint access
- **Consistent Tagging**: Automatic tag application based on label configuration

## Usage

### Basic Azure Computer Vision
```yaml
components:
  terraform:
    azure-computer-vision:
      vars:
        name: "vision"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        sku_name: "S1"
        public_network_access_enabled: false
```

### Azure Computer Vision with Managed Identity
```yaml
components:
  terraform:
    azure-computer-vision:
      vars:
        name: "vision"
        location: "East US"
        resource_group_name: "eusdevserviceslazylabs"
        identity_type: "SystemAssigned"
        public_network_access_enabled: false
```

### Azure Computer Vision with Network ACLs
```yaml
components:
  terraform:
    azure-computer-vision:
      vars:
        name: "vision"
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

Azure Computer Vision names follow the pattern: `{environment}{stage}{name}{namespace}`

### Examples
| Environment | Stage | Name | Namespace | Result |
|-------------|-------|------|-----------|--------|
| eus | dev | vision | lazylabs | eusdevvisionlazylabs |
| eus | prod | cv | lazylabs | eusprodcvlazylabs |
| wus | dev | image | lazylabs | wusdevimagelazylabs |

## Integration with Other Components

Azure Computer Vision can be referenced by other components using Terraform outputs:

```yaml
# Application using Computer Vision endpoint
azure-function-app:
  vars:
    app_settings:
      VISION_ENDPOINT: !terraform.output azure-computer-vision.cognitive_account_endpoint
      VISION_API_KEY: !terraform.output azure-computer-vision.primary_access_key
```

## Computer Vision Capabilities

### Image Analysis
- **Tags**: Automatic image tagging
- **Objects**: Object detection and localization
- **Categories**: Image categorization
- **Brands**: Brand logo detection
- **Faces**: Face detection (age, gender, emotion)
- **Adult Content**: Detect adult, racy, gory content
- **Color**: Dominant colors and accent colors
- **Image Type**: Detect clipart, line drawings

### Optical Character Recognition (OCR)
- **Read API**: Extract printed and handwritten text
- **Multi-page support**: Process multi-page documents
- **High accuracy**: Advanced OCR models
- **164 languages**: Extensive language support
- **Layout detection**: Preserve document structure

### Spatial Analysis
- **People counting**: Count people in designated zones
- **Social distancing**: Monitor physical distancing
- **Mask detection**: Detect face mask compliance
- **Zone crossing**: Track zone entry/exit events

### Custom Vision
- **Image classification**: Custom image classifiers
- **Object detection**: Custom object detectors
- **Model training**: Train with your own images
- **Model export**: Deploy to edge devices

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
    ComplianceScope: "gdpr,ccpa"
    Owner: "vision-platform-team"
```

### Privacy and Compliance
- Images may contain PII and faces
- Comply with privacy regulations (GDPR, CCPA, etc.)
- Implement data retention and deletion policies
- Consider regional data residency requirements
- Document consent for face detection/recognition

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
| location | The Azure Region where the Azure Computer Vision should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| sku_name | The SKU name for the Azure Computer Vision | `string` | `S1` | no |
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
| cognitive_account_id | The ID of the Azure Computer Vision |
| cognitive_account_name | The name of the Azure Computer Vision |
| cognitive_account_endpoint | The endpoint URL for API access |
| cognitive_account_location | The location of the service |
| primary_access_key | Primary access key (sensitive) |
| secondary_access_key | Secondary access key (sensitive) |
| identity_principal_id | Principal ID of managed identity |
| tags | Tags applied to the service |
| context | Exported context for use by other modules |

## Troubleshooting

### Common Issues

1. **Image Format and Size**
   - Supported formats: JPEG, PNG, GIF, BMP
   - Maximum file size: 4MB for most operations
   - Minimum dimensions: 50x50 pixels
   - Maximum dimensions: 10,000x10,000 pixels

2. **OCR Accuracy**
   - Image quality affects OCR accuracy
   - Ensure sufficient resolution (300 DPI recommended)
   - Avoid skewed or rotated images
   - Good lighting and contrast improve results

3. **Rate Limiting**
   - API has transaction per second limits
   - S1: 10 TPS, can be increased
   - F0: 20 calls per minute
   - Implement exponential backoff retry logic

4. **Face Detection vs Recognition**
   - Computer Vision provides face detection only
   - For face recognition, use Azure Face API
   - Be aware of regulatory restrictions on face recognition

### Validation
```bash
# Check Azure Computer Vision
az cognitiveservices account show \
  --name eusdevvisionlazylabs \
  --resource-group eusdevserviceslazylabs

# Test Computer Vision endpoint (analyze image)
curl -X POST "https://eusdevvisionlazylabs.cognitiveservices.azure.com/vision/v3.2/analyze?visualFeatures=Tags,Objects" \
  -H "Ocp-Apim-Subscription-Key: {your-key}" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com/image.jpg"}'
```

## Best Practices

### Cost Optimization
- Use S1 tier for production workloads
- Use F0 (free) tier for development and testing
- Optimize image sizes before processing
- Cache results for repeated analyses
- Monitor transaction usage

### Security
- Always use managed identities when possible
- Implement network isolation with private endpoints
- Enable Azure Monitor for audit logging
- Implement access controls for image storage
- Document consent for face detection

### Performance
- Resize large images before processing
- Use batch processing when possible
- Implement caching for frequently analyzed images
- Deploy services close to your users
- Monitor latency and throughput metrics

### Accuracy
- Use high-quality images with good lighting
- Ensure sufficient image resolution
- Test with representative samples
- Validate results for your specific use case
- Consider custom models for specialized scenarios

### Privacy and Ethics
- Implement consent mechanisms for face detection
- Document data retention and deletion policies
- Comply with regional privacy regulations
- Implement fairness testing for diverse populations
- Regular privacy and ethics reviews

### Governance
- Tag resources consistently for cost tracking
- Document acceptable use policies
- Implement approval workflows for production deployments
- Regular security and compliance reviews
- Track API usage and performance metrics
