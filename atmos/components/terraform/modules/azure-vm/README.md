# Azure Virtual Machine Module

This Terraform module creates an Azure Virtual Machine (Linux or Windows) with associated resources including network interface, public IP (optional), and data disks.

## Features

- **Dual OS Support**: Create both Linux and Windows Virtual Machines
- **Flexible Authentication**: SSH keys for Linux, password authentication for Windows
- **Network Configuration**: Network interface with optional public IP, NSG, and ASG associations
- **Storage Options**: Configurable OS disk and multiple data disks support
- **High Availability**: Support for Availability Sets and Availability Zones
- **Security**: Encryption at host, secure boot, vTPM, managed identities
- **Monitoring**: Boot diagnostics integration
- **Marketplace Support**: Plan blocks for marketplace images
- **CloudPosse Label Integration**: Consistent naming and tagging

## Usage

### Linux Virtual Machine Example

```hcl
module "linux_vm" {
  source = "../modules/azure-vm"

  # Basic Configuration
  location            = "eastus"
  resource_group_name = "my-resource-group"
  os_type             = "Linux"
  vm_size             = "Standard_D2s_v3"

  # Networking
  subnet_id = azurerm_subnet.example.id

  # Authentication
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  admin_ssh_keys = [
    file("~/.ssh/id_rsa.pub")
  ]

  # Source Image
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Label Module Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "dev"
  name        = "web"

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "WebServer"
  }
}
```

### Windows Virtual Machine Example

```hcl
module "windows_vm" {
  source = "../modules/azure-vm"

  # Basic Configuration
  location            = "eastus"
  resource_group_name = "my-resource-group"
  os_type             = "Windows"
  vm_size             = "Standard_D2s_v3"

  # Networking
  subnet_id = azurerm_subnet.example.id

  # Authentication
  admin_username = "azureadmin"
  admin_password = "P@ssw0rd1234!"  # Use Azure Key Vault in production

  # Source Image
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  # Windows-specific
  enable_automatic_updates = true
  timezone                 = "Eastern Standard Time"

  # Label Module Configuration
  namespace   = "myorg"
  environment = "eus"
  stage       = "dev"
  name        = "app"

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "ApplicationServer"
  }
}
```

### VM with Data Disks Example

```hcl
module "vm_with_disks" {
  source = "../modules/azure-vm"

  location            = "eastus"
  resource_group_name = "my-resource-group"
  os_type             = "Linux"
  vm_size             = "Standard_D4s_v3"
  subnet_id           = azurerm_subnet.example.id

  admin_username                  = "azureadmin"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  # Data Disks
  data_disks = {
    data01 = {
      lun                  = 0
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
      caching              = "ReadWrite"
      create_option        = "Empty"
    }
    data02 = {
      lun                  = 1
      disk_size_gb         = 256
      storage_account_type = "Premium_LRS"
      caching              = "ReadOnly"
      create_option        = "Empty"
    }
  }

  namespace   = "myorg"
  environment = "eus"
  stage       = "prod"
  name        = "database"
}
```

### VM with Public IP and NSG Example

```hcl
module "public_vm" {
  source = "../modules/azure-vm"

  location            = "eastus"
  resource_group_name = "my-resource-group"
  os_type             = "Linux"
  vm_size             = "Standard_B2s"
  subnet_id           = azurerm_subnet.example.id

  # Public IP
  create_public_ip              = true
  public_ip_allocation_method   = "Static"
  public_ip_sku                 = "Standard"

  # Network Security
  network_security_group_id = azurerm_network_security_group.example.id

  # Authentication
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  namespace   = "myorg"
  environment = "eus"
  stage       = "dev"
  name        = "jumpbox"
}
```

### VM with Managed Identity and Encryption Example

