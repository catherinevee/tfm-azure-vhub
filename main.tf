# Azure Virtual WAN Module
# This module creates a comprehensive Virtual WAN architecture including:
# - Virtual WAN hub
# - Site-to-site VPN connections
# - ExpressRoute connections
# - Point-to-site VPN
# - Virtual network connections

# Virtual WAN Resource
resource "azurerm_virtual_wan" "main" {
  name                = var.virtual_wan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  disable_vpn_encryption = var.disable_vpn_encryption
  allow_branch_to_branch_traffic = var.allow_branch_to_branch_traffic
  office365_local_breakout_category = var.office365_local_breakout_category
  type                = var.virtual_wan_type

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "virtual-wan"
  })
}

# Virtual WAN Hub
resource "azurerm_virtual_hub" "main" {
  name                = var.virtual_hub_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_prefix      = var.virtual_hub_address_prefix
  virtual_wan_id      = azurerm_virtual_wan.main.id
  hub_routing_preference = var.hub_routing_preference
  sku                 = var.virtual_hub_sku

  dynamic "route" {
    for_each = var.virtual_hub_routes
    content {
      address_prefixes    = route.value.address_prefixes
      next_hop_ip_address = route.value.next_hop_ip_address
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "virtual-hub"
  })
}

# Virtual Hub Route Table
resource "azurerm_virtual_hub_route_table" "main" {
  count          = var.create_hub_route_table ? 1 : 0
  name           = var.hub_route_table_name
  virtual_hub_id = azurerm_virtual_hub.main.id
  labels         = var.hub_route_table_labels

  dynamic "route" {
    for_each = var.hub_route_table_routes
    content {
      name                = route.value.name
      destinations        = route.value.destinations
      destinations_type   = route.value.destinations_type
      next_hop           = route.value.next_hop
      next_hop_type      = route.value.next_hop_type
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "hub-route-table"
  })
}

# Site-to-Site VPN Gateway
resource "azurerm_vpn_gateway" "main" {
  count               = var.create_s2s_vpn_gateway ? 1 : 0
  name                = var.vpn_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_hub_id      = azurerm_virtual_hub.main.id
  routing_preference  = var.vpn_gateway_routing_preference
  scale_unit          = var.vpn_gateway_scale_unit

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "vpn-gateway"
  })
}

# VPN Site for Site-to-Site connections
resource "azurerm_vpn_site" "main" {
  for_each            = var.vpn_sites
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_cidrs       = each.value.address_cidrs
  device_model        = each.value.device_model
  device_vendor       = each.value.device_vendor
  link_speed_in_mbps  = each.value.link_speed_in_mbps

  dynamic "link" {
    for_each = each.value.links
    content {
      name                = link.value.name
      ip_address          = link.value.ip_address
      fqdn                = link.value.fqdn
      bgp_enabled         = link.value.bgp_enabled
      asn                 = link.value.asn
      bgp_peering_address = link.value.bgp_peering_address
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "vpn-site"
    "SiteName" = each.value.name
  })
}

# VPN Connection for Site-to-Site
resource "azurerm_vpn_gateway_connection" "main" {
  for_each            = var.vpn_connections
  name                = each.value.name
  vpn_gateway_id      = azurerm_vpn_gateway.main[0].id
  remote_vpn_site_id  = azurerm_vpn_site.main[each.value.vpn_site_key].id
  internet_security_enabled = each.value.internet_security_enabled
  routing_weight      = each.value.routing_weight
  shared_key          = each.value.shared_key

  dynamic "vpn_link" {
    for_each = each.value.vpn_links
    content {
      name             = vpn_link.value.name
      vpn_site_link_id = azurerm_vpn_site.main[each.value.vpn_site_key].link[0].id
      bandwidth_mbps   = vpn_link.value.bandwidth_mbps
      bgp_enabled      = vpn_link.value.bgp_enabled
      ipsec_policy {
        sa_lifetime_seconds   = vpn_link.value.ipsec_policy.sa_lifetime_seconds
        sa_data_size_kilobytes = vpn_link.value.ipsec_policy.sa_data_size_kilobytes
        ipsec_encryption      = vpn_link.value.ipsec_policy.ipsec_encryption
        ipsec_integrity       = vpn_link.value.ipsec_policy.ipsec_integrity
        ike_encryption        = vpn_link.value.ipsec_policy.ike_encryption
        ike_integrity         = vpn_link.value.ipsec_policy.ike_integrity
        dh_group              = vpn_link.value.ipsec_policy.dh_group
        pfs_group             = vpn_link.value.ipsec_policy.pfs_group
      }
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "vpn-connection"
    "ConnectionName" = each.value.name
  })
}

