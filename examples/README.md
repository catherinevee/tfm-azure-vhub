# Azure Virtual WAN Module Examples

This directory contains practical examples of how to use the Azure Virtual WAN Terraform module.

## Examples Overview

### Basic Example (`basic/`)
A minimal configuration that creates a Virtual WAN with just a hub. This is perfect for:
- Getting started with Virtual WAN
- Testing the module
- Simple hub-and-spoke architectures

**Features:**
- Virtual WAN resource
- Virtual Hub
- Basic tagging

### Advanced Example (`advanced/`)
A comprehensive configuration that demonstrates all module features. This is ideal for:
- Production deployments
- Enterprise architectures
- Learning all available options

**Features:**
- All gateway types (S2S VPN, ExpressRoute, P2S VPN)
- Multiple VPN sites and connections
- Virtual network connections
- Network Security Groups
- Custom route tables
- Advanced security configurations

## Getting Started

### Prerequisites

1. **Azure CLI**: Install and authenticate with Azure
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Terraform**: Install Terraform (version >= 1.0)
   ```bash
   # Download from https://www.terraform.io/downloads.html
   # or use package manager
   ```

3. **Azure Provider**: The module uses the Azure provider (~> 3.0)

### Running the Basic Example

1. Navigate to the basic example directory:
   ```bash
   cd examples/basic
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

### Running the Advanced Example

1. Navigate to the advanced example directory:
   ```bash
   cd examples/advanced
   ```

2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your specific values:
   ```bash
   # Edit the file with your actual values
   nano terraform.tfvars
   ```

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the plan:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Examples

### Basic Virtual WAN

```hcl
module "virtual_wan" {
  source = "../../"

  resource_group_name = "rg-network"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"
}
```

### Virtual WAN with Site-to-Site VPN

```hcl
module "virtual_wan" {
  source = "../../"

  resource_group_name = "rg-network"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"

  create_s2s_vpn_gateway = true
  vpn_gateway_name       = "vpn-gateway"
  vpn_gateway_scale_unit = 2

  vpn_sites = {
    "branch-office" = {
      name               = "branch-office"
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

  vpn_connections = {
    "branch-office-conn" = {
      name                      = "branch-office-connection"
      vpn_site_key             = "branch-office"
      internet_security_enabled = true
      routing_weight            = 1
      shared_key                = "YourSecureKey123!"
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

### Virtual WAN with Point-to-Site VPN

```hcl
module "virtual_wan" {
  source = "../../"

  resource_group_name = "rg-network"
  location            = "East US"

  virtual_wan_name = "vwan-production"
  virtual_hub_name = "vhub-eastus"

  create_p2s_vpn_gateway = true
  p2s_vpn_gateway_name   = "p2s-vpn-gateway"
  p2s_vpn_gateway_scale_unit = 1

  vpn_authentication_types = ["Certificate"]
  vpn_protocols           = ["OpenVPN"]

  client_root_certificates = [
    {
      name             = "root-cert-1"
      public_cert_data = "MIIC5zCCAc+gAwIBAgIQ..." # Your certificate data
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
}
```

## Security Considerations

### VPN Shared Keys
- Use strong, unique shared keys for each VPN connection
- Store keys securely (consider using Azure Key Vault)
- Rotate keys regularly

### Certificates
- Use valid, trusted certificates for P2S VPN
- Keep certificates up to date
- Implement proper certificate management

### Network Security Groups
- Configure appropriate NSG rules
- Follow the principle of least privilege
- Regularly review and update security rules

## Cost Optimization

### Development/Testing
- Use Basic SKU for Virtual Hub
- Use minimal scale units for gateways
- Consider using Basic Virtual WAN type

### Production
- Use Standard SKU for better performance
- Scale gateways based on actual usage
- Monitor bandwidth and adjust accordingly

## Troubleshooting

### Common Issues

1. **VPN Connection Failing**
   - Verify shared keys match
   - Check IPsec policy compatibility
   - Ensure firewall allows VPN traffic

2. **P2S VPN Client Issues**
   - Verify certificate installation
   - Check client address pool configuration
   - Ensure proper route propagation

3. **ExpressRoute Issues**
   - Verify circuit peering configuration
   - Check authorization key validity
   - Ensure BGP configuration is correct

### Useful Commands

```bash
# Check Virtual WAN status
az network vwan show --name vwan-name --resource-group rg-name

# Check VPN Gateway status
az network vpn-gateway show --name vpn-gateway-name --resource-group rg-name

# Check ExpressRoute Gateway status
az network express-route gateway show --name er-gateway-name --resource-group rg-name

# Check Virtual Hub status
az network vhub show --name vhub-name --resource-group rg-name
```

## Cleanup

To destroy the resources created by the examples:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources created by the example. Make sure you have backups of any important data.

## Next Steps

After running the examples:

1. **Customize**: Modify the configurations to match your requirements
2. **Integrate**: Use the module outputs to connect with other resources
3. **Scale**: Add more VPN sites, connections, or virtual networks
4. **Monitor**: Set up monitoring and alerting for your Virtual WAN
5. **Document**: Document your specific configuration for your team

## Support

For issues with the examples:
1. Check the main module README
2. Review Azure Virtual WAN documentation
3. Open an issue in the repository 