# Azure Virtual WAN Module Outputs
# This file contains all outputs that can be used by other modules or configurations

# Virtual WAN Outputs
output "virtual_wan_id" {
  description = "ID of the Virtual WAN"
  value       = azurerm_virtual_wan.main.id
}

output "virtual_wan_name" {
  description = "Name of the Virtual WAN"
  value       = azurerm_virtual_wan.main.name
}

output "virtual_wan_guid" {
  description = "GUID of the Virtual WAN"
  value       = azurerm_virtual_wan.main.guid
}

# Virtual Hub Outputs
output "virtual_hub_id" {
  description = "ID of the Virtual Hub"
  value       = azurerm_virtual_hub.main.id
}

output "virtual_hub_name" {
  description = "Name of the Virtual Hub"
  value       = azurerm_virtual_hub.main.name
}

output "virtual_hub_default_route_table_id" {
  description = "ID of the default route table in the Virtual Hub"
  value       = azurerm_virtual_hub.main.default_route_table_id
}

output "virtual_hub_route_table_ids" {
  description = "IDs of all route tables in the Virtual Hub"
  value       = azurerm_virtual_hub.main.route_table_ids
}

# Virtual Hub Route Table Outputs
output "virtual_hub_route_table_id" {
  description = "ID of the Virtual Hub route table"
  value       = var.create_hub_route_table ? azurerm_virtual_hub_route_table.main[0].id : null
}

output "virtual_hub_route_table_name" {
  description = "Name of the Virtual Hub route table"
  value       = var.create_hub_route_table ? azurerm_virtual_hub_route_table.main[0].name : null
}

# Site-to-Site VPN Gateway Outputs
output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.create_s2s_vpn_gateway ? azurerm_vpn_gateway.main[0].id : null
}

output "vpn_gateway_name" {
  description = "Name of the VPN Gateway"
  value       = var.create_s2s_vpn_gateway ? azurerm_vpn_gateway.main[0].name : null
}

output "vpn_gateway_public_ip_addresses" {
  description = "Public IP addresses of the VPN Gateway"
  value       = var.create_s2s_vpn_gateway ? azurerm_vpn_gateway.main[0].public_ip_addresses : []
}

# VPN Sites Outputs
output "vpn_site_ids" {
  description = "Map of VPN site names to their IDs"
  value = {
    for k, v in azurerm_vpn_site.main : k => v.id
  }
}

output "vpn_site_names" {
  description = "List of VPN site names"
  value       = [for site in azurerm_vpn_site.main : site.name]
}

# VPN Connections Outputs
output "vpn_connection_ids" {
  description = "Map of VPN connection names to their IDs"
  value = {
    for k, v in azurerm_vpn_gateway_connection.main : k => v.id
  }
}

output "vpn_connection_names" {
  description = "List of VPN connection names"
  value       = [for conn in azurerm_vpn_gateway_connection.main : conn.name]
}

# ExpressRoute Gateway Outputs
output "expressroute_gateway_id" {
  description = "ID of the ExpressRoute Gateway"
  value       = var.create_expressroute_gateway ? azurerm_express_route_gateway.main[0].id : null
}

output "expressroute_gateway_name" {
  description = "Name of the ExpressRoute Gateway"
  value       = var.create_expressroute_gateway ? azurerm_express_route_gateway.main[0].name : null
}

# ExpressRoute Connections Outputs
output "expressroute_connection_ids" {
  description = "Map of ExpressRoute connection names to their IDs"
  value = {
    for k, v in azurerm_express_route_connection.main : k => v.id
  }
}

output "expressroute_connection_names" {
  description = "List of ExpressRoute connection names"
  value       = [for conn in azurerm_express_route_connection.main : conn.name]
}

# Point-to-Site VPN Gateway Outputs
output "p2s_vpn_gateway_id" {
  description = "ID of the Point-to-Site VPN Gateway"
  value       = var.create_p2s_vpn_gateway ? azurerm_point_to_site_vpn_gateway.main[0].id : null
}

