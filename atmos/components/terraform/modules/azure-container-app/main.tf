module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  tenant      = var.tenant
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags

  regex_replace_chars = var.regex_replace_chars
  label_order         = var.label_order
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case
  id_length_limit     = var.id_length_limit
}

# Azure Container App Environment
resource "azurerm_container_app_environment" "this" {
  count = var.enabled && var.create_environment ? 1 : 0

  name                = coalesce(var.environment_name, "${module.label.id}env")
  location            = var.location
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  zone_redundancy_enabled        = var.zone_redundancy_enabled
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "workload_profile" {
    for_each = { for idx, profile in var.workload_profile : idx => profile }
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }

  tags = module.label.tags
}

# Local variable for environment ID
locals {
  environment_id = var.enabled ? (
    var.create_environment ?
    azurerm_container_app_environment.this[0].id :
    var.environment_id
  ) : ""
}

# Azure Container App
resource "azurerm_container_app" "this" {
  count = var.enabled ? 1 : 0

  name                         = coalesce(var.container_app_name, module.label.id)
  container_app_environment_id = local.environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "container" {
      for_each = { for idx, c in var.containers : idx => c }
      content {
        name    = container.value.name
        image   = container.value.image
        cpu     = container.value.cpu
        memory  = container.value.memory
        args    = container.value.args
        command = container.value.command

        dynamic "env" {
          for_each = container.value.env != null ? { for idx, e in container.value.env : idx => e } : {}
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
          content {
            transport               = liveness_probe.value.transport
            port                    = liveness_probe.value.port
            path                    = liveness_probe.value.path
            host                    = liveness_probe.value.host
            interval_seconds        = liveness_probe.value.interval_seconds
            timeout                 = liveness_probe.value.timeout
            failure_count_threshold = liveness_probe.value.failure_count_threshold
            initial_delay           = liveness_probe.value.initial_delay

            dynamic "header" {
              for_each = liveness_probe.value.header != null ? { for idx, h in liveness_probe.value.header : idx => h } : {}
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
          content {
            transport               = readiness_probe.value.transport
            port                    = readiness_probe.value.port
            path                    = readiness_probe.value.path
            host                    = readiness_probe.value.host
            interval_seconds        = readiness_probe.value.interval_seconds
            timeout                 = readiness_probe.value.timeout
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            success_count_threshold = readiness_probe.value.success_count_threshold

            dynamic "header" {
              for_each = readiness_probe.value.header != null ? { for idx, h in readiness_probe.value.header : idx => h } : {}
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = container.value.startup_probe != null ? [container.value.startup_probe] : []
          content {
            transport               = startup_probe.value.transport
            port                    = startup_probe.value.port
            path                    = startup_probe.value.path
            host                    = startup_probe.value.host
            interval_seconds        = startup_probe.value.interval_seconds
            timeout                 = startup_probe.value.timeout
            failure_count_threshold = startup_probe.value.failure_count_threshold

            dynamic "header" {
              for_each = startup_probe.value.header != null ? { for idx, h in startup_probe.value.header : idx => h } : {}
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts != null ? { for idx, vm in container.value.volume_mounts : idx => vm } : {}
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "init_container" {
      for_each = { for idx, c in var.init_containers : idx => c }
      content {
        name    = init_container.value.name
        image   = init_container.value.image
        cpu     = init_container.value.cpu
        memory  = init_container.value.memory
        args    = init_container.value.args
        command = init_container.value.command

        dynamic "env" {
          for_each = init_container.value.env != null ? { for idx, e in init_container.value.env : idx => e } : {}
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts != null ? { for idx, vm in init_container.value.volume_mounts : idx => vm } : {}
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "volume" {
      for_each = { for idx, v in var.volumes : idx => v }
      content {
        name         = volume.value.name
        storage_type = volume.value.storage_type
        storage_name = volume.value.storage_name
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = { for idx, rule in var.scale_rules : idx => rule if rule.azure_queue != null }
      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.azure_queue.queue_name
        queue_length = azure_queue_scale_rule.value.azure_queue.queue_length

        authentication {
          secret_name       = azure_queue_scale_rule.value.azure_queue.account_name
          trigger_parameter = "connection"
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = { for idx, rule in var.scale_rules : idx => rule if rule.custom != null }
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom.type
        metadata         = custom_scale_rule.value.custom.metadata

        dynamic "authentication" {
          for_each = custom_scale_rule.value.custom.authentication != null ? { for idx, a in custom_scale_rule.value.custom.authentication : idx => a } : {}
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = { for idx, rule in var.scale_rules : idx => rule if rule.http != null }
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.http.concurrent_requests
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = { for idx, rule in var.scale_rules : idx => rule if rule.tcp != null }
      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.tcp.concurrent_requests
      }
    }
  }

  dynamic "ingress" {
    for_each = var.ingress != null ? [var.ingress] : []
    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = ingress.value.transport
      allow_insecure_connections = ingress.value.allow_insecure_connections
      exposed_port               = ingress.value.exposed_port

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight != null ? { for idx, tw in ingress.value.traffic_weight : idx => tw } : {}
        content {
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
          percentage      = traffic_weight.value.percentage
        }
      }

      dynamic "custom_domain" {
        for_each = ingress.value.custom_domain != null ? { for idx, cd in ingress.value.custom_domain : idx => cd } : {}
        content {
          name                     = custom_domain.value.name
          certificate_binding_type = custom_domain.value.certificate_binding_type
          certificate_id           = custom_domain.value.certificate_id
        }
      }

      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restriction != null ? { for idx, isr in ingress.value.ip_security_restriction : idx => isr } : {}
        content {
          name             = ip_security_restriction.value.name
          ip_address_range = ip_security_restriction.value.ip_address_range
          description      = ip_security_restriction.value.description
          action           = ip_security_restriction.value.action
        }
      }
    }
  }

  dynamic "dapr" {
    for_each = var.dapr != null ? [var.dapr] : []
    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "registry" {
    for_each = { for idx, r in var.registry : idx => r }
    content {
      server               = registry.value.server
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
      identity             = registry.value.identity
    }
  }

  dynamic "secret" {
    for_each = { for idx, s in var.secrets : idx => s }
    content {
      name                = secret.value.name
      value               = secret.value.value
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
    }
  }

  tags = module.label.tags
}
