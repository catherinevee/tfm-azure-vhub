# Basic test for Azure Virtual WAN module
# This test validates the basic functionality of the module

run "basic_virtual_wan_creation" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan"
    location            = "East US"
    virtual_wan_name    = "vwan-test"
    virtual_hub_name    = "vhub-test"
  }

  assert {
    condition     = azurerm_virtual_wan.main.name == "vwan-test"
    error_message = "Virtual WAN name should match the input variable"
  }

  assert {
    condition     = azurerm_virtual_hub.main.name == "vhub-test"
    error_message = "Virtual Hub name should match the input variable"
  }

  assert {
    condition     = azurerm_virtual_hub.main.virtual_wan_id == azurerm_virtual_wan.main.id
    error_message = "Virtual Hub should reference the Virtual WAN"
  }

  assert {
    condition     = azurerm_virtual_wan.main.type == "Standard"
    error_message = "Virtual WAN type should default to Standard"
  }

  assert {
    condition     = azurerm_virtual_hub.main.sku == "Standard"
    error_message = "Virtual Hub SKU should default to Standard"
  }
}

run "virtual_wan_with_custom_config" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan-custom"
    location            = "West US 2"
    virtual_wan_name    = "vwan-custom"
    virtual_hub_name    = "vhub-custom"
    virtual_wan_type    = "Basic"
    virtual_hub_sku     = "Basic"
    virtual_hub_address_prefix = "10.1.0.0/24"
    disable_vpn_encryption = true
    allow_branch_to_branch_traffic = false
  }

  assert {
    condition     = azurerm_virtual_wan.main.type == "Basic"
    error_message = "Virtual WAN type should be set to Basic"
  }

  assert {
    condition     = azurerm_virtual_hub.main.sku == "Basic"
    error_message = "Virtual Hub SKU should be set to Basic"
  }

  assert {
    condition     = azurerm_virtual_hub.main.address_prefix == "10.1.0.0/24"
    error_message = "Virtual Hub address prefix should match the input"
  }

  assert {
    condition     = azurerm_virtual_wan.main.disable_vpn_encryption == true
    error_message = "VPN encryption should be disabled"
  }

  assert {
    condition     = azurerm_virtual_wan.main.allow_branch_to_branch_traffic == false
    error_message = "Branch to branch traffic should be disabled"
  }
}

run "virtual_wan_with_vpn_gateway" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan-vpn"
    location            = "Central US"
    virtual_wan_name    = "vwan-vpn"
    virtual_hub_name    = "vhub-vpn"
    create_s2s_vpn_gateway = true
    vpn_gateway_name    = "vpn-gateway-test"
    vpn_gateway_scale_unit = 2
  }

  assert {
    condition     = azurerm_vpn_gateway.main[0].name == "vpn-gateway-test"
    error_message = "VPN Gateway name should match the input variable"
  }

  assert {
    condition     = azurerm_vpn_gateway.main[0].scale_unit == 2
    error_message = "VPN Gateway scale unit should match the input variable"
  }

  assert {
    condition     = azurerm_vpn_gateway.main[0].virtual_hub_id == azurerm_virtual_hub.main.id
    error_message = "VPN Gateway should reference the Virtual Hub"
  }
}

run "virtual_wan_with_expressroute" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan-er"
    location            = "North Europe"
    virtual_wan_name    = "vwan-er"
    virtual_hub_name    = "vhub-er"
    create_expressroute_gateway = true
    expressroute_gateway_name = "er-gateway-test"
    expressroute_gateway_scale_units = 3
  }

  assert {
    condition     = azurerm_express_route_gateway.main[0].name == "er-gateway-test"
    error_message = "ExpressRoute Gateway name should match the input variable"
  }

  assert {
    condition     = azurerm_express_route_gateway.main[0].scale_units == 3
    error_message = "ExpressRoute Gateway scale units should match the input variable"
  }

  assert {
    condition     = azurerm_express_route_gateway.main[0].virtual_hub_id == azurerm_virtual_hub.main.id
    error_message = "ExpressRoute Gateway should reference the Virtual Hub"
  }
}

run "virtual_wan_with_p2s_vpn" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan-p2s"
    location            = "South Central US"
    virtual_wan_name    = "vwan-p2s"
    virtual_hub_name    = "vhub-p2s"
    create_p2s_vpn_gateway = true
    p2s_vpn_gateway_name = "p2s-gateway-test"
    p2s_vpn_gateway_scale_unit = 1
  }

  assert {
    condition     = azurerm_point_to_site_vpn_gateway.main[0].name == "p2s-gateway-test"
    error_message = "P2S VPN Gateway name should match the input variable"
  }

  assert {
    condition     = azurerm_point_to_site_vpn_gateway.main[0].scale_unit == 1
    error_message = "P2S VPN Gateway scale unit should match the input variable"
  }

  assert {
    condition     = azurerm_point_to_site_vpn_gateway.main[0].virtual_hub_id == azurerm_virtual_hub.main.id
    error_message = "P2S VPN Gateway should reference the Virtual Hub"
  }
}

run "virtual_wan_with_nsg" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan-nsg"
    location            = "West Europe"
    virtual_wan_name    = "vwan-nsg"
    virtual_hub_name    = "vhub-nsg"
    create_virtual_hub_nsg = true
    virtual_hub_nsg_name = "vhub-nsg-test"
    virtual_hub_nsg_rules = [
      {
        name                       = "AllowHTTPS"
        priority                   = 100
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

  assert {
    condition     = azurerm_network_security_group.virtual_hub[0].name == "vhub-nsg-test"
    error_message = "NSG name should match the input variable"
  }

  assert {
    condition     = length(azurerm_network_security_group.virtual_hub[0].security_rule) == 1
    error_message = "NSG should have one security rule"
  }

  assert {
    condition     = azurerm_network_security_group.virtual_hub[0].security_rule[0].name == "AllowHTTPS"
    error_message = "NSG security rule name should match the input"
  }
}

run "virtual_wan_with_route_table" {
  command = plan

  variables {
    resource_group_name = "rg-test-vwan-rt"
    location            = "East Asia"
    virtual_wan_name    = "vwan-rt"
    virtual_hub_name    = "vhub-rt"
    create_virtual_hub_route_table = true
    virtual_hub_route_table_name = "vhub-rt-test"
    virtual_hub_route_table_routes = [
      {
        name                   = "InternetRoute"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      }
    ]
  }

  assert {
    condition     = azurerm_route_table.virtual_hub[0].name == "vhub-rt-test"
    error_message = "Route table name should match the input variable"
  }

  assert {
    condition     = length(azurerm_route_table.virtual_hub[0].route) == 1
    error_message = "Route table should have one route"
  }

  assert {
    condition     = azurerm_route_table.virtual_hub[0].route[0].name == "InternetRoute"
    error_message = "Route name should match the input"
  }
} 