module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace           = var.namespace
  tenant              = var.tenant
  environment         = var.environment
  stage               = var.stage
  name                = var.name
  attributes          = var.attributes
  delimiter           = var.delimiter
  tags                = var.tags
  regex_replace_chars = var.regex_replace_chars
  label_order         = var.label_order
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case
  id_length_limit     = var.id_length_limit
}

locals {
  loadbalancer_name = var.enabled ? coalesce(var.loadbalancer_name, module.label.id) : null
}

resource "azurerm_lb" "this" {
  count = var.enabled ? 1 : 0

  name                = local.loadbalancer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  sku_tier            = var.sku_tier
  edge_zone           = var.edge_zone

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations

    content {
      name                                               = frontend_ip_configuration.value.name
      zones                                              = frontend_ip_configuration.value.zones
      subnet_id                                          = frontend_ip_configuration.value.subnet_id
      gateway_load_balancer_frontend_ip_configuration_id = frontend_ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id
      private_ip_address                                 = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation                      = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address_version                         = frontend_ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = frontend_ip_configuration.value.public_ip_address_id
      public_ip_prefix_id                                = frontend_ip_configuration.value.public_ip_prefix_id
    }
  }

  tags = module.label.tags
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each = var.enabled ? var.backend_address_pools : {}

  name            = each.value.name
  loadbalancer_id = azurerm_lb.this[0].id

  dynamic "tunnel_interface" {
    for_each = each.value.tunnel_interfaces != null ? each.value.tunnel_interfaces : []

    content {
      identifier = tunnel_interface.value.identifier
      type       = tunnel_interface.value.type
      protocol   = tunnel_interface.value.protocol
      port       = tunnel_interface.value.port
    }
  }
}

resource "azurerm_lb_probe" "this" {
  for_each = var.enabled ? var.probes : {}

  name                = each.value.name
  loadbalancer_id     = azurerm_lb.this[0].id
  protocol            = each.value.protocol
  port                = each.value.port
  request_path        = each.value.request_path
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
  probe_threshold     = each.value.probe_threshold
}

resource "azurerm_lb_rule" "this" {
  for_each = var.enabled ? var.load_balancing_rules : {}

  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.this[0].id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [for pool_key in each.value.backend_address_pool_keys : azurerm_lb_backend_address_pool.this[pool_key].id]
  probe_id                       = each.value.probe_key != null ? azurerm_lb_probe.this[each.value.probe_key].id : null
  enable_floating_ip             = each.value.enable_floating_ip
  enable_tcp_reset               = each.value.enable_tcp_reset
  disable_outbound_snat          = each.value.disable_outbound_snat
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  load_distribution              = each.value.load_distribution
}

resource "azurerm_lb_nat_rule" "this" {
  for_each = var.enabled ? var.nat_rules : {}

  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.this[0].id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  enable_floating_ip             = each.value.enable_floating_ip
  enable_tcp_reset               = each.value.enable_tcp_reset
}

resource "azurerm_lb_nat_pool" "this" {
  for_each = var.enabled ? var.nat_pools : {}

  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.this[0].id
  protocol                       = each.value.protocol
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  floating_ip_enabled            = each.value.floating_ip_enabled
  tcp_reset_enabled              = each.value.tcp_reset_enabled
}

resource "azurerm_lb_outbound_rule" "this" {
  for_each = var.enabled ? var.outbound_rules : {}

  name                     = each.value.name
  loadbalancer_id          = azurerm_lb.this[0].id
  protocol                 = each.value.protocol
  backend_address_pool_id  = azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_key].id
  allocated_outbound_ports = each.value.allocated_outbound_ports
  idle_timeout_in_minutes  = each.value.idle_timeout_in_minutes
  enable_tcp_reset         = each.value.enable_tcp_reset

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration_names

    content {
      name = frontend_ip_configuration.value
    }
  }
}
