# Azure Virtual WAN Module Variables
# This file contains all customizable parameters for the Virtual WAN architecture

# Required Variables
variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

# Virtual WAN Configuration
variable "virtual_wan_name" {
  description = "Name of the Virtual WAN resource"
  type        = string
  default     = "vwan-main"
}

variable "virtual_wan_type" {
  description = "Type of Virtual WAN (Standard or Basic)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Basic"], var.virtual_wan_type)
    error_message = "Virtual WAN type must be either 'Standard' or 'Basic'."
  }
}

variable "disable_vpn_encryption" {
  description = "Disable VPN encryption for Virtual WAN"
  type        = bool
  default     = false
}

variable "allow_branch_to_branch_traffic" {
  description = "Allow branch to branch traffic through Virtual WAN"
  type        = bool
  default     = true
}

variable "office365_local_breakout_category" {
  description = "Office365 local breakout category"
  type        = string
  default     = "None"
  validation {
    condition     = contains(["None", "Optimize", "Allow"], var.office365_local_breakout_category)
    error_message = "Office365 local breakout category must be 'None', 'Optimize', or 'Allow'."
  }
}

# Virtual Hub Configuration
variable "virtual_hub_name" {
  description = "Name of the Virtual Hub"
  type        = string
  default     = "vhub-main"
}

variable "virtual_hub_address_prefix" {
  description = "Address prefix for the Virtual Hub (CIDR notation)"
  type        = string
  default     = "10.0.0.0/24"
  validation {
    condition     = can(cidrhost(var.virtual_hub_address_prefix, 0))
    error_message = "Virtual Hub address prefix must be a valid CIDR notation."
  }
}

variable "virtual_hub_sku" {
  description = "SKU for the Virtual Hub"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.virtual_hub_sku)
    error_message = "Virtual Hub SKU must be either 'Basic' or 'Standard'."
  }
}

variable "hub_routing_preference" {
  description = "Hub routing preference"
  type        = string
  default     = "ExpressRoute"
  validation {
    condition     = contains(["ExpressRoute", "VpnGateway", "ASPath"], var.hub_routing_preference)
    error_message = "Hub routing preference must be 'ExpressRoute', 'VpnGateway', or 'ASPath'."
  }
}

variable "virtual_hub_routes" {
  description = "List of routes for the Virtual Hub"
  type = list(object({
    address_prefixes    = list(string)
    next_hop_ip_address = string
  }))
  default = []
}

# Virtual Hub Route Table Configuration
variable "create_hub_route_table" {
  description = "Whether to create a Virtual Hub route table"
  type        = bool
  default     = false
}

variable "hub_route_table_name" {
  description = "Name of the Virtual Hub route table"
  type        = string
  default     = "vhub-route-table"
}

variable "hub_route_table_labels" {
  description = "Labels for the Virtual Hub route table"
  type        = list(string)
  default     = ["default"]
}

variable "hub_route_table_routes" {
  description = "List of routes for the Virtual Hub route table"
  type = list(object({
    name                = string
    destinations        = list(string)
    destinations_type   = string
    next_hop           = string
    next_hop_type      = string
  }))
  default = []
}

# Site-to-Site VPN Gateway Configuration
variable "create_s2s_vpn_gateway" {
  description = "Whether to create a Site-to-Site VPN Gateway"
  type        = bool
  default     = false
}

variable "vpn_gateway_name" {
  description = "Name of the VPN Gateway"
  type        = string
  default     = "vpn-gateway"
}

variable "vpn_gateway_routing_preference" {
  description = "Routing preference for VPN Gateway"
  type        = string
  default     = "Microsoft Network"
  validation {
    condition     = contains(["Microsoft Network", "Internet"], var.vpn_gateway_routing_preference)
    error_message = "VPN Gateway routing preference must be 'Microsoft Network' or 'Internet'."
  }
}

variable "vpn_gateway_scale_unit" {
  description = "Scale unit for VPN Gateway (1-80)"
  type        = number
  default     = 1
  validation {
    condition     = var.vpn_gateway_scale_unit >= 1 && var.vpn_gateway_scale_unit <= 80
    error_message = "VPN Gateway scale unit must be between 1 and 80."
  }
}

# VPN Sites Configuration
variable "vpn_sites" {
  description = "Map of VPN sites to create"
  type = map(object({
    name                = string
    address_cidrs       = list(string)
    device_model        = string
    device_vendor       = string
    link_speed_in_mbps  = number
    links = list(object({
      name                = string
      ip_address          = string
      fqdn                = optional(string)
      bgp_enabled         = optional(bool, false)
      asn                 = optional(number)
      bgp_peering_address = optional(string)
    }))
  }))
  default = {}
}

# VPN Connections Configuration
variable "vpn_connections" {
  description = "Map of VPN connections to create"
  type = map(object({
    name                      = string
    vpn_site_key             = string
    internet_security_enabled = bool
    routing_weight            = number
    shared_key                = string
    vpn_links = list(object({
      name             = string
      bandwidth_mbps   = number
      bgp_enabled      = bool
      ipsec_policy = object({
        sa_lifetime_seconds     = number
        sa_data_size_kilobytes = number
        ipsec_encryption        = string
        ipsec_integrity         = string
        ike_encryption          = string
        ike_integrity           = string
        dh_group                = string
        pfs_group               = string
      })
    }))
  }))
  default = {}
}

