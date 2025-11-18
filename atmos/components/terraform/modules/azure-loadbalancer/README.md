# Azure Load Balancer Terraform Module

This module creates and manages an Azure Load Balancer with support for frontend IP configurations, backend address pools, health probes, load balancing rules, NAT rules, NAT pools, and outbound rules.

## Features

- **Multiple SKU Support**: Basic, Standard, and Gateway SKUs
- **Frontend IP Configurations**: Support for both public and private IP addresses
- **Backend Address Pools**: Multiple backend pools with optional tunnel interfaces
- **Health Probes**: TCP, HTTP, and HTTPS health probes with customizable thresholds
- **Load Balancing Rules**: Flexible load distribution with multiple algorithms
- **Inbound NAT Rules**: Port forwarding for individual backend instances
- **NAT Pools**: Port address translation for VM scale sets
- **Outbound Rules**: Configure outbound connectivity for Standard SKU
- **Zone Redundancy**: Support for availability zones
- **CloudPosse Label Integration**: Consistent naming and tagging using the label module
- **Conditional Creation**: Enable/disable resource creation with a single variable

## Usage

### Basic Public Load Balancer

```hcl
module "public_loadbalancer" {
  source = "../../modules/azure-loadbalancer"

  enabled             = true
  location            = "eastus"
  resource_group_name = "rg-network-prod"

  sku      = "Standard"
  sku_tier = "Regional"

  frontend_ip_configurations = [
    {
      name                 = "public-frontend"
      public_ip_address_id = azurerm_public_ip.example.id
      zones                = ["1", "2", "3"]
    }
  ]

  backend_address_pools = {
    web-pool = {
      name = "web-backend-pool"
    }
  }

  probes = {
    http-probe = {
      name                = "http-health-probe"
      protocol            = "Http"
      port                = 80
      request_path        = "/health"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  }

  load_balancing_rules = {
    http-rule = {
      name                           = "http-lb-rule"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "public-frontend"
      backend_address_pool_keys      = ["web-pool"]
      probe_key                      = "http-probe"
      enable_tcp_reset               = true
      idle_timeout_in_minutes        = 4
    }
  }

  # Label module configuration
  namespace   = "acme"
  environment = "eus"
  stage       = "prod"
  name        = "web-lb"
  tags = {
    ManagedBy = "Terraform"
    Purpose   = "Web Traffic"
  }
}
```

### Internal Load Balancer with Multiple Backend Pools

```hcl
module "internal_loadbalancer" {
  source = "../../modules/azure-loadbalancer"

  enabled             = true
  location            = "westeurope"
  resource_group_name = "rg-network-prod"

  sku      = "Standard"
  sku_tier = "Regional"

  frontend_ip_configurations = [
    {
      name                          = "internal-frontend"
      subnet_id                     = azurerm_subnet.backend.id
      private_ip_address            = "10.0.1.100"
      private_ip_address_allocation = "Static"
      private_ip_address_version    = "IPv4"
      zones                         = ["1", "2", "3"]
    }
  ]

  backend_address_pools = {
    app-pool = {
      name = "application-pool"
    }
    db-pool = {
      name = "database-pool"
    }
  }

  probes = {
    app-probe = {
      name                = "app-tcp-probe"
      protocol            = "Tcp"
      port                = 8080
      interval_in_seconds = 10
      number_of_probes    = 3
    }
    db-probe = {
      name                = "db-tcp-probe"
      protocol            = "Tcp"
      port                = 5432
      interval_in_seconds = 10
      number_of_probes    = 3
    }
  }

  load_balancing_rules = {
    app-rule = {
      name                           = "app-lb-rule"
      protocol                       = "Tcp"
      frontend_port                  = 8080
      backend_port                   = 8080
      frontend_ip_configuration_name = "internal-frontend"
      backend_address_pool_keys      = ["app-pool"]
      probe_key                      = "app-probe"
      enable_tcp_reset               = true
      load_distribution              = "SourceIPProtocol"
    }
    db-rule = {
      name                           = "db-lb-rule"
      protocol                       = "Tcp"
      frontend_port                  = 5432
      backend_port                   = 5432
      frontend_ip_configuration_name = "internal-frontend"
      backend_address_pool_keys      = ["db-pool"]
      probe_key                      = "db-probe"
      enable_tcp_reset               = true
    }
  }

  namespace   = "acme"
  environment = "weu"
  stage       = "prod"
  name        = "internal-lb"
  tags = {
    ManagedBy = "Terraform"
    Purpose   = "Internal Services"
  }
}
```

### Advanced Configuration with NAT Rules and Outbound Rules

