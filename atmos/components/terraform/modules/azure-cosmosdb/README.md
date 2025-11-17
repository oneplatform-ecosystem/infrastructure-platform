# Azure Cosmos DB Terraform Module

This Terraform module creates and manages an Azure Cosmos DB account with support for multiple APIs, geo-replication, backup policies, and advanced security configurations.

## Features

- Multiple API support: SQL (Core), MongoDB, Cassandra, Gremlin, and Table
- Multi-region deployments with automatic failover
- Multiple write locations support
- Configurable consistency levels (Strong, Bounded Staleness, Session, Consistent Prefix, Eventual)
- Backup configuration (Periodic and Continuous)
- Point-in-time restore capabilities
- Network security with Virtual Network rules and IP filtering
- Private endpoint support
- Managed Identity support (System and User Assigned)
- Analytical storage with configurable schema types
- Free tier option for development and testing
- CORS configuration
- Serverless and provisioned capacity modes
- CloudPosse label module integration for consistent resource naming and tagging

## Usage

### Basic SQL API Configuration

```hcl
module "cosmosdb_basic" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Cosmos DB Configuration
  kind       = "GlobalDocumentDB"
  offer_type = "Standard"

  # Consistency Policy
  consistency_policy = {
    consistency_level = "Session"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "dev"
  name        = "cosmosdb"
}
```

### MongoDB API with Multi-Region Deployment

```hcl
module "cosmosdb_mongodb" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # MongoDB Configuration
  kind                = "MongoDB"
  mongo_server_version = "4.2"

  # Enable MongoDB capability
  capabilities = ["EnableMongo"]

  # Multi-region setup
  geo_locations = [
    {
      location          = "eastus"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "westus2"
      failover_priority = 1
      zone_redundant    = true
    }
  ]

  # Enable automatic failover
  enable_automatic_failover = true

  # Strong consistency for critical data
  consistency_policy = {
    consistency_level = "Strong"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "prod"
  stage       = "prod"
  name        = "mongodb"
}
```

### Production Configuration with Enhanced Security

```hcl
module "cosmosdb_secure" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Cosmos DB Configuration
  kind = "GlobalDocumentDB"

  # Network Security
  public_network_access_enabled = false

  # Virtual Network Rules
  virtual_network_rules = [
    {
      id                                   = azurerm_subnet.cosmos.id
      ignore_missing_vnet_service_endpoint = false
    }
  ]

  # IP Filtering
  ip_range_filter = ["203.0.113.0/24", "198.51.100.0/24"]

  # Azure Services Bypass
  network_acl_bypass_for_azure_services = true

  # Managed Identity
  identity_type = "SystemAssigned"

  # Disable local authentication (use AAD only)
  local_authentication_disabled = true

  # Minimal TLS Version
  minimal_tls_version = "Tls12"

  # Consistency Policy
  consistency_policy = {
    consistency_level = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  # Continuous Backup
  backup = {
    type               = "Continuous"
    storage_redundancy = "Zone"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "prod"
  name        = "secure"
}
```

### Serverless Configuration with Free Tier

```hcl
module "cosmosdb_serverless" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Serverless Configuration
  kind         = "GlobalDocumentDB"
  capabilities = ["EnableServerless"]

  # Enable Free Tier
  enable_free_tier = true

  # Consistency Policy
  consistency_policy = {
    consistency_level = "Session"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "dev"
  name        = "serverless"
}
```

### Analytical Storage Configuration

```hcl
module "cosmosdb_analytical" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Enable Analytical Storage
  analytical_storage_enabled = true
  analytical_storage_type    = "FullFidelity"

  # Capabilities
  capabilities = ["EnableAnalyticalStorage"]

  # Consistency Policy
  consistency_policy = {
    consistency_level = "Session"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "analytics"
  name        = "cosmosdb"
}
```

### Cassandra API Configuration