# ExpressRoute Gateway Configuration
variable "create_expressroute_gateway" {
  description = "Whether to create an ExpressRoute Gateway"
  type        = bool
  default     = false
}

variable "expressroute_gateway_name" {
  description = "Name of the ExpressRoute Gateway"
  type        = string
  default     = "er-gateway"
}

variable "expressroute_gateway_scale_units" {
  description = "Scale units for ExpressRoute Gateway (1-10)"
  type        = number
  default     = 1
  validation {
    condition     = var.expressroute_gateway_scale_units >= 1 && var.expressroute_gateway_scale_units <= 10
    error_message = "ExpressRoute Gateway scale units must be between 1 and 10."
  }
}

# ExpressRoute Connections Configuration
variable "expressroute_connections" {
  description = "Map of ExpressRoute connections to create"
  type = map(object({
    name                           = string
    express_route_circuit_peering_id = string
    authorization_key              = string
    routing_weight                 = number
    enable_internet_security       = bool
  }))
  default = {}
}

# Point-to-Site VPN Gateway Configuration
variable "create_p2s_vpn_gateway" {
  description = "Whether to create a Point-to-Site VPN Gateway"
  type        = bool
  default     = false
}

variable "p2s_vpn_gateway_name" {
  description = "Name of the Point-to-Site VPN Gateway"
  type        = string
  default     = "p2s-vpn-gateway"
}

variable "p2s_vpn_gateway_scale_unit" {
  description = "Scale unit for Point-to-Site VPN Gateway (1-80)"
  type        = number
  default     = 1
  validation {
    condition     = var.p2s_vpn_gateway_scale_unit >= 1 && var.p2s_vpn_gateway_scale_unit <= 80
    error_message = "Point-to-Site VPN Gateway scale unit must be between 1 and 80."
  }
}

variable "p2s_vpn_server_configuration_id" {
  description = "ID of the VPN server configuration for Point-to-Site VPN"
  type        = string
  default     = null
}

variable "p2s_connection_configurations" {
  description = "List of connection configurations for Point-to-Site VPN"
  type = list(object({
    name = string
    vpn_client_address_pool = object({
      address_prefixes = list(string)
    })
    route = object({
      associated_route_table_id = string
      propagated_route_table = object({
        labels = list(string)
        route_table_ids = list(string)
      })
    })
  }))
  default = []
}

# VPN Server Configuration for P2S
variable "vpn_server_configuration_name" {
  description = "Name of the VPN server configuration"
  type        = string
  default     = "vpn-server-config"
}

variable "vpn_authentication_types" {
  description = "List of VPN authentication types"
  type        = list(string)
  default     = ["Certificate"]
  validation {
    condition = alltrue([
      for auth_type in var.vpn_authentication_types : 
      contains(["Certificate", "AAD", "Radius"], auth_type)
    ])
    error_message = "VPN authentication types must be 'Certificate', 'AAD', or 'Radius'."
  }
}

variable "vpn_protocols" {
  description = "List of VPN protocols"
  type        = list(string)
  default     = ["OpenVPN"]
  validation {
    condition = alltrue([
      for protocol in var.vpn_protocols : 
      contains(["OpenVPN", "IkeV2"], protocol)
    ])
    error_message = "VPN protocols must be 'OpenVPN' or 'IkeV2'."
  }
}

variable "azure_ad_authentication" {
  description = "Azure Active Directory authentication configuration"
  type = list(object({
    audience = string
    issuer   = string
    tenant   = string
  }))
  default = []
}

variable "client_revoked_certificates" {
  description = "List of client revoked certificates"
  type = list(object({
    name       = string
    thumbprint = string
  }))
  default = []
}

variable "client_root_certificates" {
  description = "List of client root certificates"
  type = list(object({
    name             = string
    public_cert_data = string
  }))
  default = []
}

# Virtual Network Connections Configuration
variable "virtual_network_connections" {
  description = "Map of virtual network connections to create"
  type = map(object({
    name                        = string
    remote_virtual_network_id   = string
    internet_security_enabled   = bool
    routing = object({
      associated_route_table_id = string
      propagated_route_table = object({
        labels = list(string)
        route_table_ids = list(string)
      })
    })
  }))
  default = {}
}

# Network Security Group Configuration
variable "create_virtual_hub_nsg" {
  description = "Whether to create a Network Security Group for the Virtual Hub"
  type        = bool
  default     = false
}

variable "virtual_hub_nsg_name" {
  description = "Name of the Network Security Group for Virtual Hub"
  type        = string
  default     = "vhub-nsg"
}

variable "virtual_hub_nsg_rules" {
  description = "List of security rules for the Virtual Hub NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

# Route Table Configuration
variable "create_virtual_hub_route_table" {
  description = "Whether to create a route table for the Virtual Hub"
  type        = bool
  default     = false
}

variable "virtual_hub_route_table_name" {
  description = "Name of the route table for Virtual Hub"
  type        = string
  default     = "vhub-route-table"
}

variable "disable_bgp_route_propagation" {
  description = "Disable BGP route propagation"
  type        = bool
  default     = false
}

variable "virtual_hub_route_table_routes" {
  description = "List of routes for the Virtual Hub route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "Environment" = "Production"
    "Project"     = "Virtual-WAN"
    "ManagedBy"   = "Terraform"
  }
} 