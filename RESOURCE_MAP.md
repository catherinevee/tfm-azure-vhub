# Azure Virtual WAN Module - Resource Map

This document provides a comprehensive overview of all Azure resources created by the `tfm-azure-vhub` Terraform module, their relationships, and dependencies.

## Resource Overview

The module creates a complete Azure Virtual WAN architecture with the following resource types:

| Resource Type | Azure Resource | Purpose | Conditional |
|---------------|----------------|---------|-------------|
| **Core Infrastructure** | | | |
| `azurerm_virtual_wan` | Virtual WAN | Central hub for network connectivity | Always |
| `azurerm_virtual_hub` | Virtual Hub | Regional hub for network services | Always |
| **Routing** | | | |
| `azurerm_virtual_hub_route_table` | Hub Route Table | Custom routing within the hub | Optional |
| `azurerm_route_table` | Route Table | Custom routing for virtual networks | Optional |
| **VPN Connectivity** | | | |
| `azurerm_vpn_gateway` | Site-to-Site VPN Gateway | On-premises connectivity | Optional |
| `azurerm_vpn_site` | VPN Site | Remote site definitions | Optional |
| `azurerm_vpn_gateway_connection` | VPN Connection | Site-to-site connections | Optional |
| `azurerm_point_to_site_vpn_gateway` | Point-to-Site VPN Gateway | Remote user access | Optional |
| `azurerm_vpn_server_configuration` | VPN Server Configuration | P2S authentication settings | Optional |
| **ExpressRoute** | | | |
| `azurerm_express_route_gateway` | ExpressRoute Gateway | Private connectivity | Optional |
| `azurerm_express_route_connection` | ExpressRoute Connection | Circuit connections | Optional |
| **Network Security** | | | |
| `azurerm_network_security_group` | Network Security Group | Security rules for hub | Optional |
| **Virtual Network Integration** | | | |
| `azurerm_virtual_hub_connection` | Virtual Hub Connection | Spoke network connectivity | Optional |

## Resource Dependencies

```
azurerm_virtual_wan
    └── azurerm_virtual_hub
        ├── azurerm_virtual_hub_route_table (optional)
        ├── azurerm_vpn_gateway (optional)
        │   ├── azurerm_vpn_site (optional)
        │   └── azurerm_vpn_gateway_connection (optional)
        ├── azurerm_express_route_gateway (optional)
        │   └── azurerm_express_route_connection (optional)
        ├── azurerm_point_to_site_vpn_gateway (optional)
        │   └── azurerm_vpn_server_configuration (optional)
        ├── azurerm_virtual_hub_connection (optional)
        ├── azurerm_network_security_group (optional)
        └── azurerm_route_table (optional)
```

## Detailed Resource Descriptions

### Core Infrastructure

#### azurerm_virtual_wan
- **Purpose**: Central hub for network connectivity across Azure regions
- **Dependencies**: None (root resource)
- **Key Attributes**:
  - `name`: Virtual WAN name
  - `type`: Standard or Basic
  - `disable_vpn_encryption`: VPN encryption settings
  - `allow_branch_to_branch_traffic`: Inter-branch connectivity

#### azurerm_virtual_hub
- **Purpose**: Regional hub for network services and connectivity
- **Dependencies**: `azurerm_virtual_wan`
- **Key Attributes**:
  - `address_prefix`: Hub address space (CIDR)
  - `sku`: Basic or Standard
  - `hub_routing_preference`: Routing preference
  - `virtual_wan_id`: Reference to Virtual WAN

### VPN Connectivity

#### azurerm_vpn_gateway
- **Purpose**: Site-to-site VPN connectivity to on-premises networks
- **Dependencies**: `azurerm_virtual_hub`
- **Key Attributes**:
  - `scale_unit`: Gateway capacity (1-80)
  - `routing_preference`: Microsoft or Internet routing

#### azurerm_vpn_site
- **Purpose**: Definition of remote VPN sites
- **Dependencies**: `azurerm_virtual_wan`
- **Key Attributes**:
  - `address_cidrs`: Remote site address ranges
  - `device_model`: VPN device model
  - `device_vendor`: VPN device vendor

#### azurerm_vpn_gateway_connection
- **Purpose**: Active VPN connections to remote sites
- **Dependencies**: `azurerm_vpn_gateway`, `azurerm_vpn_site`
- **Key Attributes**:
  - `vpn_site_id`: Reference to VPN site
  - `routing_weight`: Connection priority

#### azurerm_point_to_site_vpn_gateway
- **Purpose**: Remote user VPN access
- **Dependencies**: `azurerm_virtual_hub`
- **Key Attributes**:
  - `scale_unit`: Gateway capacity
  - `vpn_server_configuration_id`: Authentication settings

