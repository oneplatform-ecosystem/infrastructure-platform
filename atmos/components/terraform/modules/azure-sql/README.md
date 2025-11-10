# Azure SQL Database Component

This Terraform component provisions an Azure SQL Server and Database with comprehensive security, backup, and networking features.

## Features

- Azure SQL Server (managed instance)
- Azure SQL Database with configurable SKU
- Azure AD authentication support
- Managed identity support
- Firewall rules configuration
- Virtual network rules integration
- Short-term and long-term backup retention policies
- Threat detection policy
- TLS version enforcement
- Connection string outputs for various clients

## Usage

### Basic Example

```yaml
components:
  terraform:
    azure-sql-database:
      metadata:
        component: azure-sql
      vars:
        enabled: true
        name: "myapp"
        resource_group_name: "my-resource-group"
        location: "westeurope"
        administrator_login: "sqladmin"
        administrator_login_password: "P@ssw0rd123!"
        sku_name: "GP_S_Gen5_2"
```

### Advanced Example with Security Features

```yaml
components:
  terraform:
    azure-sql-database:
      metadata:
        component: azure-sql
      vars:
        enabled: true
        name: "production-db"
        resource_group_name: "prod-resources"
        location: "westeurope"

        # Server Configuration
        sql_server_version: "12.0"
        administrator_login: "sqladmin"
        administrator_login_password: "ComplexP@ssw0rd!"
        minimum_tls_version: "1.2"
        public_network_access_enabled: false

        # Azure AD Authentication
        azuread_administrator:
          login_username: "sql-admins"
          object_id: "12345678-1234-1234-1234-123456789012"
          tenant_id: "87654321-4321-4321-4321-210987654321"
          azuread_authentication_only: false

        # Managed Identity
        identity_type: "SystemAssigned"

        # Database Configuration
        database_name: "production-database"
        sku_name: "GP_Gen5_4"
        max_size_gb: 250
        zone_redundant: true
        storage_account_type: "Geo"

        # Backup Policies
        short_term_retention_policy:
          retention_days: 14
          backup_interval_in_hours: 12

        long_term_retention_policy:
          weekly_retention: "P4W"
          monthly_retention: "P12M"
          yearly_retention: "P5Y"
          week_of_year: 1

        # Threat Detection
        threat_detection_policy:
          state: "Enabled"
          email_account_admins: "Enabled"
          email_addresses:
            - "security@example.com"
          retention_days: 30

        # Network Rules
        firewall_rules:
          allow-azure-services:
            start_ip_address: "0.0.0.0"
            end_ip_address: "0.0.0.0"
          office-network:
            start_ip_address: "203.0.113.0"
            end_ip_address: "203.0.113.255"

        virtual_network_rules:
          app-subnet:
            subnet_id: "/subscriptions/.../subnets/app-subnet"
```

### Serverless Database Example

