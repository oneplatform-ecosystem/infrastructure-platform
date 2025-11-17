# Azure PostgreSQL Flexible Server Component

This Terraform component provisions an Azure PostgreSQL Flexible Server with databases, comprehensive security, high availability, backup, and networking features.

## Features

- Azure PostgreSQL Flexible Server (versions 11-16)
- Multiple database support
- Azure AD authentication support
- Managed identity support
- High availability with zone redundancy
- Customer-managed encryption keys (CMK)
- Firewall rules configuration
- Server configuration parameters
- Automated backups with geo-redundancy
- Maintenance window configuration
- Connection string outputs for various clients (standard, JDBC, Python, .NET)

## Usage

### Basic Example

```yaml
components:
  terraform:
    azure-postgres-database:
      metadata:
        component: azure-postgres
      vars:
        enabled: true
        name: "myapp"
        resource_group_name: "my-resource-group"
        location: "eastus"
        administrator_login: "pgadmin"
        administrator_password: "P@ssw0rd123!"
        sku_name: "B_Standard_B1ms"
        storage_mb: 32768
        postgres_version: "16"

        databases:
          appdb:
            collation: "en_US.utf8"
            charset: "UTF8"
```

### Advanced Example with High Availability and Security

```yaml
components:
  terraform:
    azure-postgres-production:
      metadata:
        component: azure-postgres
      vars:
        enabled: true
        name: "production-db"
        resource_group_name: "prod-resources"
        location: "eastus"

        # Server Configuration
        postgres_version: "16"
        administrator_login: "pgadmin"
        administrator_password: "ComplexP@ssw0rd!"
        sku_name: "GP_Standard_D4s_v3"
        storage_mb: 131072
        zone: "1"

        # High Availability
        high_availability_enabled: true
        high_availability_mode: "ZoneRedundant"
        standby_availability_zone: "2"

        # Backup Configuration
        backup_retention_days: 35
        geo_redundant_backup_enabled: true
        auto_grow_enabled: true

        # Network Security
        public_network_access_enabled: false

        # Azure AD Authentication
        authentication_config:
          active_directory_auth_enabled: true
          password_auth_enabled: true
          tenant_id: "12345678-1234-1234-1234-123456789012"

        azuread_administrator:
          tenant_id: "12345678-1234-1234-1234-123456789012"
          object_id: "87654321-4321-4321-4321-210987654321"
          principal_name: "postgres-admins"
          principal_type: "Group"

        # Managed Identity
        identity_type: "SystemAssigned"

        # Maintenance Window
        maintenance_window:
          day_of_week: 0    # Sunday
          start_hour: 2
          start_minute: 0

        # Multiple Databases
        databases:
          production:
            collation: "en_US.utf8"
            charset: "UTF8"
          analytics:
            collation: "en_US.utf8"
            charset: "UTF8"

        # Server Configurations
        server_configurations:
          max_connections: "200"
          shared_buffers: "256MB"
          effective_cache_size: "1GB"
          work_mem: "4MB"
          maintenance_work_mem: "64MB"

        # Firewall Rules
        firewall_rules:
          allow-azure-services:
            start_ip_address: "0.0.0.0"
            end_ip_address: "0.0.0.0"
          office-network:
            start_ip_address: "203.0.113.0"
            end_ip_address: "203.0.113.255"
```

### Example with Customer-Managed Keys

```yaml
components:
  terraform:
    azure-postgres-cmk:
      metadata:
        component: azure-postgres
      vars:
        enabled: true
        name: "secure-db"
        resource_group_name: "security-resources"
        location: "eastus"

        administrator_login: "pgadmin"
        administrator_password: "SecureP@ssw0rd!"

        # Customer Managed Key
        identity_type: "UserAssigned"
        identity_ids:
          - "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xxx"
        customer_managed_key_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.KeyVault/vaults/xxx/keys/xxx"
        primary_user_assigned_identity_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xxx"

        databases:
          encrypted_db:
            collation: "en_US.utf8"
            charset: "UTF8"
```

### Development Environment Example

```yaml
components:
  terraform:
    azure-postgres-dev:
      metadata:
        component: azure-postgres
      vars:
        enabled: true
        name: "dev-db"
        resource_group_name: "dev-resources"
        location: "eastus"

        administrator_login: "devadmin"
        administrator_password: "DevP@ssw0rd!"

        # Cost-effective settings for development
        sku_name: "B_Standard_B1ms"
        storage_mb: 32768
        postgres_version: "16"
        backup_retention_days: 7
        geo_redundant_backup_enabled: false
        high_availability_enabled: false

        # Allow broader access for development
        public_network_access_enabled: true

        firewall_rules:
          allow-all-azure:
            start_ip_address: "0.0.0.0"
            end_ip_address: "0.0.0.0"
          developer-home:
            start_ip_address: "198.51.100.1"
            end_ip_address: "198.51.100.1"

        databases:
          devdb:
            collation: "en_US.utf8"
            charset: "UTF8"
```