```hcl
module "advanced_loadbalancer" {
  source = "../../modules/azure-loadbalancer"

  enabled             = true
  location            = "eastus2"
  resource_group_name = "rg-network-prod"

  sku      = "Standard"
  sku_tier = "Regional"

  frontend_ip_configurations = [
    {
      name                 = "public-frontend-1"
      public_ip_address_id = azurerm_public_ip.lb_pip_1.id
      zones                = ["1", "2", "3"]
    },
    {
      name                 = "public-frontend-2"
      public_ip_address_id = azurerm_public_ip.lb_pip_2.id
      zones                = ["1", "2", "3"]
    }
  ]

  backend_address_pools = {
    primary-pool = {
      name = "primary-backend-pool"
    }
  }

  probes = {
    https-probe = {
      name                = "https-health-probe"
      protocol            = "Https"
      port                = 443
      request_path        = "/api/health"
      interval_in_seconds = 15
      number_of_probes    = 2
      probe_threshold     = 1
    }
  }

  load_balancing_rules = {
    https-rule = {
      name                           = "https-lb-rule"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "public-frontend-1"
      backend_address_pool_keys      = ["primary-pool"]
      probe_key                      = "https-probe"
      enable_tcp_reset               = true
      disable_outbound_snat          = true
      idle_timeout_in_minutes        = 15
    }
  }

  nat_rules = {
    ssh-vm1 = {
      name                           = "ssh-nat-vm1"
      protocol                       = "Tcp"
      frontend_port                  = 22001
      backend_port                   = 22
      frontend_ip_configuration_name = "public-frontend-2"
      enable_tcp_reset               = true
    }
    ssh-vm2 = {
      name                           = "ssh-nat-vm2"
      protocol                       = "Tcp"
      frontend_port                  = 22002
      backend_port                   = 22
      frontend_ip_configuration_name = "public-frontend-2"
      enable_tcp_reset               = true
    }
  }

  outbound_rules = {
    outbound = {
      name                             = "outbound-rule"
      protocol                         = "All"
      backend_address_pool_key         = "primary-pool"
      frontend_ip_configuration_names  = ["public-frontend-1", "public-frontend-2"]
      allocated_outbound_ports         = 1024
      idle_timeout_in_minutes          = 4
      enable_tcp_reset                 = true
    }
  }

  namespace   = "acme"
  environment = "eus2"
  stage       = "prod"
  name        = "advanced-lb"
  delimiter   = "-"
  tags = {
    ManagedBy   = "Terraform"
    Purpose     = "Production Services"
    Criticality = "High"
  }
}
```

### Development Environment

```hcl
module "dev_loadbalancer" {
  source = "../../modules/azure-loadbalancer"

  enabled             = true
  location            = "eastus"
  resource_group_name = "rg-network-dev"

  sku      = "Basic"
  sku_tier = "Regional"

  frontend_ip_configurations = [
    {
      name                 = "dev-frontend"
      public_ip_address_id = azurerm_public_ip.dev.id
    }
  ]

  backend_address_pools = {
    dev-pool = {
      name = "dev-backend-pool"
    }
  }

  probes = {
    tcp-probe = {
      name                = "tcp-probe"
      protocol            = "Tcp"
      port                = 80
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  }

  load_balancing_rules = {
    http = {
      name                           = "http-rule"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "dev-frontend"
      backend_address_pool_keys      = ["dev-pool"]
      probe_key                      = "tcp-probe"
    }
  }

  namespace   = "acme"
  environment = "eus"
  stage       = "dev"
  name        = "lb"
  tags = {
    ManagedBy   = "Terraform"
    Environment = "Development"
    CostCenter  = "Engineering"
  }
}
```

## Atmos Stack Configuration

