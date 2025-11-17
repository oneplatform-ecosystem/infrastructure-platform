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

locals {
  # VM name
  vm_name = var.enabled ? coalesce(var.vm_name, module.label.id) : null
  # NIC name
  nic_name = var.enabled ? coalesce(var.nic_name, "${local.vm_name}-nic") : null
  # Public IP name
  public_ip_name = var.enabled && var.create_public_ip ? coalesce(var.public_ip_name, "${local.vm_name}-pip") : null
  # OS disk name
  os_disk_name = var.enabled ? coalesce(var.os_disk_name, "${local.vm_name}-osdisk") : null
}

# Public IP Address (optional)
resource "azurerm_public_ip" "this" {
  count = var.enabled && var.create_public_ip ? 1 : 0

  name                = local.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  zones               = var.zones

  tags = module.label.tags
}

# Network Interface
resource "azurerm_network_interface" "this" {
  count = var.enabled ? 1 : 0

  name                = local.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : null
  }

  enable_accelerated_networking = var.enable_accelerated_networking
  enable_ip_forwarding          = var.enable_ip_forwarding

  tags = module.label.tags
}

# Network Interface - Application Security Group Association
resource "azurerm_network_interface_application_security_group_association" "this" {
  count = var.enabled && var.application_security_group_id != null ? 1 : 0

  network_interface_id          = azurerm_network_interface.this[0].id
  application_security_group_id = var.application_security_group_id
}

# Network Interface - Network Security Group Association
resource "azurerm_network_interface_security_group_association" "this" {
  count = var.enabled && var.network_security_group_id != null ? 1 : 0

  network_interface_id      = azurerm_network_interface.this[0].id
  network_security_group_id = var.network_security_group_id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "this" {
  count = var.enabled && var.os_type == "Linux" ? 1 : 0

  name                = local.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.this[0].id
  ]

  # Authentication
  disable_password_authentication = var.disable_password_authentication
  admin_password                  = var.disable_password_authentication ? null : var.admin_password

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_keys
    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  # OS Disk
  os_disk {
    name                 = local.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Source Image
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_id

  # Additional Configuration
  computer_name                   = var.computer_name != null ? var.computer_name : local.vm_name
  custom_data                     = var.custom_data
  availability_set_id             = var.availability_set_id
  zone                            = var.zone
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  secure_boot_enabled             = var.secure_boot_enabled
  vtpm_enabled                    = var.vtpm_enabled
  patch_mode                      = var.linux_patch_mode
  patch_assessment_mode           = var.patch_assessment_mode
  provision_vm_agent              = var.provision_vm_agent
  allow_extension_operations      = var.allow_extension_operations
  license_type                    = var.license_type

  # Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Managed Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Plan (for marketplace images)
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  tags = module.label.tags
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "this" {
  count = var.enabled && var.os_type == "Windows" ? 1 : 0

  name                = local.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.this[0].id
  ]

  # OS Disk
  os_disk {
    name                 = local.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Source Image
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_id

  # Additional Configuration
  computer_name                   = var.computer_name != null ? var.computer_name : local.vm_name
  custom_data                     = var.custom_data
  availability_set_id             = var.availability_set_id
  zone                            = var.zone
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  secure_boot_enabled             = var.secure_boot_enabled
  vtpm_enabled                    = var.vtpm_enabled
  patch_mode                      = var.windows_patch_mode
  patch_assessment_mode           = var.patch_assessment_mode
  provision_vm_agent              = var.provision_vm_agent
  allow_extension_operations      = var.allow_extension_operations
  enable_automatic_updates        = var.enable_automatic_updates
  license_type                    = var.license_type
  timezone                        = var.timezone

  # Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Managed Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Plan (for marketplace images)
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  tags = module.label.tags
}

# Managed Data Disks
resource "azurerm_managed_disk" "this" {
  for_each = var.enabled ? var.data_disks : {}

  name                 = "${local.vm_name}-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
  zone                 = var.zone

  tags = module.label.tags
}

# Data Disk Attachments
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = var.enabled ? var.data_disks : {}

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  lun                = each.value.lun
  caching            = each.value.caching
}
