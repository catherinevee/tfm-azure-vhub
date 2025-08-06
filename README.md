# Azure Virtual WAN Terraform Module

This Terraform module creates an Azure Virtual WAN architecture with support for:

- **Virtual WAN Hub**: Central hub for network connectivity
- **Site-to-Site VPN connections**: Secure connections to on-premises networks
- **ExpressRoute connections**: Private, high-bandwidth connections
- **Point-to-Site VPN**: Remote user access to Azure resources
- **Virtual network connections**: Spoke network connectivity
- **Network Security Groups**: Security controls for the Virtual Hub
- **Route Tables**: Custom routing configurations

## Features

- **Modular Design**: Reusable components for different deployment scenarios
- **Configurable**: Extensive customization options for all resources
- **Security Focused**: Built-in security controls and best practices
- **Comprehensive Outputs**: Detailed outputs for integration with other modules
- **Tagging Support**: Consistent resource tagging for cost management
- **Validation**: Input validation to prevent configuration errors
- **Resource Map**: Documentation of all created resources

## Documentation

- [**Resource Map**](RESOURCE_MAP.md) - Overview of all Azure resources, relationships, and dependencies
- [**Examples**](examples/) - Working examples for different deployment scenarios
- [**Tests**](tests/) - Test suite for module validation
- [**Contributing**](CONTRIBUTING.md) - Guidelines for contributing to the module
- [**Changelog**](CHANGELOG.md) - Version history and changes

## Architecture Overview

```
                    ┌─────────────────┐
                    │   Virtual WAN   │
                    │      Hub        │
                    └─────────┬───────┘
                              │
        ┌─────────────┬───────┼───────┬─────────────┐
        │             │       │       │             │
    ┌───▼───┐    ┌───▼───┐ ┌─▼─┐ ┌───▼───┐    ┌───▼───┐
    │ S2S   │    │ P2S   │ │ER │ │ VNet  │    │ Route │
    │ VPN   │    │ VPN   │ │GW │ │Conn.  │    │Table  │
    └───────┘    └───────┘ └───┘ └───────┘    └───────┘
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| azurerm | ~> 4.38.1 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.38.1 |

## Inputs

### Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group where resources will be created | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |

### Virtual WAN Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| virtual_wan_name | Name of the Virtual WAN resource | `string` | `"vwan-main"` | no |
| virtual_wan_type | Type of Virtual WAN (Standard or Basic) | `string` | `"Standard"` | no |
| disable_vpn_encryption | Disable VPN encryption for Virtual WAN | `bool` | `false` | no |
| allow_branch_to_branch_traffic | Allow branch to branch traffic through Virtual WAN | `bool` | `true` | no |
| office365_local_breakout_category | Office365 local breakout category | `string` | `"None"` | no |

### Virtual Hub Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| virtual_hub_name | Name of the Virtual Hub | `string` | `"vhub-main"` | no |
| virtual_hub_address_prefix | Address prefix for the Virtual Hub (CIDR notation) | `string` | `"10.0.0.0/24"` | no |
| virtual_hub_sku | SKU for the Virtual Hub | `string` | `"Standard"` | no |
| hub_routing_preference | Hub routing preference | `string` | `"ExpressRoute"` | no |

### Site-to-Site VPN Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_s2s_vpn_gateway | Whether to create a Site-to-Site VPN Gateway | `bool` | `false` | no |
| vpn_gateway_name | Name of the VPN Gateway | `string` | `"vpn-gateway"` | no |
| vpn_gateway_scale_unit | Scale unit for VPN Gateway (1-80) | `number` | `1` | no |
| vpn_sites | Map of VPN sites to create | `map(object)` | `{}` | no |
| vpn_connections | Map of VPN connections to create | `map(object)` | `{}` | no |

### ExpressRoute Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_expressroute_gateway | Whether to create an ExpressRoute Gateway | `bool` | `false` | no |
| expressroute_gateway_name | Name of the ExpressRoute Gateway | `string` | `"er-gateway"` | no |
| expressroute_gateway_scale_units | Scale units for ExpressRoute Gateway (1-10) | `number` | `1` | no |
| expressroute_connections | Map of ExpressRoute connections to create | `map(object)` | `{}` | no |

### Point-to-Site VPN Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_p2s_vpn_gateway | Whether to create a Point-to-Site VPN Gateway | `bool` | `false` | no |
| p2s_vpn_gateway_name | Name of the Point-to-Site VPN Gateway | `string` | `"p2s-vpn-gateway"` | no |
| p2s_vpn_gateway_scale_unit | Scale unit for Point-to-Site VPN Gateway (1-80) | `number` | `1` | no |
| vpn_authentication_types | List of VPN authentication types | `list(string)` | `["Certificate"]` | no |
| vpn_protocols | List of VPN protocols | `list(string)` | `["OpenVPN"]` | no |

### Virtual Network Connections

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| virtual_network_connections | Map of virtual network connections to create | `map(object)` | `{}` | no |

### Security Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_virtual_hub_nsg | Whether to create a Network Security Group for the Virtual Hub | `bool` | `false` | no |
| virtual_hub_nsg_rules | List of security rules for the Virtual Hub NSG | `list(object)` | `[]` | no |

### Common Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| common_tags | Common tags to apply to all resources | `map(string)` | `{"Environment" = "Production", "Project" = "Virtual-WAN", "ManagedBy" = "Terraform"}` | no |

## Outputs

| Name | Description |
|------|-------------|
| virtual_wan_id | ID of the Virtual WAN |
| virtual_hub_id | ID of the Virtual Hub |
| vpn_gateway_id | ID of the VPN Gateway |
| expressroute_gateway_id | ID of the ExpressRoute Gateway |
| p2s_vpn_gateway_id | ID of the Point-to-Site VPN Gateway |
| module_summary | Summary of all resources created by this module |

## Usage Examples

### Basic Virtual WAN with Hub Only

```hcl
module "virtual_wan" {
  source = "./tfm-azure-vhub"