## Atmos Stack Configuration

Import this component in your Atmos stack:

```yaml
import:
  - catalog/azure-postgres/defaults

components:
  terraform:
    azure-postgres-database:
      metadata:
        component: azure-postgres
      vars:
        resource_group_name: "my-resource-group"
        location: "eastus"
        administrator_login: "pgadmin"
        administrator_password: "P@ssw0rd123!"
```

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

| Type | Name |
|------|------|
| azurerm_postgresql_flexible_server | this |
| azurerm_postgresql_flexible_server_database | this |
| azurerm_postgresql_flexible_server_configuration | this |
| azurerm_postgresql_flexible_server_firewall_rule | this |
| azurerm_postgresql_flexible_server_active_directory_administrator | this |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| resource_group_name | The name of the resource group in which to create the PostgreSQL Flexible Server | `string` | n/a | yes |
| location | The Azure region where the PostgreSQL Flexible Server should exist | `string` | n/a | yes |
| server_name | Custom name for the PostgreSQL Flexible Server. If not provided, will use the label module generated ID | `string` | `null` | no |
| postgres_version | The version of PostgreSQL to use. Valid values are 11, 12, 13, 14, 15, 16 | `string` | `"16"` | no |
| administrator_login | The administrator login name for the PostgreSQL Flexible Server | `string` | n/a | yes |
| administrator_password | The administrator login password for the PostgreSQL Flexible Server | `string` | n/a | yes |
| sku_name | The SKU name for the PostgreSQL Flexible Server | `string` | `"B_Standard_B1ms"` | no |
| storage_mb | The max storage allowed for the PostgreSQL Flexible Server in MB | `number` | `32768` | no |
| backup_retention_days | The backup retention days for the PostgreSQL Flexible Server (7-35) | `number` | `7` | no |
| geo_redundant_backup_enabled | Should geo redundant backup be enabled? | `bool` | `false` | no |
| auto_grow_enabled | Should storage auto grow be enabled? | `bool` | `true` | no |
| public_network_access_enabled | Should public network access be enabled for this server? | `bool` | `false` | no |
| zone | The availability zone in which the PostgreSQL Flexible Server should be located | `string` | `null` | no |
| authentication_config | Authentication configuration for the PostgreSQL Flexible Server | `object` | `null` | no |
| customer_managed_key_id | The ID of the Key Vault Key to use for customer managed key encryption | `string` | `null` | no |
| primary_user_assigned_identity_id | The ID of the primary User Assigned Identity for customer managed key encryption | `string` | `null` | no |
| high_availability_enabled | Should high availability be enabled? | `bool` | `false` | no |
| high_availability_mode | The high availability mode. Valid values are ZoneRedundant and SameZone | `string` | `"ZoneRedundant"` | no |
| standby_availability_zone | The availability zone for the standby server when high availability is enabled | `string` | `null` | no |
| identity_type | The type of Managed Service Identity. Possible values are SystemAssigned, UserAssigned | `string` | `null` | no |
| identity_ids | A list of User Assigned Managed Identity IDs to be assigned to this PostgreSQL Flexible Server | `list(string)` | `null` | no |
| maintenance_window | Maintenance window configuration | `object` | `null` | no |
| server_configurations | Map of PostgreSQL server configuration parameters | `map(string)` | `{}` | no |
| databases | Map of databases to create | `map(object)` | `{}` | no |
| firewall_rules | Map of firewall rules to create | `map(object)` | `{}` | no |
| azuread_administrator | Azure AD administrator configuration | `object` | `null` | no |

