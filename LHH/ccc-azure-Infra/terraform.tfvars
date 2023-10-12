# --- GENERAL --- #
location              = "Australia Southeast"
resource_group_name   = "app-rg"
name_prefix           = "ccc-"
create_resource_group = true
custom_image_id = "Canonical"
img_offer = "UbuntuServer"
img_sku = "19.04"
img_version = "latest"
tags = {
  "owner"   = "hazadeh@paloaltonetworks.com"
  "CreatedWith" = "Terraform"
}
enable_zones = false


# --- VNET PART --- #
vnets = {
  "vnet" = {
    name          = "app-vnet"
    address_space = ["10.112.0.0/16"]
    network_security_groups = {
      "app" = {
        name = "app-nsg"
        rules = {
          app_allow_inbound = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["*"] 
            source_port_range          = "*"
            destination_address_prefix = "*"
            destination_port_ranges    = ["22", "80"]
          }
        }
      }
    }
    subnets = {
      "app-subnet01" = {
        name                   = "app-subnet01"
        address_prefixes       = ["10.112.0.0/24"]
        network_security_group = "app"
      }
    }
  }
}

