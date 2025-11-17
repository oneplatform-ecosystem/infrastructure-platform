# Azure PostgreSQL Flexible Server Database Component

This Terraform component provisions a database on an existing Azure PostgreSQL Flexible Server. This component is designed to be used independently to manage databases on a server that was created separately, allowing for better separation of concerns and database lifecycle management.

## Features

- Create databases on existing PostgreSQL Flexible Server
- Configurable collation and charset
- CloudPosse label module integration for consistent naming
- Conditional resource creation

## Usage

### Basic Example

```yaml
components:
  terraform:
    postgres-app-database:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "appdb"
        server_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.DBforPostgreSQL/flexibleServers/xxx"
        collation: "en_US.utf8"
        charset: "UTF8"
```

### Multiple Databases on Same Server

```yaml
components:
  terraform:
    postgres-production-db:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "production"
        server_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.DBforPostgreSQL/flexibleServers/myserver"
        collation: "en_US.utf8"
        charset: "UTF8"

    postgres-analytics-db:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "analytics"
        server_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.DBforPostgreSQL/flexibleServers/myserver"
        collation: "en_US.utf8"
        charset: "UTF8"
```

### With Custom Collation

```yaml
components:
  terraform:
    postgres-multilingual-db:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "multilingual"
        server_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.DBforPostgreSQL/flexibleServers/myserver"
        collation: "en_US.utf8"
        charset: "UTF8"
```

### Using with Remote State

```yaml
components:
  terraform:
    postgres-app-database:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "appdb"
      settings:
        depends_on:
          - azure-postgres-server
      env:
        TF_VAR_server_id: "{{ (atmos.Component 'azure-postgres-server' .stack).outputs.server_id }}"
```

## Atmos Stack Configuration

Import this component in your Atmos stack:

```yaml
import:
  - catalog/azure-postgres-database/defaults

components:
  terraform:
    postgres-app-database:
      metadata:
        component: azure-postgres-database
      vars:
        server_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.DBforPostgreSQL/flexibleServers/myserver"
        database_name: "appdb"
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
| azurerm_postgresql_flexible_server_database | this |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| server_id | The ID of the PostgreSQL Flexible Server on which to create the database | `string` | n/a | yes |
| database_name | Custom name for the database. If not provided, will use the label module generated ID | `string` | `null` | no |
| collation | Specifies the collation of the database | `string` | `"en_US.utf8"` | no |
| charset | Specifies the charset of the database | `string` | `"UTF8"` | no |

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
| database_id | The ID of the PostgreSQL Flexible Server Database |
| database_name | The name of the PostgreSQL Flexible Server Database |
| database_collation | The collation of the PostgreSQL Flexible Server Database |
| database_charset | The charset of the PostgreSQL Flexible Server Database |
| server_id | The ID of the PostgreSQL Flexible Server |
| tags | The tags applied to the resources |
| context | Exported context for use by other modules |
| id | The generated ID from the label module |

## Notes

### Getting Server ID

The `server_id` can be obtained from:

1. **From Azure Portal**: Navigate to the PostgreSQL Flexible Server → Properties → Resource ID
2. **From Azure CLI**:
   ```bash
   az postgres flexible-server show \
     --resource-group <resource-group-name> \
     --name <server-name> \
     --query id -o tsv
   ```
3. **From another Atmos component output**:
   ```yaml
   server_id: "{{ (atmos.Component 'azure-postgres-server' .stack).outputs.server_id }}"
   ```

### Supported Collations

Common PostgreSQL collations include:
- `en_US.utf8` - English (United States) UTF-8
- `en_GB.utf8` - English (United Kingdom) UTF-8
- `de_DE.utf8` - German (Germany) UTF-8
- `fr_FR.utf8` - French (France) UTF-8
- `C` - Traditional C locale
- `POSIX` - POSIX locale

### Supported Character Sets

Valid PostgreSQL character sets:
- `UTF8` - Unicode, 8-bit (recommended)
- `SQL_ASCII` - ASCII
- `LATIN1` through `LATIN10` - ISO 8859 series
- And other PostgreSQL-supported encodings

### Use Cases

This component is useful when:

1. **Separation of Concerns**: Server infrastructure is managed by platform team, databases by application teams
2. **Multi-Tenant Applications**: Multiple databases on the same server for different tenants
3. **Microservices**: Each microservice gets its own database on a shared PostgreSQL server
4. **Environment Promotion**: Create identical databases across dev/staging/prod servers
5. **Database Lifecycle Management**: Independent creation, deletion, and versioning of databases

### Limitations

- Database names must be unique per PostgreSQL Flexible Server
- Cannot change collation or charset after database creation (requires recreation)
- Database names have a maximum length of 63 characters
- Some collations may require specific server configuration

## Examples

### Development Environment

```yaml
components:
  terraform:
    dev-app-db:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "devdb"
        server_id: "/subscriptions/xxx/resourceGroups/dev-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/dev-postgres"

        tags:
          Environment: "Development"
          Application: "MyApp"
```

### Production Environment with Multiple Databases

```yaml
components:
  terraform:
    prod-main-db:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "production"
        server_id: "/subscriptions/xxx/resourceGroups/prod-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/prod-postgres"

        tags:
          Environment: "Production"
          Application: "MyApp"
          Database: "Main"

    prod-analytics-db:
      metadata:
        component: azure-postgres-database
      vars:
        enabled: true
        name: "analytics"
        server_id: "/subscriptions/xxx/resourceGroups/prod-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/prod-postgres"

        tags:
          Environment: "Production"
          Application: "Analytics"
          Database: "Analytics"
```

## References

- [Azure PostgreSQL Flexible Server Database Documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-limits)
- [PostgreSQL Collation Documentation](https://www.postgresql.org/docs/current/collation.html)
- [PostgreSQL Character Sets](https://www.postgresql.org/docs/current/multibyte.html)
- [Terraform AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/postgresql_flexible_server_database)
