####################
# AKS Cluster Outputs
####################

output "cluster_id" {
  description = "The ID of the Kubernetes Cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].id : ""
}

output "cluster_name" {
  description = "The name of the Kubernetes Cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].name : ""
}

output "cluster_fqdn" {
  description = "The FQDN of the Kubernetes Cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].fqdn : ""
}

output "private_fqdn" {
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled"
  value       = var.enabled && var.private_cluster_enabled ? azurerm_kubernetes_cluster.this[0].private_fqdn : ""
}

output "portal_fqdn" {
  description = "The FQDN for the Azure Portal when private link has been enabled"
  value       = var.enabled && var.private_cluster_enabled ? azurerm_kubernetes_cluster.this[0].portal_fqdn : ""
}

output "kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kube_config_raw : ""
  sensitive   = true
}

output "kube_admin_config" {
  description = "Raw Kubernetes admin config"
  value       = var.enabled && !var.local_account_disabled ? azurerm_kubernetes_cluster.this[0].kube_admin_config_raw : ""
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kube_config[0].host : ""
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kube_config[0].client_certificate : ""
  sensitive   = true
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kube_config[0].client_key : ""
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kube_config[0].cluster_ca_certificate : ""
  sensitive   = true
}

output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].node_resource_group : ""
}

output "identity_principal_id" {
  description = "The Principal ID associated with the system assigned managed identity"
  value       = var.enabled && var.identity_type != null ? azurerm_kubernetes_cluster.this[0].identity[0].principal_id : ""
}

output "identity_tenant_id" {
  description = "The Tenant ID associated with the system assigned managed identity"
  value       = var.enabled && var.identity_type != null ? azurerm_kubernetes_cluster.this[0].identity[0].tenant_id : ""
}

output "kubelet_identity_object_id" {
  description = "The Object ID of the user-defined Managed Identity assigned to the Kubelets"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kubelet_identity[0].object_id : ""
}

output "kubelet_identity_client_id" {
  description = "The Client ID of the user-defined Managed Identity assigned to the Kubelets"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kubelet_identity[0].client_id : ""
}

output "kubelet_identity_user_assigned_identity_id" {
  description = "The ID of the User Assigned Identity assigned to the Kubelets"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].kubelet_identity[0].user_assigned_identity_id : ""
}

output "oms_agent_identity_object_id" {
  description = "The Object ID of the user-defined Managed Identity used by the OMS Agent"
  value       = var.enabled && var.oms_agent != null ? azurerm_kubernetes_cluster.this[0].oms_agent[0].oms_agent_identity[0].object_id : ""
}

output "oms_agent_identity_client_id" {
  description = "The Client ID of the user-defined Managed Identity used by the OMS Agent"
  value       = var.enabled && var.oms_agent != null ? azurerm_kubernetes_cluster.this[0].oms_agent[0].oms_agent_identity[0].client_id : ""
}

output "key_vault_secrets_provider_secret_identity_object_id" {
  description = "The Object ID of the user-defined Managed Identity used by the Key Vault Secrets Provider"
  value       = var.enabled && var.key_vault_secrets_provider != null ? azurerm_kubernetes_cluster.this[0].key_vault_secrets_provider[0].secret_identity[0].object_id : ""
}

output "key_vault_secrets_provider_secret_identity_client_id" {
  description = "The Client ID of the user-defined Managed Identity used by the Key Vault Secrets Provider"
  value       = var.enabled && var.key_vault_secrets_provider != null ? azurerm_kubernetes_cluster.this[0].key_vault_secrets_provider[0].secret_identity[0].client_id : ""
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster"
  value       = var.enabled && var.oidc_issuer_enabled ? azurerm_kubernetes_cluster.this[0].oidc_issuer_url : ""
}

output "current_kubernetes_version" {
  description = "The current version of Kubernetes running on the cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].current_kubernetes_version : ""
}

output "http_application_routing_zone_name" {
  description = "The Zone Name of the HTTP Application Routing"
  value       = var.enabled && var.http_application_routing_enabled ? azurerm_kubernetes_cluster.this[0].http_application_routing_zone_name : ""
}

output "resource_group_name" {
  description = "The name of the resource group in which the AKS cluster was created"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].resource_group_name : ""
}

output "location" {
  description = "The Azure Region where the AKS cluster exists"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].location : ""
}

output "additional_node_pool_ids" {
  description = "Map of additional node pool names to their IDs"
  value       = var.enabled ? { for k, v in azurerm_kubernetes_cluster_node_pool.this : k => v.id } : {}
}

output "additional_node_pool_names" {
  description = "List of additional node pool names"
  value       = var.enabled ? [for k, v in azurerm_kubernetes_cluster_node_pool.this : v.name] : []
}

output "tags" {
  description = "Tags applied to the AKS cluster"
  value       = var.enabled ? azurerm_kubernetes_cluster.this[0].tags : {}
}

output "context" {
  description = "Exported context from label module for use by other modules"
  value       = module.label.context
}
