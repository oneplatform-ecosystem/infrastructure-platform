# Azure Data Factory Module

This module creates an Azure Data Factory with support for managed virtual networks, managed identities, GitHub/Azure DevOps integration, and customer-managed encryption.

## Features

- **Data Factory Creation**: Provision Azure Data Factory instances
- **Managed Virtual Network**: Support for managed virtual network integration
- **Managed Identity**: SystemAssigned, UserAssigned, or both identity types
- **Public Network Control**: Configure public network access
- **Git Integration**: GitHub or Azure DevOps (VSTS) repository integration
- **Customer Managed Keys**: Support for customer-managed encryption keys
- **Global Parameters**: Define global parameters for the Data Factory
- **Cloud Posse Label Integration**: Consistent naming and tagging

## Usage

### Basic Example

```hcl
module "datafactory" {
  source = "../modules/azure-datafactory"

  location            = "eastus"
  resource_group_name = "my-rg"

  # Naming
  namespace   = "myorg"
  environment = "dev"
  stage       = "dev"
  name        = "analytics"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

### Example with Managed Virtual Network

```hcl
module "datafactory" {
  source = "../modules/azure-datafactory"

  location            = "eastus"
  resource_group_name = "my-rg"

  # Enable managed virtual network
  managed_virtual_network_enabled = true
  public_network_enabled          = false

  # Naming
  namespace   = "myorg"
  environment = "prod"
  stage       = "prod"
  name        = "analytics"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Example with GitHub Integration

```hcl
module "datafactory" {
  source = "../modules/azure-datafactory"

  location            = "eastus"
  resource_group_name = "my-rg"

  # GitHub configuration
  github_configuration = {
    account_name    = "my-org"
    branch_name     = "main"
    repository_name = "data-pipelines"
    root_folder     = "/datafactory"
    git_url         = "https://github.com"
    publishing_enabled = true
  }

  # Naming
  namespace   = "myorg"
  environment = "dev"
  stage       = "dev"
  name        = "analytics"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

### Example with Azure DevOps Integration

```hcl
module "datafactory" {
  source = "../modules/azure-datafactory"

  location            = "eastus"
  resource_group_name = "my-rg"

  # Azure DevOps configuration
  vsts_configuration = {
    account_name    = "my-org"
    branch_name     = "main"
    project_name    = "DataPlatform"
    repository_name = "data-pipelines"
    root_folder     = "/datafactory"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    publishing_enabled = true
  }

  # Naming
  namespace   = "myorg"
  environment = "dev"
  stage       = "dev"
  name        = "analytics"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

### Example with Global Parameters

```hcl
module "datafactory" {
  source = "../modules/azure-datafactory"

  location            = "eastus"
  resource_group_name = "my-rg"

  # Global parameters
  global_parameters = [
    {
      name  = "environment"
      type  = "String"
      value = "production"
    },
    {
      name  = "apiVersion"
      type  = "String"
      value = "v1"
    }
  ]

  # Naming
  namespace   = "myorg"
  environment = "prod"
  stage       = "prod"
  name        = "analytics"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Example with User Assigned Managed Identity

```hcl
module "datafactory" {
  source = "../modules/azure-datafactory"

  location            = "eastus"
  resource_group_name = "my-rg"

  # Managed Identity
  identity_type = "UserAssigned"
  identity_ids  = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-identity"]

  # Naming
  namespace   = "myorg"
  environment = "prod"
  stage       = "prod"
  name        = "analytics"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| location | The Azure Region where the Data Factory should exist | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group in which the Data Factory should exist | `string` | n/a | yes |
| datafactory_name | The name of the Data Factory. If not provided, the name will be generated using the label module | `string` | `null` | no |
| public_network_enabled | Is the Data Factory visible to the public network? | `bool` | `true` | no |
| managed_virtual_network_enabled | Is Managed Virtual Network enabled for the Data Factory? | `bool` | `false` | no |
| customer_managed_key_id | The ID of the Key Vault Key to use for customer managed key encryption | `string` | `null` | no |
| identity_type | The type of Managed Identity (SystemAssigned, UserAssigned, or both) | `string` | `"SystemAssigned"` | no |
| identity_ids | List of User Assigned Managed Identity IDs | `list(string)` | `null` | no |
| github_configuration | GitHub configuration for the Data Factory | `object` | `null` | no |
| vsts_configuration | Azure DevOps (VSTS) configuration for the Data Factory | `object` | `null` | no |
| global_parameters | List of global parameters for the Data Factory | `list(object)` | `null` | no |
| namespace | ID element - organization name abbreviation | `string` | `null` | no |
| tenant | ID element - customer identifier | `string` | `null` | no |
| environment | ID element - environment/region | `string` | `null` | no |
| stage | ID element - stage/role | `string` | `null` | no |
| name | ID element - component name | `string` | `null` | no |
| attributes | ID element - additional attributes | `list(string)` | `[]` | no |
| delimiter | Delimiter between ID elements | `string` | `"-"` | no |
| tags | Additional tags | `map(string)` | `{}` | no |
| regex_replace_chars | Regex to remove characters from ID | `string` | `null` | no |
| label_order | Order of labels in ID | `list(string)` | `null` | no |
| label_key_case | Letter case of tag keys | `string` | `null` | no |
| label_value_case | Letter case of tag values | `string` | `null` | no |
| id_length_limit | Maximum length of ID | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Data Factory |
| name | The name of the Data Factory |
| location | The Azure Region where the Data Factory exists |
| resource_group_name | The name of the Resource Group |
| datafactory_id | The ID of the Data Factory (alias) |
| identity | The Managed Identity block |
| principal_id | The Principal ID of the Managed Identity |
| tenant_id | The Tenant ID of the Managed Identity |
| tags | The tags assigned to the Data Factory |

## Requirements

- Terraform >= 1.9.0
- Azure Provider = 4.20.0

## Notes

- Data Factory names must be globally unique across Azure
- When using `managed_virtual_network_enabled`, consider setting `public_network_enabled` to `false` for enhanced security
- GitHub and Azure DevOps configurations are mutually exclusive - use only one
- When using `UserAssigned` identity type, you must provide `identity_ids`
- Global parameters are useful for parameterizing Data Factory pipelines across environments
