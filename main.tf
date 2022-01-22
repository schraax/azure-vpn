terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resources"
  location = var.location
}


resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_public_ip" "publicip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "gw" {
  name                = "${var.prefix}-vnetgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1AZ"


  ip_configuration {
     name                          = "vnetGatewayConfig"
     public_ip_address_id          = azurerm_public_ip.publicip.id
     private_ip_address_allocation = "Dynamic"
     subnet_id                     = azurerm_subnet.subnet.id
  }
}