#### azurerm_vpn_server_configuration
- **Purpose**: Authentication configuration for P2S VPN
- **Dependencies**: None (standalone)
- **Key Attributes**:
  - `vpn_authentication_types`: Authentication methods
  - `vpn_protocols`: Supported protocols

### ExpressRoute Connectivity

#### azurerm_express_route_gateway
- **Purpose**: Private connectivity via ExpressRoute circuits
- **Dependencies**: `azurerm_virtual_hub`
- **Key Attributes**:
  - `scale_units`: Gateway capacity (1-10)

#### azurerm_express_route_connection
- **Purpose**: Connection to ExpressRoute circuits
- **Dependencies**: `azurerm_express_route_gateway`
- **Key Attributes**:
  - `express_route_circuit_id`: Circuit reference
  - `routing_weight`: Connection priority

### Routing

#### azurerm_virtual_hub_route_table
- **Purpose**: Custom routing within the Virtual Hub
- **Dependencies**: `azurerm_virtual_hub`
- **Key Attributes**:
  - `labels`: Route table labels
  - `routes`: Custom route definitions

#### azurerm_route_table
- **Purpose**: Custom routing for virtual networks
- **Dependencies**: None (standalone)
- **Key Attributes**:
  - `disable_bgp_route_propagation`: BGP settings
  - `routes`: Custom route definitions

### Network Security

#### azurerm_network_security_group
- **Purpose**: Security rules for Virtual Hub traffic
- **Dependencies**: None (standalone)
- **Key Attributes**:
  - `security_rules`: Inbound/outbound rules
  - `location`: NSG location

### Virtual Network Integration

#### azurerm_virtual_hub_connection
- **Purpose**: Connect spoke virtual networks to the hub
- **Dependencies**: `azurerm_virtual_hub`
- **Key Attributes**:
  - `remote_virtual_network_id`: Spoke VNet reference
  - `internet_security_enabled`: Internet security
  - `routing`: Route table associations

## Conditional Resource Creation

The module uses several boolean variables to conditionally create resources:

| Variable | Resources Created When True |
|----------|----------------------------|
| `create_hub_route_table` | `azurerm_virtual_hub_route_table` |
| `create_s2s_vpn_gateway` | `azurerm_vpn_gateway` |
| `create_expressroute_gateway` | `azurerm_express_route_gateway` |
| `create_p2s_vpn_gateway` | `azurerm_point_to_site_vpn_gateway`, `azurerm_vpn_server_configuration` |
| `create_virtual_hub_nsg` | `azurerm_network_security_group` |
| `create_virtual_hub_route_table` | `azurerm_route_table` |

## Resource Naming Convention

All resources follow a consistent naming pattern:
- Virtual WAN: `{virtual_wan_name}`
- Virtual Hub: `{virtual_hub_name}`
- VPN Gateway: `{vpn_gateway_name}`
- ExpressRoute Gateway: `{expressroute_gateway_name}`
- P2S VPN Gateway: `{p2s_vpn_gateway_name}`
- NSG: `{virtual_hub_nsg_name}`
- Route Table: `{virtual_hub_route_table_name}`

## Tagging Strategy

All resources are tagged with:
- `Module`: "azure-virtual-wan"
- `Component`: Specific component name
- `Environment`: From `common_tags`
- `Project`: From `common_tags`
- `ManagedBy`: "Terraform"

## Cost Considerations

**Always Created Resources** (Base Cost):
- Virtual WAN: ~$0.50/hour
- Virtual Hub: ~$0.30/hour

**Optional Resources** (Additional Cost):
- VPN Gateway: $0.50/hour + data transfer
- ExpressRoute Gateway: $0.50/hour + circuit costs
- P2S VPN Gateway: $0.50/hour + data transfer

## Security Considerations

1. **Network Security Groups**: Optional but recommended for production
2. **VPN Encryption**: Enabled by default, can be disabled if needed
3. **Authentication**: Supports multiple authentication types for P2S VPN
4. **Routing**: Custom routing tables for traffic control
5. **Access Control**: All resources support Azure RBAC

## Monitoring and Logging

Key resources that support monitoring:
- Virtual WAN: Azure Monitor integration
- VPN Gateway: Connection monitoring and diagnostics
- ExpressRoute Gateway: Circuit monitoring
- Network Security Groups: Flow logs and security analytics

## Backup and Recovery

- Virtual WAN configuration is stored in Terraform state
- VPN configurations can be exported/imported
- ExpressRoute circuits require separate backup strategies
- Consider using Terraform Cloud or similar for state management

## Compliance and Governance

- All resources support Azure Policy
- Tagging strategy enables cost allocation
- Resource locks can be applied for production environments
- Audit logs available for all resources 