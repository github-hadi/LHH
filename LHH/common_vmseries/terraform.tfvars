# --- GENERAL --- #
location            = "Australia Southeast"
resource_group_name = "transit-rg"
name_prefix         = "ccc-"
tags = {
  "owner"   = "hazadeh@paloaltonetworks.com"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  "transit" = {
    name          = "transit-vnet"
    address_space = ["10.110.0.0/16"]
    network_security_groups = {
      "management" = {
        name = "mgmt-nsg"
        rules = {
          vmseries_mgmt_allow_inbound = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["*"] 
            source_port_range          = "*"
            destination_address_prefix = "10.110.255.0/24"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
    }
    route_tables = {
      "management" = {
        name = "mgmt-rt"
        routes = {
          "private_blackhole" = {
            address_prefix = "10.110.0.0/24"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            address_prefix = "10.110.129.0/24"
            next_hop_type  = "None"
          }
        }
      }
      "private" = {
        name = "private-rt"
        routes = {
          "default" = {
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.110.0.21"
          }
          "mgmt_blackhole" = {
            address_prefix = "10.110.255.0/24"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            address_prefix = "10.110.129.0/24"
            next_hop_type  = "None"
          }
        }
      }
      "public" = {
        name = "public-rt"
        routes = {
          "mgmt_blackhole" = {
            address_prefix = "10.110.255.0/24"
            next_hop_type  = "None"
          }
          "private_blackhole" = {
            address_prefix = "10.110.0.0/24"
            next_hop_type  = "None"
          }
        }
      }
    }
    subnets = {
      "management" = {
        name                            = "mgmt-snet"
        address_prefixes                = ["10.110.255.0/24"]
        network_security_group          = "management"
        route_table                     = "management"
        enable_storage_service_endpoint = true
      }
      "private" = {
        name             = "private-snet"
        address_prefixes = ["10.110.0.0/24"]
        route_table      = "private"
      }
      "public" = {
        name                   = "public-snet"
        address_prefixes       = ["10.110.129.0/24"]
        network_security_group = "public"
        route_table            = "public"
      }
      "appgw" = {
        name             = "appgw-snet"
        address_prefixes = ["10.110.130.0/24"]
      }
    }
  }
}


# --- LOAD BALANCING PART --- #
load_balancers = {
  "public" = {
    name                              = "public-lb"
    nsg_vnet_key                      = "transit"
    nsg_key                           = "public"
    network_security_allow_source_ips = ["0.0.0.0/0"] 
    avzones                           = ["1", "2", "3"]
    frontend_ips = {
      "palo-lb-app1" = {
        create_public_ip = true
        in_rules = {
          "balanceHttp" = {
            protocol = "Tcp"
            port     = 80
          }
        }
      }
    }
  }
  "private" = {
    name    = "private-lb"
    avzones = ["1", "2", "3"]
    frontend_ips = {
      "ha-ports" = {
        vnet_key           = "transit"
        subnet_key         = "private"
        private_ip_address = "10.110.0.21"
        in_rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}

# # --- APPLICATION GATEWAYs --- #
appgws = {
  "public" = {
    name                     = "public-appgw"
    vnet_key                 = "transit"
    subnet_key               = "appgw"
    zones                    = ["1", "2", "3"]
    capacity                 = 2
    vmseries_public_nic_name = "public"
    rules = {
      "minimum" = {
        priority = 1
        listener = {
          port = 80
        }
        rewrite_sets = {
          "xff-strip-port" = {
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
    }
  }
}



# --- VMSERIES PART --- #
vmseries_version = "10.2.3"
vmseries_vm_size = "Standard_DS3_v2"
bootstrap_options = "type=dhcp-client"
vmseries = {
 "fw-1" = {
   name              = "firewall01"
   vnet_key          = "transit"
   avzone            = 1
   interfaces = [
     {
       name       = "mgmt"
       subnet_key = "management"
       create_pip = true
     },
     {
       name              = "private"
       subnet_key        = "private"
       load_balancer_key = "private"
     },
     {
       name              = "public"
       subnet_key        = "public"
       load_balancer_key = "public"
       create_pip        = true
     }
   ]
 }
 "fw-2" = {
   name              = "firewall02"
   vnet_key          = "transit"
   avzone            = 2
   interfaces = [
     {
       name       = "mgmt"
       subnet_key = "management"
       create_pip = true
     },
     {
       name              = "private"
       subnet_key        = "private"
       load_balancer_key = "private"
     },
     {
       name              = "public"
       subnet_key        = "public"
       load_balancer_key = "public"
       create_pip        = true
     }
   ]
 }
}

#vnet peering 

## local_peer_config {
##   vnet_name = "ccc-transit-vnet"
## }
## 
## remote_peer_config {
##   resrouce_group {
##     name = [ "ccc-management-rg","ccc-app-rg" ]
##     vnet_name = ["ccc-management-vnet","ccc-app-vnet"]
##   }
## 
## }