### Label Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | ID element. Usually an abbreviation of your organization name | `string` | `null` | no |
| tenant | ID element. Usually used to indicate the tenant | `string` | `null` | no |
| environment | ID element. Usually used for region (e.g. 'eus', 'weu') | `string` | `null` | no |
| stage | ID element. Usually used to indicate role (e.g. 'prod', 'dev') | `string` | `null` | no |
| name | ID element. Usually the component or solution name | `string` | `null` | no |
| attributes | ID element. Additional attributes to add to ID | `list(string)` | `[]` | no |
| delimiter | Delimiter to be used between ID elements | `string` | `"-"` | no |
| tags | Additional tags | `map(string)` | `{}` | no |
| regex_replace_chars | Regex string to remove characters from ID elements | `string` | `null` | no |
| label_order | The order in which the labels appear in the id | `list(string)` | `null` | no |
| label_key_case | Controls the letter case of tag keys | `string` | `null` | no |
| label_value_case | Controls the letter case of tag values | `string` | `null` | no |
| id_length_limit | Limit id to this many characters | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| server_id | The ID of the PostgreSQL Flexible Server |
| server_name | The name of the PostgreSQL Flexible Server |
| server_fqdn | The fully qualified domain name of the PostgreSQL Flexible Server |
| server_public_network_access_enabled | Is public network access enabled |
| server_identity | The identity block of the PostgreSQL Flexible Server |
| database_ids | Map of database IDs |
| database_names | Map of database names |
| connection_string | The connection string for the PostgreSQL Flexible Server (sensitive) |
| jdbc_connection_string | JDBC connection string (sensitive) |
| python_connection_string | Python (psycopg2) connection string (sensitive) |
| dotnet_connection_string | .NET (Npgsql) connection string (sensitive) |
| firewall_rules | Map of created firewall rules |
| server_configurations | Map of applied server configurations |
| azuread_administrator_id | The ID of the Azure AD administrator |
| tags | The tags applied to the resources |
| context | Exported context for use by other modules |
| id | The generated ID from the label module |

## Notes

### PostgreSQL Versions

Azure PostgreSQL Flexible Server supports the following major versions:
- PostgreSQL 11 (end of support: November 9, 2023)
- PostgreSQL 12
- PostgreSQL 13
- PostgreSQL 14
- PostgreSQL 15
- PostgreSQL 16 (recommended)

### SKU Naming Convention

SKU names follow the pattern: `{tier}_{compute-family}_{cores}`

**Tiers:**
- `B` - Burstable (dev/test workloads)
- `GP` - General Purpose (most workloads)
- `MO` - Memory Optimized (memory-intensive workloads)

**Examples:**
- `B_Standard_B1ms` - Burstable, 1 vCore, 2 GiB RAM
- `GP_Standard_D2s_v3` - General Purpose, 2 vCores, 8 GiB RAM
- `MO_Standard_E4s_v3` - Memory Optimized, 4 vCores, 32 GiB RAM

### Storage

Storage is provisioned in MB and must be one of the following values:
- 32768 (32 GB) - minimum
- 65536 (64 GB)
- 131072 (128 GB)
- 262144 (256 GB)
- 524288 (512 GB)
- 1048576 (1 TB)
- 2097152 (2 TB)
- 4194304 (4 TB)
- 8388608 (8 TB)
- 16777216 (16 TB)
- 33554432 (32 TB) - maximum

### High Availability

High availability can be enabled with two modes:
- **ZoneRedundant**: Standby server in a different availability zone (recommended)
- **SameZone**: Standby server in the same availability zone

Note: High availability requires GP or MO tier SKUs.

### Backup and Restore

- Automated backups are taken daily
- Backup retention: 7-35 days
- Geo-redundant backups available for disaster recovery
- Point-in-time restore supported within retention period

### Networking

By default, `public_network_access_enabled` is set to `false` for security. Use firewall rules or VNet integration for controlled access:
- Set `start_ip_address` and `end_ip_address` to `0.0.0.0` to allow all Azure services
- Specify specific IP ranges for external access
- Use VNet integration for private connectivity

### Maintenance Windows

Configure maintenance windows to control when Azure performs updates:
- `day_of_week`: 0-6 (Sunday-Saturday)
- `start_hour`: 0-23
- `start_minute`: 0 or 30

### Connection Strings

Connection strings are marked as sensitive and include placeholders for the password. To connect:

**Standard PostgreSQL:**
```bash
psql "postgresql://pgadmin:PASSWORD@server.postgres.database.azure.com:5432/postgres?sslmode=require"
```

**Python (psycopg2):**
```python
import psycopg2
conn = psycopg2.connect(
    host="server.postgres.database.azure.com",
    port=5432,
    dbname="postgres",
    user="pgadmin",
    password="PASSWORD",
    sslmode="require"
)
```

**Java (JDBC):**
```java
String url = "jdbc:postgresql://server.postgres.database.azure.com:5432/postgres?sslmode=require";
Connection conn = DriverManager.getConnection(url, "pgadmin", "PASSWORD");
```

### Lifecycle Management

The component uses `ignore_changes` for:
- `zone` - Azure may move resources during maintenance
- `high_availability[0].standby_availability_zone` - Azure manages standby placement

This prevents Terraform from attempting to modify these Azure-managed attributes.

## References

- [Azure PostgreSQL Flexible Server Documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [Terraform AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