```hcl
module "cosmosdb_cassandra" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Cassandra Configuration
  kind = "GlobalDocumentDB"
  capabilities = ["EnableCassandra"]

  # Multi-write locations
  enable_multiple_write_locations = true
  enable_automatic_failover       = true

  # Geo-replication
  geo_locations = [
    {
      location          = "eastus"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "westus2"
      failover_priority = 1
      zone_redundant    = true
    },
    {
      location          = "northeurope"
      failover_priority = 2
      zone_redundant    = false
    }
  ]

  # Consistency Policy
  consistency_policy = {
    consistency_level = "Session"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "global"
  stage       = "prod"
  name        = "cassandra"
}
```

### Point-in-Time Restore Configuration

```hcl
module "cosmosdb_restored" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Restore Configuration
  create_mode = "Restore"

  restore = {
    source_cosmosdb_account_id = azurerm_cosmosdb_account.source.id
    restore_timestamp_in_utc   = "2025-01-01T00:00:00Z"

    database = [
      {
        name             = "mydb1"
        collection_names = ["collection1", "collection2"]
      }
    ]
  }

  # Consistency Policy
  consistency_policy = {
    consistency_level = "Session"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "restore"
  name        = "cosmosdb"
}
```

### CORS Configuration for Web Applications

```hcl
module "cosmosdb_cors" {
  source = "./modules/azure-cosmosdb"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # CORS Configuration
  cors_rules = [
    {
      allowed_headers    = ["x-ms-*"]
      allowed_methods    = ["GET", "POST", "PUT", "DELETE"]
      allowed_origins    = ["https://example.com", "https://app.example.com"]
      exposed_headers    = ["x-ms-*"]
      max_age_in_seconds = 3600
    }
  ]

  # Consistency Policy
  consistency_policy = {
    consistency_level = "Session"
  }

  # Label Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "web"
  name        = "cosmosdb"
}
```

### Atmos Stack Configuration

```yaml
components:
  terraform:
    azure-cosmosdb-prod:
      metadata:
        component: azure-cosmosdb
      settings:
        depends_on:
          - component: "azure-resource-group"
      vars:
        enabled: true
        location: "eastus"
        resource_group_name: !terraform.output azure-resource-group.resource_group_name

        # Cosmos DB Configuration
        kind: "GlobalDocumentDB"
        offer_type: "Standard"

        # Multi-region deployment
        geo_locations:
          - location: "eastus"
            failover_priority: 0
            zone_redundant: true
          - location: "westus2"
            failover_priority: 1
            zone_redundant: true

        # Automatic failover
        enable_automatic_failover: true

        # Consistency
        consistency_policy:
          consistency_level: "Session"

        # Backup
        backup:
          type: "Continuous"
          storage_redundancy: "Zone"

        # Network Security
        public_network_access_enabled: false
        network_acl_bypass_for_azure_services: true

        # Identity
        identity_type: "SystemAssigned"

        # Security
        minimal_tls_version: "Tls12"
        local_authentication_disabled: false

        # Labels
        namespace: "myorg"
        environment: "eus"
        stage: "prod"
        name: "cosmosdb"

        tags:
          CostCenter: "Engineering"
          Owner: "Platform Team"
```

## Configuration

### API Types

The module supports multiple Cosmos DB APIs through the `kind` and `capabilities` variables:

- **SQL (Core) API**: `kind = "GlobalDocumentDB"` (default)
- **MongoDB API**: `kind = "MongoDB"` + `capabilities = ["EnableMongo"]`
- **Cassandra API**: `kind = "GlobalDocumentDB"` + `capabilities = ["EnableCassandra"]`
- **Gremlin (Graph) API**: `kind = "GlobalDocumentDB"` + `capabilities = ["EnableGremlin"]`
- **Table API**: `kind = "GlobalDocumentDB"` + `capabilities = ["EnableTable"]`

### Consistency Levels

Cosmos DB offers five consistency levels (ordered from strongest to weakest):

