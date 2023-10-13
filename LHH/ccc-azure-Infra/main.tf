# Generate a random password.
resource "random_password" "this" {

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}


# Create or source the Resource Group.
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group = var.create_resource_group ? azurerm_resource_group.this[0] : data.azurerm_resource_group.this[0]
}

# Manage the network required for the topology.

resource "azurerm_virtual_network" "app-vnet" {
  for_each = var.vnets
  name                = "${var.name_prefix}${each.value.name}"
  address_space       = each.value.address_space
  location               = var.location
  resource_group_name = local.resource_group.name
}

resource "azurerm_subnet" "app-subnets" {

  for_each = var.vnets
  name                 = each.value.subnets.name
  resource_group_name  = local.resource_group.name
  virtual_network_name = azurerm_virtual_network.app-vnet
  address_prefixes     = each.value.address_prefixes
}

# app servers

# create public IP address

resource "azurerm_public_ip" "app-vm-public_ip" {
  name                = "appPublicIP"
  location            = var.location
  resource_group_name = local.resource_group.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "app-nic" {
  name = "app-nic"
  location            = var.location
  resource_group_name = local.resource_group.name

  ip_configuration {
    name                          = "app-nic"
    subnet_id                     = azurerm_subnet.app-subnets.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app-vm-public_ip.id
  }
}

# app vm 

resource "azurerm_virtual_machine" "app-vm" {
  name = "app-vm"
  resource_group_name = local.resource_group.name
  location            = var.location
  vm_size             = "Standard_ds1_v2"
  network_interface_ids = [azurerm_network_interface.app-nic.id]

  storage_image_reference {
   
    publisher = var.custom_image_id
    offer     = var.img_offer
    sku       = var.img_sku
    version   = var.img_version
  }  
 storage_os_disk {
    name              = coalesce(var.os_disk_name, "app-vm-vhd")
    create_option     = "FromImage"
    caching              = "ReadWrite"
    os_type           = "Linux"
  }

delete_os_disk_on_termination    = true
delete_data_disks_on_termination = true

os_profile {
  admin_username      = "appadmin"
  admin_password = coalesce(var.vm_password, random_password.this.result)
  computer_name  = "ccc-app"
  }
 os_profile_linux_config {
    disable_password_authentication = false
  }
}
