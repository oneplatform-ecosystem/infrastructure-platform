module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled             = var.enabled
  namespace           = var.namespace
  tenant              = var.tenant
  environment         = var.environment
  stage               = var.stage
  name                = var.name
  attributes          = var.attributes
  delimiter           = var.delimiter
  tags                = var.tags
  additional_tag_map  = var.additional_tag_map
  regex_replace_chars = var.regex_replace_chars
  label_order         = var.label_order
  id_length_limit     = var.id_length_limit
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case
  context             = var.context
}

locals {
  frontdoor_profile_name = var.custom_name != null ? var.custom_name : module.label.id
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  count = var.enabled ? 1 : 0

  name                     = local.frontdoor_profile_name
  resource_group_name      = var.resource_group_name
  sku_name                 = var.sku_name
  response_timeout_seconds = var.response_timeout_seconds
  tags                     = module.label.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = var.enabled ? var.endpoints : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  enabled                  = each.value.enabled
  tags                     = merge(module.label.tags, each.value.tags)
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = var.enabled ? var.origin_groups : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  session_affinity_enabled = each.value.session_affinity_enabled

  load_balancing {
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
  }

  dynamic "health_probe" {
    for_each = each.value.health_probe != null ? [each.value.health_probe] : []
    content {
      protocol            = health_probe.value.protocol
      interval_in_seconds = health_probe.value.interval_in_seconds
      request_type        = health_probe.value.request_type
      path                = health_probe.value.path
    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = var.enabled ? var.origins : {}

  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_key].id
  enabled                        = each.value.enabled
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  host_name                      = each.value.host_name
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  origin_host_header             = each.value.origin_host_header
  priority                       = each.value.priority
  weight                         = each.value.weight

  dynamic "private_link" {
    for_each = each.value.private_link != null ? [each.value.private_link] : []
    content {
      request_message        = private_link.value.request_message
      target_type            = private_link.value.target_type
      location               = private_link.value.location
      private_link_target_id = private_link.value.private_link_target_id
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = var.enabled ? var.routes : {}

  name                            = each.value.name
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.this[each.value.endpoint_key].id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_key].id
  cdn_frontdoor_origin_ids        = [for origin_key in each.value.origin_keys : azurerm_cdn_frontdoor_origin.this[origin_key].id]
  enabled                         = each.value.enabled
  forwarding_protocol             = each.value.forwarding_protocol
  https_redirect_enabled          = each.value.https_redirect_enabled
  patterns_to_match               = each.value.patterns_to_match
  supported_protocols             = each.value.supported_protocols
  cdn_frontdoor_custom_domain_ids = each.value.custom_domain_keys != null ? [for domain_key in each.value.custom_domain_keys : azurerm_cdn_frontdoor_custom_domain.this[domain_key].id] : []
  link_to_default_domain          = each.value.link_to_default_domain
  cdn_frontdoor_rule_set_ids      = each.value.rule_set_keys != null ? [for rule_set_key in each.value.rule_set_keys : azurerm_cdn_frontdoor_rule_set.this[rule_set_key].id] : []

  dynamic "cache" {
    for_each = each.value.cache != null ? [each.value.cache] : []
    content {
      query_string_caching_behavior = cache.value.query_string_caching_behavior
      query_strings                 = cache.value.query_strings
      compression_enabled           = cache.value.compression_enabled
      content_types_to_compress     = cache.value.content_types_to_compress
    }
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "this" {
  for_each = var.enabled ? var.rule_sets : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
}

resource "azurerm_cdn_frontdoor_rule" "this" {
  for_each = var.enabled ? var.rules : {}

  name                      = each.value.name
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this[each.value.rule_set_key].id
  order                     = each.value.order
  behavior_on_match         = each.value.behavior_on_match

  actions {
    dynamic "route_configuration_override_action" {
      for_each = each.value.actions.route_configuration_override_action != null ? [each.value.actions.route_configuration_override_action] : []
      content {
        cache_duration                = route_configuration_override_action.value.cache_duration
        cdn_frontdoor_origin_group_id = route_configuration_override_action.value.origin_group_key != null ? azurerm_cdn_frontdoor_origin_group.this[route_configuration_override_action.value.origin_group_key].id : null
        forwarding_protocol           = route_configuration_override_action.value.forwarding_protocol
        query_string_caching_behavior = route_configuration_override_action.value.query_string_caching_behavior
        query_string_parameters       = route_configuration_override_action.value.query_string_parameters
        compression_enabled           = route_configuration_override_action.value.compression_enabled
        cache_behavior                = route_configuration_override_action.value.cache_behavior
      }
    }

    dynamic "url_redirect_action" {
      for_each = each.value.actions.url_redirect_action != null ? [each.value.actions.url_redirect_action] : []
      content {
        redirect_type        = url_redirect_action.value.redirect_type
        redirect_protocol    = url_redirect_action.value.redirect_protocol
        query_string         = url_redirect_action.value.query_string
        destination_path     = url_redirect_action.value.destination_path
        destination_hostname = url_redirect_action.value.destination_hostname
        destination_fragment = url_redirect_action.value.destination_fragment
      }
    }

    dynamic "url_rewrite_action" {
      for_each = each.value.actions.url_rewrite_action != null ? [each.value.actions.url_rewrite_action] : []
      content {
        source_pattern          = url_rewrite_action.value.source_pattern
        destination             = url_rewrite_action.value.destination
        preserve_unmatched_path = url_rewrite_action.value.preserve_unmatched_path
      }
    }

    dynamic "request_header_action" {
      for_each = each.value.actions.request_header_action != null ? each.value.actions.request_header_action : []
      content {
        header_action = request_header_action.value.header_action
        header_name   = request_header_action.value.header_name
        value         = request_header_action.value.value
      }
    }

    dynamic "response_header_action" {
      for_each = each.value.actions.response_header_action != null ? each.value.actions.response_header_action : []
      content {
        header_action = response_header_action.value.header_action
        header_name   = response_header_action.value.header_name
        value         = response_header_action.value.value
      }
    }
  }

  dynamic "conditions" {
    for_each = each.value.conditions != null ? [each.value.conditions] : []
    content {
      dynamic "remote_address_condition" {
        for_each = conditions.value.remote_address_condition != null ? [conditions.value.remote_address_condition] : []
        content {
          operator         = remote_address_condition.value.operator
          negate_condition = remote_address_condition.value.negate_condition
          match_values     = remote_address_condition.value.match_values
        }
      }

      dynamic "request_method_condition" {
        for_each = conditions.value.request_method_condition != null ? [conditions.value.request_method_condition] : []
        content {
          operator         = request_method_condition.value.operator
          negate_condition = request_method_condition.value.negate_condition
          match_values     = request_method_condition.value.match_values
        }
      }

      dynamic "query_string_condition" {
        for_each = conditions.value.query_string_condition != null ? [conditions.value.query_string_condition] : []
        content {
          operator         = query_string_condition.value.operator
          negate_condition = query_string_condition.value.negate_condition
          match_values     = query_string_condition.value.match_values
          transforms       = query_string_condition.value.transforms
        }
      }

      dynamic "post_args_condition" {
        for_each = conditions.value.post_args_condition != null ? [conditions.value.post_args_condition] : []
        content {
          post_args_name   = post_args_condition.value.post_args_name
          operator         = post_args_condition.value.operator
          negate_condition = post_args_condition.value.negate_condition
          match_values     = post_args_condition.value.match_values
          transforms       = post_args_condition.value.transforms
        }
      }

      dynamic "request_uri_condition" {
        for_each = conditions.value.request_uri_condition != null ? [conditions.value.request_uri_condition] : []
        content {
          operator         = request_uri_condition.value.operator
          negate_condition = request_uri_condition.value.negate_condition
          match_values     = request_uri_condition.value.match_values
          transforms       = request_uri_condition.value.transforms
        }
      }

      dynamic "request_header_condition" {
        for_each = conditions.value.request_header_condition != null ? [conditions.value.request_header_condition] : []
        content {
          header_name      = request_header_condition.value.header_name
          operator         = request_header_condition.value.operator
          negate_condition = request_header_condition.value.negate_condition
          match_values     = request_header_condition.value.match_values
          transforms       = request_header_condition.value.transforms
        }
      }

      dynamic "request_body_condition" {
        for_each = conditions.value.request_body_condition != null ? [conditions.value.request_body_condition] : []
        content {
          operator         = request_body_condition.value.operator
          negate_condition = request_body_condition.value.negate_condition
          match_values     = request_body_condition.value.match_values
          transforms       = request_body_condition.value.transforms
        }
      }

      dynamic "request_scheme_condition" {
        for_each = conditions.value.request_scheme_condition != null ? [conditions.value.request_scheme_condition] : []
        content {
          operator         = request_scheme_condition.value.operator
          negate_condition = request_scheme_condition.value.negate_condition
          match_values     = request_scheme_condition.value.match_values
        }
      }

      dynamic "url_path_condition" {
        for_each = conditions.value.url_path_condition != null ? [conditions.value.url_path_condition] : []
        content {
          operator         = url_path_condition.value.operator
          negate_condition = url_path_condition.value.negate_condition
          match_values     = url_path_condition.value.match_values
          transforms       = url_path_condition.value.transforms
        }
      }

      dynamic "url_file_extension_condition" {
        for_each = conditions.value.url_file_extension_condition != null ? [conditions.value.url_file_extension_condition] : []
        content {
          operator         = url_file_extension_condition.value.operator
          negate_condition = url_file_extension_condition.value.negate_condition
          match_values     = url_file_extension_condition.value.match_values
          transforms       = url_file_extension_condition.value.transforms
        }
      }

      dynamic "url_filename_condition" {
        for_each = conditions.value.url_filename_condition != null ? [conditions.value.url_filename_condition] : []
        content {
          operator         = url_filename_condition.value.operator
          negate_condition = url_filename_condition.value.negate_condition
          match_values     = url_filename_condition.value.match_values
          transforms       = url_filename_condition.value.transforms
        }
      }

      dynamic "http_version_condition" {
        for_each = conditions.value.http_version_condition != null ? [conditions.value.http_version_condition] : []
        content {
          operator         = http_version_condition.value.operator
          negate_condition = http_version_condition.value.negate_condition
          match_values     = http_version_condition.value.match_values
        }
      }

      dynamic "cookies_condition" {
        for_each = conditions.value.cookies_condition != null ? [conditions.value.cookies_condition] : []
        content {
          cookie_name      = cookies_condition.value.cookie_name
          operator         = cookies_condition.value.operator
          negate_condition = cookies_condition.value.negate_condition
          match_values     = cookies_condition.value.match_values
          transforms       = cookies_condition.value.transforms
        }
      }

      dynamic "is_device_condition" {
        for_each = conditions.value.is_device_condition != null ? [conditions.value.is_device_condition] : []
        content {
          operator         = is_device_condition.value.operator
          negate_condition = is_device_condition.value.negate_condition
          match_values     = is_device_condition.value.match_values
        }
      }

      dynamic "socket_address_condition" {
        for_each = conditions.value.socket_address_condition != null ? [conditions.value.socket_address_condition] : []
        content {
          operator         = socket_address_condition.value.operator
          negate_condition = socket_address_condition.value.negate_condition
          match_values     = socket_address_condition.value.match_values
        }
      }

      dynamic "client_port_condition" {
        for_each = conditions.value.client_port_condition != null ? [conditions.value.client_port_condition] : []
        content {
          operator         = client_port_condition.value.operator
          negate_condition = client_port_condition.value.negate_condition
          match_values     = client_port_condition.value.match_values
        }
      }

      dynamic "server_port_condition" {
        for_each = conditions.value.server_port_condition != null ? [conditions.value.server_port_condition] : []
        content {
          operator         = server_port_condition.value.operator
          negate_condition = server_port_condition.value.negate_condition
          match_values     = server_port_condition.value.match_values
        }
      }

      dynamic "host_name_condition" {
        for_each = conditions.value.host_name_condition != null ? [conditions.value.host_name_condition] : []
        content {
          operator         = host_name_condition.value.operator
          negate_condition = host_name_condition.value.negate_condition
          match_values     = host_name_condition.value.match_values
          transforms       = host_name_condition.value.transforms
        }
      }

      dynamic "ssl_protocol_condition" {
        for_each = conditions.value.ssl_protocol_condition != null ? [conditions.value.ssl_protocol_condition] : []
        content {
          operator         = ssl_protocol_condition.value.operator
          negate_condition = ssl_protocol_condition.value.negate_condition
          match_values     = ssl_protocol_condition.value.match_values
        }
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = var.enabled ? var.custom_domains : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.value.host_name

  dynamic "tls" {
    for_each = each.value.tls != null ? [each.value.tls] : []
    content {
      certificate_type        = tls.value.certificate_type
      minimum_tls_version     = tls.value.minimum_tls_version
      cdn_frontdoor_secret_id = tls.value.cdn_frontdoor_secret_id
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "this" {
  for_each = var.enabled ? var.security_policies : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = each.value.firewall_policy_id
      association {
        dynamic "domain" {
          for_each = each.value.domain_keys != null ? each.value.domain_keys : []
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.this[domain.value].id
          }
        }
        patterns_to_match = each.value.patterns_to_match
      }
    }
  }
}