  resource_group_name = "rg-network-prod"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"
}
```

### Virtual WAN with Site-to-Site VPN

```hcl
module "virtual_wan" {
  source = "./tfm-azure-vhub"

  resource_group_name = "rg-network-prod"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"

  # Enable Site-to-Site VPN
  create_s2s_vpn_gateway = true
  vpn_gateway_name       = "vpn-gateway-prod"
  vpn_gateway_scale_unit = 2

  # Define VPN sites
  vpn_sites = {
    "branch-office-1" = {
      name               = "branch-office-1"
      address_cidrs      = ["192.168.1.0/24"]
      device_model       = "Generic"
      device_vendor      = "Generic"
      link_speed_in_mbps = 100
      links = [
        {
          name       = "primary-link"
          ip_address = "203.0.113.1"
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
      shared_key                = "your-shared-key-here"
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
  }
}
```

### Virtual WAN with ExpressRoute

```hcl
module "virtual_wan" {
  source = "./tfm-azure-vhub"

  resource_group_name = "rg-network-prod"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"

  # Enable ExpressRoute Gateway
  create_expressroute_gateway = true
  expressroute_gateway_name   = "er-gateway-prod"
  expressroute_gateway_scale_units = 2

  # Define ExpressRoute connections
  expressroute_connections = {
    "er-connection-1" = {
      name                           = "er-connection-1"
      express_route_circuit_peering_id = "/subscriptions/.../peerings/AzurePrivatePeering"
      authorization_key              = "your-auth-key"
      routing_weight                 = 1
      enable_internet_security       = false
    }
  }
}
```

### Virtual WAN with Point-to-Site VPN

```hcl
module "virtual_wan" {
  source = "./tfm-azure-vhub"

  resource_group_name = "rg-network-prod"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"

  # Enable Point-to-Site VPN
  create_p2s_vpn_gateway = true
  p2s_vpn_gateway_name   = "p2s-vpn-gateway"
  p2s_vpn_gateway_scale_unit = 1

  # VPN authentication configuration
  vpn_authentication_types = ["Certificate"]
  vpn_protocols           = ["OpenVPN"]

  # Client certificates
  client_root_certificates = [
    {
      name             = "root-cert-1"
      public_cert_data = "MIIC5zCCAc+gAwIBAgIQ..." # Your certificate data
    }
  ]

  # Connection configuration
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
}
```

### Virtual WAN with Virtual Network Connections

```hcl
module "virtual_wan" {
  source = "./tfm-azure-vhub"

  resource_group_name = "rg-network-prod"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"

  # Connect virtual networks
  virtual_network_connections = {
    "vnet-app-connection" = {
      name                      = "vnet-app-connection"
      remote_virtual_network_id = "/subscriptions/.../virtualNetworks/vnet-app"
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
}
```

### Complete Enterprise Virtual WAN

```hcl
module "virtual_wan" {
  source = "./tfm-azure-vhub"

  resource_group_name = "rg-network-prod"
  location            = "East US"

  # Virtual WAN and Hub
  virtual_wan_name = "vwan-enterprise"
  virtual_hub_name = "vhub-eastus"
  virtual_hub_address_prefix = "10.0.0.0/24"

  # Enable all gateway types
  create_s2s_vpn_gateway     = true
  create_expressroute_gateway = true
  create_p2s_vpn_gateway     = true

  # Site-to-Site VPN configuration
  vpn_gateway_name       = "vpn-gateway-enterprise"
  vpn_gateway_scale_unit = 3

  vpn_sites = {
    "hq-office" = {
      name               = "hq-office"
      address_cidrs      = ["192.168.10.0/24"]
      device_model       = "Cisco ASA"
      device_vendor      = "Cisco"
      link_speed_in_mbps = 1000
      links = [
        {
          name       = "primary-link"
          ip_address = "203.0.113.10"
          bgp_enabled = true
          asn        = 65001
          bgp_peering_address = "192.168.10.1"
        }
      ]
    }
  }

  vpn_connections = {
    "hq-office-conn" = {
      name                      = "hq-office-connection"
      vpn_site_key             = "hq-office"
      internet_security_enabled = true
      routing_weight            = 1
      shared_key                = var.vpn_shared_key
      vpn_links = [
        {
          name           = "primary-link"
          bandwidth_mbps = 1000
          bgp_enabled    = true
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
  expressroute_gateway_name        = "er-gateway-enterprise"
  expressroute_gateway_scale_units = 3

  expressroute_connections = {
    "er-primary" = {
      name                           = "er-primary-connection"
      express_route_circuit_peering_id = var.expressroute_circuit_peering_id
      authorization_key              = var.expressroute_auth_key
      routing_weight                 = 1
      enable_internet_security       = false
    }
  }

  # Point-to-Site VPN configuration
  p2s_vpn_gateway_name       = "p2s-vpn-gateway-enterprise"
  p2s_vpn_gateway_scale_unit = 2

  vpn_authentication_types = ["Certificate", "AAD"]
  vpn_protocols           = ["OpenVPN", "IkeV2"]

  azure_ad_authentication = [
    {
      audience = "https://login.microsoftonline.com/your-tenant-id"
      issuer   = "https://sts.windows.net/your-tenant-id/"
      tenant   = "your-tenant-id"
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
    "vnet-app" = {
      name                      = "vnet-app-connection"
      remote_virtual_network_id = var.vnet_app_id
      internet_security_enabled = true
      routing = {
        associated_route_table_id = "default"
        propagated_route_table = {
          labels = ["default"]
          route_table_ids = []
        }
      }
    }
    "vnet-data" = {
      name                      = "vnet-data-connection"
      remote_virtual_network_id = var.vnet_data_id
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

  # Security configuration
  create_virtual_hub_nsg = true
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
    }
  ]

  # Custom tags
  common_tags = {
    Environment = "Production"
    Project     = "Enterprise-Network"
    CostCenter  = "IT-001"
    Owner       = "Network-Team"
  }
}
```

## Best Practices

### Security
- Enable internet security for VPN connections when possible
- Use strong authentication methods for Point-to-Site VPN
- Implement Network Security Groups for additional security controls
- Store sensitive information like shared keys in Azure Key Vault

### Performance
- Choose appropriate scale units based on expected traffic
- Use ExpressRoute for high-bandwidth, low-latency requirements
- Consider regional placement for optimal performance

### Cost Optimization
- Use Basic SKU for development/test environments
- Monitor bandwidth usage and adjust scale units accordingly
- Implement proper tagging for cost allocation

### Monitoring
- Enable diagnostic settings for all gateways
- Set up alerts for connection status changes
- Monitor bandwidth utilization

## Troubleshooting

### Common Issues

1. **VPN Connection Failing**
   - Verify shared keys match on both sides
   - Check IPsec policy compatibility
   - Ensure firewall rules allow VPN traffic

2. **ExpressRoute Connection Issues**
   - Verify circuit peering is configured correctly
   - Check authorization key validity
   - Ensure BGP configuration is correct

3. **Point-to-Site VPN Client Issues**
   - Verify certificate validity and installation
   - Check client address pool configuration
   - Ensure proper route propagation

### Debugging Commands

```bash
# Check Virtual WAN status
az network vwan show --name vwan-name --resource-group rg-name

# Check VPN Gateway status
az network vpn-gateway show --name vpn-gateway-name --resource-group rg-name

# Check ExpressRoute Gateway status
az network express-route gateway show --name er-gateway-name --resource-group rg-name
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Azure documentation
3. Open an issue in the repository

## Changelog

### Version 1.0.0
- Initial release
- Support for Virtual WAN, Hub, and all gateway types
- Comprehensive variable validation
- Security and monitoring features