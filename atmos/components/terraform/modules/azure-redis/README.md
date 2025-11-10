# Azure Cache for Redis Terraform Module

This Terraform module creates and manages an Azure Cache for Redis instance with configurable SKU, networking, and security settings.

## Features

- Multiple SKU tiers: Basic, Standard, and Premium
- Configurable Redis version (4 or 6)
- TLS/SSL enforcement with configurable minimum version
- Private endpoint support for secure network access
- Redis configuration options (maxmemory policies, persistence, etc.)
- Managed Identity support
- Availability Zones support (Premium SKU)
- Clustering support (Premium SKU)
- VNet integration (Premium SKU)
- RDB and AOF persistence options
- Patch schedule management
- CloudPosse label module integration for consistent resource naming and tagging

## Usage

### Basic Configuration

```hcl
module "redis_cache" {
  source = "./modules/azure-redis"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # SKU Configuration
  sku_name = "Standard"
  family   = "C"
  capacity = 1

  # Redis Configuration
  redis_version       = "6"
  minimum_tls_version = "1.2"
  enable_non_ssl_port = false

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "dev"
  name        = "cache"
}
```

### Premium Configuration with VNet Integration

```hcl
module "redis_cache_premium" {
  source = "./modules/azure-redis"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # Premium SKU Configuration
  sku_name = "Premium"
  family   = "P"
  capacity = 1

  # VNet Integration
  subnet_id = azurerm_subnet.redis.id

  # High Availability
  zones                = ["1", "2", "3"]
  replicas_per_primary = 2
  shard_count          = 2

  # Redis Configuration
  redis_configuration = {
    maxmemory_policy                = "allkeys-lru"
    maxmemory_reserved              = 2
    maxmemory_delta                 = 2
    maxfragmentationmemory_reserved = 2
    rdb_backup_enabled              = true
    rdb_backup_frequency            = 60
    rdb_backup_max_snapshot_count   = 1
    rdb_storage_connection_string   = azurerm_storage_account.backup.primary_connection_string
  }

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "prod"
  name        = "cache"
}
```

### With Private Endpoint

```hcl
module "redis_cache_private" {
  source = "./modules/azure-redis"

  enabled             = true
  location            = "eastus"
  resource_group_name = "my-resource-group"

  # SKU Configuration
  sku_name = "Premium"
  family   = "P"
  capacity = 1

  # Network Security
  public_network_access_enabled = false

  # Private Endpoint
  create_private_endpoint      = true
  private_endpoint_subnet_id   = azurerm_subnet.private_endpoints.id

  private_endpoint_dns_zone_group = {
    name                 = "redis-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis.id]
  }

  # Label Configuration
  namespace   = "lazylabs"
  environment = "eus"
  stage       = "prod"
  name        = "cache"
}
```

## SKU Tiers

### Basic
- Single node, no SLA
- Ideal for development/testing
- Family: C (0-6)

### Standard
- Two nodes with replication
- 99.9% SLA
- Family: C (0-6)

### Premium
- All Standard features plus:
  - VNet integration
  - Clustering
  - Data persistence (RDB/AOF)
  - Availability Zones
  - Geo-replication
- Family: P (1-5)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enabled | Set to false to prevent the module from creating any resources | bool | true | no |
| location | The Azure Region where the Redis Cache should be created | string | - | yes |
| resource_group_name | The name of the resource group in which to create the Redis Cache | string | - | yes |
| sku_name | The SKU of Redis to use (Basic, Standard, Premium) | string | "Standard" | no |
| family | The SKU family/pricing group (C for Basic/Standard, P for Premium) | string | "C" | no |
| capacity | The size of the Redis cache to deploy | number | 1 | no |
| redis_version | Redis version (4 or 6) | string | "6" | no |
| minimum_tls_version | The minimum TLS version (1.0, 1.1, 1.2) | string | "1.2" | no |
| enable_non_ssl_port | Enable the non-SSL port (6379) | bool | false | no |
| public_network_access_enabled | Whether public network access is allowed | bool | false | no |

See [variables.tf](./variables.tf) for a complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| redis_cache_id | The ID of the Redis Cache |
| redis_cache_name | The name of the Redis Cache |
| redis_cache_hostname | The hostname of the Redis Cache |
| redis_cache_ssl_port | The SSL port of the Redis Cache |
| redis_cache_primary_connection_string | The primary connection string (sensitive) |
| redis_cache_primary_access_key | The primary access key (sensitive) |

See [outputs.tf](./outputs.tf) for a complete list of outputs.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | = 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | = 4.23.0 |

## Best Practices

1. **Security**
   - Always use TLS 1.2 as minimum version
   - Disable non-SSL port (6379) in production
   - Use private endpoints for production workloads
   - Enable authentication (enabled by default)

2. **High Availability**
   - Use Standard or Premium SKU for production
   - Enable Availability Zones with Premium SKU
   - Configure replicas for read scaling

3. **Data Persistence**
   - Use RDB backups for point-in-time recovery
   - Consider AOF persistence for Premium workloads requiring durability
   - Store backups in a separate storage account

4. **Monitoring**
   - Configure Azure Monitor alerts for CPU, memory, and connection metrics
   - Set up diagnostic settings for logging
   - Monitor cache hit/miss ratio

## References

- [Azure Cache for Redis documentation](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/)
- [Terraform azurerm_redis_cache resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
