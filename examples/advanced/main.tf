# Advanced Virtual WAN Example
# This example shows a comprehensive Virtual WAN configuration with all features enabled

# Configure the Azure Provider
terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-vwan-advanced"
  location = "East US"
}

# Create virtual networks for connection examples
resource "azurerm_virtual_network" "app" {
  name                = "vnet-app"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]

  tags = {
    Environment = "Production"
    Project     = "Virtual-WAN-Advanced"
  }
}

resource "azurerm_virtual_network" "data" {
  name                = "vnet-data"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.2.0.0/16"]

  tags = {
    Environment = "Production"
    Project     = "Virtual-WAN-Advanced"
  }
}

# Use the Virtual WAN module with comprehensive configuration
module "virtual_wan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Virtual WAN and Hub configuration
  virtual_wan_name = "vwan-advanced-example"
  virtual_hub_name = "vhub-eastus"
  virtual_hub_address_prefix = "10.0.0.0/24"
  virtual_hub_sku = "Standard"
  hub_routing_preference = "ExpressRoute"

  # Enable all gateway types
  create_s2s_vpn_gateway     = true
  create_expressroute_gateway = true
  create_p2s_vpn_gateway     = true
  create_hub_route_table     = true
  create_virtual_hub_nsg     = true

  # Site-to-Site VPN configuration
  vpn_gateway_name       = "vpn-gateway-advanced"
  vpn_gateway_scale_unit = 2
  vpn_gateway_routing_preference = "Microsoft Network"

  # Define VPN sites
  vpn_sites = {
    "branch-office-1" = {
      name               = "branch-office-1"
      address_cidrs      = ["192.168.1.0/24"]
      device_model       = "Cisco ASA"
      device_vendor      = "Cisco"
      link_speed_in_mbps = 100
      links = [
        {
          name       = "primary-link"
          ip_address = "203.0.113.1"
          bgp_enabled = false
        }
      ]
    }
    "branch-office-2" = {
      name               = "branch-office-2"
      address_cidrs      = ["192.168.2.0/24"]
      device_model       = "Fortinet FortiGate"
      device_vendor      = "Fortinet"
      link_speed_in_mbps = 50
      links = [
        {
          name       = "primary-link"
          ip_address = "203.0.113.2"
          bgp_enabled = false
        }
      ]
    }
  }

  # Define VPN connections
  vpn_connections = {
    "branch-office-1-conn" = {
      name                      = "branch-office-1-connection"
      vpn_site_key             = "branch-office-1"
      internet_security_enabled = true
      routing_weight            = 1
      shared_key                = "YourSecureSharedKey123!"
      vpn_links = [
        {
          name           = "primary-link"
          bandwidth_mbps = 100
          bgp_enabled    = false
          ipsec_policy = {
            sa_lifetime_seconds     = 3600
            sa_data_size_kilobytes = 102400
            ipsec_encryption        = "AES256"
            ipsec_integrity         = "SHA256"
            ike_encryption          = "AES256"
            ike_integrity           = "SHA256"
            dh_group                = "DHGroup14"
            pfs_group               = "PFS14"
          }
        }
      ]
    }
    "branch-office-2-conn" = {
      name                      = "branch-office-2-connection"
      vpn_site_key             = "branch-office-2"
      internet_security_enabled = true
      routing_weight            = 2
      shared_key                = "YourSecureSharedKey456!"
      vpn_links = [
        {
          name           = "primary-link"
          bandwidth_mbps = 50
          bgp_enabled    = false
          ipsec_policy = {
            sa_lifetime_seconds     = 3600
            sa_data_size_kilobytes = 102400
            ipsec_encryption        = "AES256"
            ipsec_integrity         = "SHA256"
            ike_encryption          = "AES256"
            ike_integrity           = "SHA256"
            dh_group                = "DHGroup14"
            pfs_group               = "PFS14"
          }
        }
      ]
    }
  }

  # ExpressRoute configuration
  expressroute_gateway_name        = "er-gateway-advanced"
  expressroute_gateway_scale_units = 2

  # Note: In a real scenario, you would provide actual ExpressRoute circuit peering IDs
  expressroute_connections = {
    # Example configuration (commented out as it requires actual circuit)
    # "er-primary" = {
    #   name                           = "er-primary-connection"
    #   express_route_circuit_peering_id = "/subscriptions/.../peerings/AzurePrivatePeering"
    #   authorization_key              = "your-auth-key"
    #   routing_weight                 = 1
    #   enable_internet_security       = false
    # }
  }

  # Point-to-Site VPN configuration
  p2s_vpn_gateway_name       = "p2s-vpn-gateway-advanced"
  p2s_vpn_gateway_scale_unit = 1

  vpn_authentication_types = ["Certificate"]
  vpn_protocols           = ["OpenVPN", "IkeV2"]

  # Client root certificates (example - replace with actual certificates)
  client_root_certificates = [
    {
      name             = "root-cert-1"
      public_cert_data = "MIIC5zCCAc+gAwIBAgIQ..." # Replace with actual certificate data
    }
  ]

  p2s_connection_configurations = [
    {
      name = "default-config"
      vpn_client_address_pool = {
        address_prefixes = ["172.16.100.0/24"]
      }
      route = {
        associated_route_table_id = "default"
        propagated_route_table = {
          labels = ["default"]
          route_table_ids = []
        }
      }
    }
  ]

  # Virtual network connections
  virtual_network_connections = {
    "vnet-app-connection" = {
      name                      = "vnet-app-connection"
      remote_virtual_network_id = azurerm_virtual_network.app.id
      internet_security_enabled = true
      routing = {
        associated_route_table_id = "default"
        propagated_route_table = {
          labels = ["default"]
          route_table_ids = []
        }
      }
    }
    "vnet-data-connection" = {
      name                      = "vnet-data-connection"
      remote_virtual_network_id = azurerm_virtual_network.data.id
      internet_security_enabled = true
      routing = {
        associated_route_table_id = "default"
        propagated_route_table = {
          labels = ["default"]
          route_table_ids = []
        }
      }
    }
  }

  # Hub route table configuration
  hub_route_table_name = "vhub-route-table-advanced"
  hub_route_table_labels = ["default", "app", "data"]
  hub_route_table_routes = [
    {
      name                = "route-to-app"
      destinations        = ["10.1.0.0/16"]
      destinations_type   = "CIDR"
      next_hop           = "10.0.0.1"
      next_hop_type      = "IPAddress"
    }
  ]

  # Network Security Group configuration
  virtual_hub_nsg_name = "vhub-nsg-advanced"
  virtual_hub_nsg_rules = [
    {
      name                       = "AllowVPNTraffic"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "500"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowVPNTraffic2"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "4500"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  # Common tags
  common_tags = {
    Environment = "Production"
    Project     = "Virtual-WAN-Advanced"
    CostCenter  = "IT-001"
    Owner       = "Network-Team"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "virtual_wan_id" {
  description = "ID of the created Virtual WAN"
  value       = module.virtual_wan.virtual_wan_id
}

output "virtual_hub_id" {
  description = "ID of the created Virtual Hub"
  value       = module.virtual_wan.virtual_hub_id
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = module.virtual_wan.vpn_gateway_id
}

output "expressroute_gateway_id" {
  description = "ID of the ExpressRoute Gateway"
  value       = module.virtual_wan.expressroute_gateway_id
}

output "p2s_vpn_gateway_id" {
  description = "ID of the Point-to-Site VPN Gateway"
  value       = module.virtual_wan.p2s_vpn_gateway_id
}

output "vpn_site_ids" {
  description = "IDs of created VPN sites"
  value       = module.virtual_wan.vpn_site_ids
}

output "vpn_connection_ids" {
  description = "IDs of created VPN connections"
  value       = module.virtual_wan.vpn_connection_ids
}

output "virtual_network_connection_ids" {
  description = "IDs of created virtual network connections"
  value       = module.virtual_wan.virtual_network_connection_ids
}

output "module_summary" {
  description = "Summary of all created resources"
  value       = module.virtual_wan.module_summary
} 