```yaml
components:
  terraform:
    azure-loadbalancer:
      metadata:
        component: azure-loadbalancer
        type: real
      vars:
        enabled: true
        location: "eastus"
        resource_group_name: "rg-network-prod"

        sku: "Standard"
        sku_tier: "Regional"

        frontend_ip_configurations:
          - name: "public-frontend"
            public_ip_address_id: "{{ outputs.azure-public-ip.id }}"
            zones: ["1", "2", "3"]

        backend_address_pools:
          web-pool:
            name: "web-backend-pool"

        probes:
          http-probe:
            name: "http-health-probe"
            protocol: "Http"
            port: 80
            request_path: "/health"
            interval_in_seconds: 15
            number_of_probes: 2

        load_balancing_rules:
          http-rule:
            name: "http-lb-rule"
            protocol: "Tcp"
            frontend_port: 80
            backend_port: 80
            frontend_ip_configuration_name: "public-frontend"
            backend_address_pool_keys: ["web-pool"]
            probe_key: "http-probe"
            enable_tcp_reset: true

        namespace: "acme"
        environment: "eus"
        stage: "prod"
        name: "web-lb"
        delimiter: "-"
        tags:
          ManagedBy: "Terraform"
          Purpose: "Web Traffic"
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

| Name | Type |
|------|------|
| [azurerm_lb.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb_rule) | resource |
| [azurerm_lb_nat_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb_nat_rule) | resource |
| [azurerm_lb_nat_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb_nat_pool) | resource |
| [azurerm_lb_outbound_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb_outbound_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| location | The Azure Region where the Load Balancer should exist | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group where the Load Balancer should exist | `string` | n/a | yes |
| loadbalancer_name | Specifies the name of the Load Balancer. If not provided, the name will be generated using the label module | `string` | `null` | no |
| sku | The SKU of the Azure Load Balancer. Accepted values are Basic, Standard and Gateway | `string` | `"Standard"` | no |
| sku_tier | The SKU tier of this Load Balancer. Possible values are Global and Regional | `string` | `"Regional"` | no |
| edge_zone | Specifies the Edge Zone within the Azure Region where this Load Balancer should exist | `string` | `null` | no |
| frontend_ip_configurations | List of frontend IP configurations for the Load Balancer | `list(object)` | `[]` | no |
| backend_address_pools | Map of backend address pools for the Load Balancer | `map(object)` | `{}` | no |
| probes | Map of health probes for the Load Balancer | `map(object)` | `{}` | no |
| load_balancing_rules | Map of load balancing rules for the Load Balancer | `map(object)` | `{}` | no |
| nat_rules | Map of inbound NAT rules for the Load Balancer | `map(object)` | `{}` | no |
| nat_pools | Map of NAT pools for the Load Balancer | `map(object)` | `{}` | no |
| outbound_rules | Map of outbound rules for the Load Balancer (Standard SKU only) | `map(object)` | `{}` | no |
| namespace | ID element. Usually an abbreviation of your organization name | `string` | `null` | no |
| tenant | ID element. Usually used to indicate the tenant identifier | `string` | `null` | no |
| environment | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| stage | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| name | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| attributes | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id` | `list(string)` | `[]` | no |
| delimiter | Delimiter to be used between ID elements | `string` | `"-"` | no |
| tags | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`) | `map(string)` | `{}` | no |
| regex_replace_chars | Regex to replace characters in ID elements | `string` | `null` | no |
| label_order | The order in which the labels appear in the `id` | `list(string)` | `null` | no |
| label_key_case | Controls the letter case of tag keys | `string` | `null` | no |
| label_value_case | Controls the letter case of ID elements | `string` | `null` | no |
| id_length_limit | Limit `id` to this many characters (minimum 6) | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Load Balancer |
| name | The name of the Load Balancer |
| frontend_ip_configuration | The frontend IP configuration of the Load Balancer |
| frontend_ip_configuration_ids | Map of frontend IP configuration names to their IDs |
| backend_address_pool_ids | Map of backend address pool names to their IDs |
| probe_ids | Map of probe names to their IDs |
| load_balancing_rule_ids | Map of load balancing rule names to their IDs |
| nat_rule_ids | Map of NAT rule names to their IDs |
| nat_pool_ids | Map of NAT pool names to their IDs |
| outbound_rule_ids | Map of outbound rule names to their IDs |
| private_ip_address | The first private IP address assigned to the load balancer |
| private_ip_addresses | The list of private IP addresses assigned to the load balancer |
| label_id | The generated ID from the label module |
| tags | The tags applied to the Load Balancer |
| context | Exported context from the label module |

## Notes

### SKU Considerations

- **Basic SKU**:
  - Supports up to 300 instances
  - Open by default (no Network Security Groups required)
  - Does not support Availability Zones
  - Does not support outbound rules
  - Free tier

- **Standard SKU**:
  - Supports up to 1000 instances
  - Secure by default (requires Network Security Groups)
  - Supports Availability Zones
  - Supports outbound rules for SNAT
  - Zone-redundant and zonal frontends
  - Charged based on rules and data processed

- **Gateway SKU**:
  - For third-party network virtual appliances
  - Supports chain of network virtual appliances

### Load Distribution Algorithms

The `load_distribution` parameter supports the following values:

- **Default**: Five-tuple hash (source IP, source port, destination IP, destination port, protocol)
- **SourceIP**: Two-tuple hash (source IP, destination IP) - session affinity
- **SourceIPProtocol**: Three-tuple hash (source IP, destination IP, protocol)

### Health Probe Protocols

- **Tcp**: Simple TCP connection check
- **Http**: HTTP GET request with 200-399 response expected
- **Https**: HTTPS GET request with 200-399 response expected

### Availability Zones

When using availability zones:
- Specify zones in `frontend_ip_configurations` as a list (e.g., `["1", "2", "3"]`)
- Zone-redundant deployment requires Standard SKU
- Public IP addresses must also be zone-redundant or zonal

### Outbound Connectivity

For Standard SKU Load Balancers:
- Outbound rules control SNAT port allocation
- `allocated_outbound_ports` should be calculated based on backend pool size
- Formula: `(frontend IPs × 64K) / backend instances`
- Use multiple frontend IPs for higher SNAT port capacity

### Resource Dependencies

Load Balancer resources must be created in this order:
1. Load Balancer
2. Backend Address Pools
3. Probes
4. Load Balancing Rules (depends on pools and probes)
5. NAT Rules/Pools
6. Outbound Rules (depends on pools)

This module handles these dependencies automatically.

## References

- [Azure Load Balancer Documentation](https://learn.microsoft.com/en-us/azure/load-balancer/)
- [Azure Load Balancer SKUs](https://learn.microsoft.com/en-us/azure/load-balancer/skus)
- [Load Balancer Health Probes](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-custom-probe-overview)
- [Outbound Rules](https://learn.microsoft.com/en-us/azure/load-balancer/outbound-rules)
- [AzureRM Load Balancer Resource](https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/lb)
- [CloudPosse Label Module](https://registry.terraform.io/modules/cloudposse/label/null/latest)