# ExpressRoute Gateway
resource "azurerm_express_route_gateway" "main" {
  count               = var.create_expressroute_gateway ? 1 : 0
  name                = var.expressroute_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_hub_id      = azurerm_virtual_hub.main.id
  scale_units         = var.expressroute_gateway_scale_units

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "expressroute-gateway"
  })
}

# ExpressRoute Circuit Connection
resource "azurerm_express_route_connection" "main" {
  for_each                    = var.expressroute_connections
  name                        = each.value.name
  express_route_gateway_id    = azurerm_express_route_gateway.main[0].id
  express_route_circuit_peering_id = each.value.express_route_circuit_peering_id
  authorization_key           = each.value.authorization_key
  routing_weight              = each.value.routing_weight
  enable_internet_security    = each.value.enable_internet_security

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "expressroute-connection"
    "ConnectionName" = each.value.name
  })
}

# Point-to-Site VPN Gateway
resource "azurerm_point_to_site_vpn_gateway" "main" {
  count               = var.create_p2s_vpn_gateway ? 1 : 0
  name                = var.p2s_vpn_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_hub_id      = azurerm_virtual_hub.main.id
  vpn_server_configuration_id = var.p2s_vpn_server_configuration_id
  scale_unit          = var.p2s_vpn_gateway_scale_unit

  dynamic "connection_configuration" {
    for_each = var.p2s_connection_configurations
    content {
      name = connection_configuration.value.name
      vpn_client_address_pool {
        address_prefixes = connection_configuration.value.vpn_client_address_pool.address_prefixes
      }
      route {
        associated_route_table_id = connection_configuration.value.route.associated_route_table_id
        propagated_route_table {
          labels = connection_configuration.value.route.propagated_route_table.labels
          route_table_ids = connection_configuration.value.route.propagated_route_table.route_table_ids
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "p2s-vpn-gateway"
  })
}

# VPN Server Configuration for P2S
resource "azurerm_vpn_server_configuration" "main" {
  count               = var.create_p2s_vpn_gateway ? 1 : 0
  name                = var.vpn_server_configuration_name
  resource_group_name = var.resource_group_name
  location            = var.location
  vpn_authentication_types = var.vpn_authentication_types
  vpn_protocols       = var.vpn_protocols

  dynamic "azure_active_directory_authentication" {
    for_each = var.azure_ad_authentication
    content {
      audience = azure_active_directory_authentication.value.audience
      issuer   = azure_active_directory_authentication.value.issuer
      tenant   = azure_active_directory_authentication.value.tenant
    }
  }

  dynamic "client_revoked_certificate" {
    for_each = var.client_revoked_certificates
    content {
      name       = client_revoked_certificate.value.name
      thumbprint = client_revoked_certificate.value.thumbprint
    }
  }

  dynamic "client_root_certificate" {
    for_each = var.client_root_certificates
    content {
      name             = client_root_certificate.value.name
      public_cert_data = client_root_certificate.value.public_cert_data
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "vpn-server-configuration"
  })
}

# Virtual Network Connections
resource "azurerm_virtual_hub_connection" "main" {
  for_each            = var.virtual_network_connections
  name                = each.value.name
  virtual_hub_id      = azurerm_virtual_hub.main.id
  remote_virtual_network_id = each.value.remote_virtual_network_id
  internet_security_enabled = each.value.internet_security_enabled
  routing {
    associated_route_table_id = each.value.routing.associated_route_table_id
    propagated_route_table {
      labels = each.value.routing.propagated_route_table.labels
      route_table_ids = each.value.routing.propagated_route_table.route_table_ids
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "virtual-network-connection"
    "ConnectionName" = each.value.name
  })
}

# Network Security Group for Virtual Hub
resource "azurerm_network_security_group" "virtual_hub" {
  count               = var.create_virtual_hub_nsg ? 1 : 0
  name                = var.virtual_hub_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.virtual_hub_nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "virtual-hub-nsg"
  })
}

# Route Table for Virtual Hub
resource "azurerm_route_table" "virtual_hub" {
  count               = var.create_virtual_hub_route_table ? 1 : 0
  name                = var.virtual_hub_route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  dynamic "route" {
    for_each = var.virtual_hub_route_table_routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = merge(var.common_tags, {
    "Module" = "azure-virtual-wan"
    "Component" = "virtual-hub-route-table"
  })
} 