```hcl
module "secure_vm" {
  source = "../modules/azure-vm"

  location            = "eastus"
  resource_group_name = "my-resource-group"
  os_type             = "Linux"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = azurerm_subnet.example.id

  # Security Features
  identity_type              = "SystemAssigned"
  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  # Authentication
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  namespace   = "myorg"
  environment = "eus"
  stage       = "prod"
  name        = "secure-app"
}
```

### VM in Availability Zone Example

```hcl
module "zonal_vm" {
  source = "../modules/azure-vm"

  location            = "eastus"
  resource_group_name = "my-resource-group"
  os_type             = "Linux"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = azurerm_subnet.example.id

  # Availability Zone
  zone  = "1"
  zones = ["1"]

  admin_username                  = "azureadmin"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  namespace   = "myorg"
  environment = "eus"
  stage       = "prod"
  name        = "ha-app"
}
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
| azurerm_linux_virtual_machine.this | resource |
| azurerm_windows_virtual_machine.this | resource |
| azurerm_network_interface.this | resource |
| azurerm_public_ip.this | resource |
| azurerm_network_interface_application_security_group_association.this | resource |
| azurerm_network_interface_security_group_association.this | resource |
| azurerm_managed_disk.this | resource |
| azurerm_virtual_machine_data_disk_attachment.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| location | The Azure Region where the Virtual Machine should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Virtual Machine | `string` | n/a | yes |
| os_type | The type of OS for the Virtual Machine. Possible values are Linux and Windows | `string` | n/a | yes |
| vm_size | The size of the Virtual Machine | `string` | `"Standard_D2s_v3"` | no |
| subnet_id | The ID of the Subnet where this Network Interface should be located in | `string` | n/a | yes |
| admin_username | The admin username for the Virtual Machine | `string` | `"azureadmin"` | no |
| admin_password | The admin password for the Virtual Machine | `string` | `null` | no |
| admin_ssh_keys | A list of SSH public keys for Linux VM authentication | `list(string)` | `[]` | no |
| source_image_reference | Source image reference for the Virtual Machine | `object` | Ubuntu 22.04 LTS | no |

See [variables.tf](./variables.tf) for a complete list of available variables.

## Outputs

| Name | Description |
|------|-------------|
| vm_id | The ID of the Virtual Machine |
| vm_name | The name of the Virtual Machine |
| vm_private_ip_address | The primary private IP address of the Virtual Machine |
| vm_public_ip_address | The primary public IP address of the Virtual Machine |
| network_interface_id | The ID of the Network Interface |
| public_ip_id | The ID of the Public IP |
| identity_principal_id | The Principal ID of the System Assigned Managed Identity |

See [outputs.tf](./outputs.tf) for a complete list of available outputs.

## Notes

### Authentication

- **Linux VMs**: By default, password authentication is disabled and SSH keys are required. Set `disable_password_authentication = false` and provide `admin_password` to use password authentication.
- **Windows VMs**: Password authentication is required. Ensure `admin_password` meets Azure complexity requirements.

### Storage

- Default OS disk type is `Premium_LRS` for better performance
- Data disks can be added using the `data_disks` map variable
- Each data disk must have a unique LUN (Logical Unit Number)

### Networking

- Private IP allocation is `Dynamic` by default. Set to `Static` and provide `private_ip_address` for static assignment.
- Public IP is not created by default. Set `create_public_ip = true` to enable.
- Accelerated Networking is disabled by default. Enable for supported VM sizes for better network performance.

### High Availability

- Use `availability_set_id` for Availability Sets (99.95% SLA with 2+ VMs)
- Use `zone` for Availability Zones (99.99% SLA)
- `availability_set_id` and `zone` are mutually exclusive

### Security Best Practices

1. Use Azure Key Vault for storing passwords and SSH private keys
2. Enable encryption at host for sensitive workloads
3. Use managed identities instead of service principals when possible
4. Enable secure boot and vTPM for trusted launch
5. Always use NSGs to restrict network access
6. Disable public IP addresses when not required
7. Use private endpoints for Azure services

## License

This module is maintained as part of the infrastructure platform.