```yaml
components:
  terraform:
    azure-sql-serverless:
      metadata:
        component: azure-sql
      vars:
        enabled: true
        name: "dev-db"
        resource_group_name: "dev-resources"
        location: "westeurope"
        administrator_login: "sqladmin"
        administrator_login_password: "DevP@ssw0rd!"

        # Serverless Configuration
        sku_name: "GP_S_Gen5_2"
        auto_pause_delay_in_minutes: 60
        min_capacity: 0.5
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | = 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | = 4.23.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/mssql_server) | resource |
| [azurerm_mssql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/mssql_database) | resource |
| [azurerm_mssql_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_virtual_network_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/mssql_virtual_network_rule) | resource |

## Inputs

### Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| administrator_login | The administrator login name | `string` | n/a | yes |
| administrator_login_password | The administrator password | `string` | n/a | yes |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enabled | Enable/disable the component | `bool` | `true` |
| sql_server_name | Custom SQL Server name | `string` | `null` |
| sql_server_version | SQL Server version | `string` | `"12.0"` |
| minimum_tls_version | Minimum TLS version | `string` | `"1.2"` |
| public_network_access_enabled | Enable public network access | `bool` | `false` |
| database_name | Custom database name | `string` | `null` |
| collation | Database collation | `string` | `"SQL_Latin1_General_CP1_CI_AS"` |
| sku_name | Database SKU | `string` | `"GP_S_Gen5_2"` |
| max_size_gb | Maximum database size in GB | `number` | `null` |
| zone_redundant | Enable zone redundancy | `bool` | `false` |
| storage_account_type | Backup storage type | `string` | `"Geo"` |

For a complete list of variables, see [variables.tf](./variables.tf).

## Outputs

| Name | Description |
|------|-------------|
| sql_server_id | The ID of the SQL Server |
| sql_server_name | The name of the SQL Server |
| sql_server_fqdn | The FQDN of the SQL Server |
| database_id | The ID of the SQL Database |
| database_name | The name of the SQL Database |
| connection_string | ADO.NET connection string |
| jdbc_connection_string | JDBC connection string |
| odbc_connection_string | ODBC connection string |
| firewall_rules | Map of created firewall rules |
| virtual_network_rules | Map of created VNet rules |
| tags | Applied resource tags |

## SKU Options

### General Purpose (GP)

- `GP_Gen5_2` - 2 vCores, Gen5
- `GP_Gen5_4` - 4 vCores, Gen5
- `GP_Gen5_8` - 8 vCores, Gen5
- `GP_Gen5_16` - 16 vCores, Gen5

### General Purpose Serverless (GP_S)

- `GP_S_Gen5_1` - 1 vCore, Serverless
- `GP_S_Gen5_2` - 2 vCores, Serverless
- `GP_S_Gen5_4` - 4 vCores, Serverless

### Business Critical (BC)

- `BC_Gen5_2` - 2 vCores, Gen5
- `BC_Gen5_4` - 4 vCores, Gen5
- `BC_Gen5_8` - 8 vCores, Gen5

### Hyperscale (HS)

- `HS_Gen5_2` - 2 vCores, Hyperscale
- `HS_Gen5_4` - 4 vCores, Hyperscale

### Basic/Standard/Premium

- `Basic` - Basic tier
- `S0`, `S1`, `S2`, `S3` - Standard tiers
- `P1`, `P2`, `P4`, `P6` - Premium tiers

## Security Best Practices

1. **Disable Public Access**: Set `public_network_access_enabled: false`
2. **Use Azure AD Authentication**: Configure `azuread_administrator`
3. **Enable TLS 1.2**: Set `minimum_tls_version: "1.2"`
4. **Configure Firewall Rules**: Restrict IP access
5. **Use VNet Integration**: Configure `virtual_network_rules`
6. **Enable Threat Detection**: Configure `threat_detection_policy`
7. **Store Credentials Securely**: Use Azure Key Vault for passwords
8. **Enable Long-term Retention**: Configure backup policies

## Integration with Other Components

### Using with Azure Key Vault

```yaml
components:
  terraform:
    azure-sql-database:
      metadata:
        component: azure-sql
      vars:
        administrator_login: "sqladmin"
        administrator_login_password: !terraform.output azure-keyvault ".secrets.sql_admin_password"
```

### Using with Virtual Network

```yaml
components:
  terraform:
    azure-sql-database:
      metadata:
        component: azure-sql
      vars:
        resource_group_name: !terraform.output azure-resource-group ".resource_group_name"
        virtual_network_rules:
          app-subnet:
            subnet_id: !terraform.output azure-subnet ".subnet_ids.app"
```

## Notes

- SQL Server names must be globally unique across Azure
- Database names must be unique within the SQL Server
- Passwords must meet Azure's complexity requirements
- Serverless databases automatically pause when inactive
- Zone redundancy is only available in certain regions
- Geo-redundant storage provides the highest durability

## References

- [Azure SQL Database Documentation](https://docs.microsoft.com/azure/azure-sql/database/)
- [Terraform azurerm_mssql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server)
- [Terraform azurerm_mssql_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)
