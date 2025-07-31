# Variables for Advanced Virtual WAN Example
# This file shows how to use variables with the Virtual WAN module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-vwan-advanced"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Production"
  validation {
    condition     = contains(["Development", "Staging", "Production"], var.environment)
    error_message = "Environment must be one of: Development, Staging, Production."
  }
}

variable "vpn_shared_keys" {
  description = "Shared keys for VPN connections"
  type = map(string)
  default = {
    "branch-office-1" = "YourSecureSharedKey123!"
    "branch-office-2" = "YourSecureSharedKey456!"
  }
  sensitive = true
}

variable "expressroute_circuit_peering_id" {
  description = "ExpressRoute circuit peering ID"
  type        = string
  default     = ""
}

variable "expressroute_auth_key" {
  description = "ExpressRoute authorization key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vnet_app_id" {
  description = "ID of the application virtual network"
  type        = string
  default     = ""
}

variable "vnet_data_id" {
  description = "ID of the data virtual network"
  type        = string
  default     = ""
}

variable "client_root_certificates" {
  description = "Client root certificates for P2S VPN"
  type = list(object({
    name             = string
    public_cert_data = string
  }))
  default = []
  sensitive = true
}

variable "azure_ad_authentication" {
  description = "Azure AD authentication configuration"
  type = list(object({
    audience = string
    issuer   = string
    tenant   = string
  }))
  default = []
}

variable "enable_all_gateways" {
  description = "Enable all gateway types"
  type        = bool
  default     = true
}

variable "enable_security_features" {
  description = "Enable security features (NSG, etc.)"
  type        = bool
  default     = true
}

variable "vpn_gateway_scale_unit" {
  description = "Scale unit for VPN Gateway"
  type        = number
  default     = 2
  validation {
    condition     = var.vpn_gateway_scale_unit >= 1 && var.vpn_gateway_scale_unit <= 80
    error_message = "VPN Gateway scale unit must be between 1 and 80."
  }
}

variable "expressroute_gateway_scale_units" {
  description = "Scale units for ExpressRoute Gateway"
  type        = number
  default     = 2
  validation {
    condition     = var.expressroute_gateway_scale_units >= 1 && var.expressroute_gateway_scale_units <= 10
    error_message = "ExpressRoute Gateway scale units must be between 1 and 10."
  }
}

variable "p2s_vpn_gateway_scale_unit" {
  description = "Scale unit for Point-to-Site VPN Gateway"
  type        = number
  default     = 1
  validation {
    condition     = var.p2s_vpn_gateway_scale_unit >= 1 && var.p2s_vpn_gateway_scale_unit <= 80
    error_message = "Point-to-Site VPN Gateway scale unit must be between 1 and 80."
  }
}

variable "vpn_client_address_pool" {
  description = "Address pool for P2S VPN clients"
  type        = string
  default     = "172.16.100.0/24"
  validation {
    condition     = can(cidrhost(var.vpn_client_address_pool, 0))
    error_message = "VPN client address pool must be a valid CIDR notation."
  }
}

variable "virtual_hub_address_prefix" {
  description = "Address prefix for Virtual Hub"
  type        = string
  default     = "10.0.0.0/24"
  validation {
    condition     = can(cidrhost(var.virtual_hub_address_prefix, 0))
    error_message = "Virtual Hub address prefix must be a valid CIDR notation."
  }
}

variable "vpn_sites" {
  description = "VPN sites configuration"
  type = map(object({
    name               = string
    address_cidrs      = list(string)
    device_model       = string
    device_vendor      = string
    link_speed_in_mbps = number
    links = list(object({
      name                = string
      ip_address          = string
      fqdn                = optional(string)
      bgp_enabled         = optional(bool, false)
      asn                 = optional(number)
      bgp_peering_address = optional(string)
    }))
  }))
  default = {
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
}

variable "nsg_rules" {
  description = "Network Security Group rules"
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
  default = [
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
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "Virtual-WAN-Advanced"
    CostCenter  = "IT-001"
    Owner       = "Network-Team"
    ManagedBy   = "Terraform"
  }
} 