output "p2s_vpn_gateway_name" {
  description = "Name of the Point-to-Site VPN Gateway"
  value       = var.create_p2s_vpn_gateway ? azurerm_point_to_site_vpn_gateway.main[0].name : null
}

output "p2s_vpn_gateway_public_ip_addresses" {
  description = "Public IP addresses of the Point-to-Site VPN Gateway"
  value       = var.create_p2s_vpn_gateway ? azurerm_point_to_site_vpn_gateway.main[0].public_ip_addresses : []
}

# VPN Server Configuration Outputs
output "vpn_server_configuration_id" {
  description = "ID of the VPN server configuration"
  value       = var.create_p2s_vpn_gateway ? azurerm_vpn_server_configuration.main[0].id : null
}

output "vpn_server_configuration_name" {
  description = "Name of the VPN server configuration"
  value       = var.create_p2s_vpn_gateway ? azurerm_vpn_server_configuration.main[0].name : null
}

# Virtual Network Connections Outputs
output "virtual_network_connection_ids" {
  description = "Map of virtual network connection names to their IDs"
  value = {
    for k, v in azurerm_virtual_hub_connection.main : k => v.id
  }
}

output "virtual_network_connection_names" {
  description = "List of virtual network connection names"
  value       = [for conn in azurerm_virtual_hub_connection.main : conn.name]
}

# Network Security Group Outputs
output "virtual_hub_nsg_id" {
  description = "ID of the Network Security Group for Virtual Hub"
  value       = var.create_virtual_hub_nsg ? azurerm_network_security_group.virtual_hub[0].id : null
}

output "virtual_hub_nsg_name" {
  description = "Name of the Network Security Group for Virtual Hub"
  value       = var.create_virtual_hub_nsg ? azurerm_network_security_group.virtual_hub[0].name : null
}

# Route Table Outputs
output "virtual_hub_route_table_id" {
  description = "ID of the route table for Virtual Hub"
  value       = var.create_virtual_hub_route_table ? azurerm_route_table.virtual_hub[0].id : null
}

output "virtual_hub_route_table_name" {
  description = "Name of the route table for Virtual Hub"
  value       = var.create_virtual_hub_route_table ? azurerm_route_table.virtual_hub[0].name : null
}

# Summary Outputs
output "module_summary" {
  description = "Summary of all resources created by this module"
  value = {
    virtual_wan_created                    = true
    virtual_hub_created                    = true
    hub_route_table_created               = var.create_hub_route_table
    s2s_vpn_gateway_created               = var.create_s2s_vpn_gateway
    vpn_sites_count                       = length(var.vpn_sites)
    vpn_connections_count                 = length(var.vpn_connections)
    expressroute_gateway_created          = var.create_expressroute_gateway
    expressroute_connections_count        = length(var.expressroute_connections)
    p2s_vpn_gateway_created               = var.create_p2s_vpn_gateway
    virtual_network_connections_count     = length(var.virtual_network_connections)
    virtual_hub_nsg_created               = var.create_virtual_hub_nsg
    virtual_hub_route_table_created       = var.create_virtual_hub_route_table
    location                              = var.location
    resource_group_name                   = var.resource_group_name
  }
}

# Connection Status Outputs
output "vpn_connection_status" {
  description = "Status of VPN connections"
  value = {
    for k, v in azurerm_vpn_gateway_connection.main : k => {
      name   = v.name
      status = v.connection_status
    }
  }
}

output "expressroute_connection_status" {
  description = "Status of ExpressRoute connections"
  value = {
    for k, v in azurerm_express_route_connection.main : k => {
      name   = v.name
      status = v.routing_configuration[0].propagated_route_tables[0].labels
    }
  }
}

# Resource Group and Location (for reference)
output "resource_group_name" {
  description = "Resource group name where resources are created"
  value       = var.resource_group_name
}

output "location" {
  description = "Azure region where resources are created"
  value       = var.location
} 