1. **Strong**: Linearizability guarantee
2. **Bounded Staleness**: Consistent Prefix with configurable lag
3. **Session**: Consistent within a session (default)
4. **Consistent Prefix**: Updates returned in order
5. **Eventual**: No ordering guarantee

### Backup Types

- **Periodic**: Traditional backup with configurable interval and retention
- **Continuous**: Point-in-time restore capability (7-30 days retention)

### Capacity Modes

- **Provisioned**: Traditional provisioned throughput (RU/s)
- **Serverless**: Pay-per-request model (add `capabilities = ["EnableServerless"]`)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | = 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | = 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| label | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| azurerm_cosmosdb_account.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| location | The Azure Region where the Cosmos DB Account should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Cosmos DB Account | `string` | n/a | yes |
| cosmosdb_account_name | The name of the Cosmos DB Account | `string` | `null` | no |
| offer_type | The Offer Type to use for this Cosmos DB Account | `string` | `"Standard"` | no |
| kind | The Kind of Cosmos DB to create | `string` | `"GlobalDocumentDB"` | no |
| consistency_policy | The consistency policy for the Cosmos DB account | `object` | `{consistency_level = "Session"}` | no |
| geo_locations | List of geo-locations for the Cosmos DB account | `list(object)` | `[]` | no |
| capabilities | List of Cosmos DB capabilities to enable | `list(string)` | `[]` | no |
| enable_automatic_failover | Enable automatic failover for this Cosmos DB account | `bool` | `false` | no |
| enable_multiple_write_locations | Enable multiple write locations | `bool` | `false` | no |
| enable_free_tier | Enable the Free Tier pricing option | `bool` | `false` | no |
| analytical_storage_enabled | Enable Analytical Storage | `bool` | `false` | no |
| public_network_access_enabled | Whether public network access is allowed | `bool` | `true` | no |
| backup | Backup configuration for the Cosmos DB account | `object` | `{type = "Periodic"}` | no |
| identity_type | The type of Managed Identity | `string` | `null` | no |
| minimal_tls_version | Specifies the minimal TLS version | `string` | `"Tls12"` | no |

See [variables.tf](./variables.tf) for a complete list of available variables.

## Outputs

| Name | Description |
|------|-------------|
| cosmosdb_account_id | The ID of the Cosmos DB Account |
| cosmosdb_account_name | The name of the Cosmos DB Account |
| endpoint | The endpoint used to connect to the Cosmos DB Account |
| read_endpoints | A list of read endpoints available for this Cosmos DB Account |
| write_endpoints | A list of write endpoints available for this Cosmos DB Account |
| primary_key | The Primary key for the Cosmos DB Account (sensitive) |
| secondary_key | The Secondary key for the Cosmos DB Account (sensitive) |
| primary_readonly_key | The Primary read-only key for the Cosmos DB Account (sensitive) |
| secondary_readonly_key | The Secondary read-only key for the Cosmos DB Account (sensitive) |
| primary_sql_connection_string | The primary SQL connection string (sensitive) |
| primary_mongodb_connection_string | The primary MongoDB connection string (sensitive) |
| identity_principal_id | The Principal ID of the Managed Service Identity |
| context | Exported context from the label module |
| tags | The tags applied to the Cosmos DB Account |

See [outputs.tf](./outputs.tf) for a complete list of available outputs.

## Notes

- When using Free Tier, you can only have one free tier account per subscription
- Serverless accounts cannot use multi-region writes
- Continuous backup requires at least 7 days retention
- Some features require specific SKUs or API types
- Geo-location order may be changed by Azure; use lifecycle ignore_changes to prevent drift
- When using MongoDB API, specify `mongo_server_version` to control the wire protocol version
- Analytical storage requires the `EnableAnalyticalStorage` capability
- Private endpoints require `public_network_access_enabled = false`

## License

Apache 2.0 Licensed. See LICENSE for full details.
