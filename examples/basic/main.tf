# Basic Virtual WAN Example
# This example shows the minimal configuration needed to create a Virtual WAN with a hub

# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-vwan-example"
  location = "East US"
}

# Use the Virtual WAN module with minimal configuration
module "virtual_wan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Basic Virtual WAN configuration
  virtual_wan_name = "vwan-basic-example"
  virtual_hub_name = "vhub-eastus"

  # Common tags
  common_tags = {
    Environment = "Development"
    Project     = "Virtual-WAN-Example"
    Owner       = "DevOps-Team"
  }
}

# Output the results
output "virtual_wan_id" {
  description = "ID of the created Virtual WAN"
  value       = module.virtual_wan.virtual_wan_id
}

output "virtual_hub_id" {
  description = "ID of the created Virtual Hub"
  value       = module.virtual_wan.virtual_hub_id
}

output "module_summary" {
  description = "Summary of created resources"
  value       = module.virtual_wan.module_summary
} 