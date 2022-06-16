provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "MyPortfolioRg" {
  name     = "MyPortfolioRg"
  location = "West India"
  tags     = local.common_tags
}

resource "azurerm_network_security_group" "PrivateNsg" {
  name                = "PrivateNsg"
  location            = azurerm_resource_group.MyPortfolioRg.location
  resource_group_name = azurerm_resource_group.MyPortfolioRg.name
  tags                = local.common_tags
  
}


resource "azurerm_network_security_group" "PublicNsg" {
  name                = "PublicNsg"
  location            = azurerm_resource_group.MyPortfolioRg.location
  resource_group_name = azurerm_resource_group.MyPortfolioRg.name
  tags                = local.common_tags

  security_rule {
    name                       = "WebInbound"
    description                = "Allows HTTPS/HTTP connection from the public internet"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
  }

  security_rule {
    name                       = "AllOutbound"
    description                = "Allows outbound conneciton to everywhere"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
  }
}

resource "azurerm_virtual_network" "MyPortfolioVn" {
  name                = "MyPortfolioVn"
  resource_group_name = azurerm_resource_group.MyPortfolioRg.name
  location            = azurerm_resource_group.MyPortfolioRg.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "PublicSubnet" {
  name           = "PublicSubnet"
  address_prefixes = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.MyPortfolioRg.name
  virtual_network_name = azurerm_virtual_network.MyPortfolioVn.name
  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

resource "azurerm_subnet_network_security_group_association" "PublicSubnetNsgAssociation" {
  subnet_id                 = azurerm_subnet.PublicSubnet.id
  network_security_group_id = azurerm_network_security_group.PublicNsg.id
}

resource "azurerm_subnet" "PrivateSubnet" {
  name           = "PrivateSubnet"
  address_prefixes = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.MyPortfolioRg.name
  virtual_network_name = azurerm_virtual_network.MyPortfolioVn.name
  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

resource "azurerm_subnet_network_security_group_association" "PrivateSubnetNsgAssociation" {
  subnet_id                 = azurerm_subnet.PrivateSubnet.id
  network_security_group_id = azurerm_network_security_group.PrivateNsg.id
}


resource "azurerm_cosmosdb_account" "my-portfolio-db" {
  name                = "my-portfolio-db"
  location            = azurerm_resource_group.MyPortfolioRg.location
  resource_group_name = azurerm_resource_group.MyPortfolioRg.name
  tags = local.common_tags
  offer_type          = "Standard"
  kind                = "MongoDB"
  enable_free_tier = true
  capacity {
    total_throughput_limit = 1000
  }

  consistency_policy {
    consistency_level       = "Eventual"
  }

  geo_location {
    location = azurerm_resource_group.MyPortfolioRg.location
    failover_priority = 0
  }

  virtual_network_rule {
    id = azurerm_subnet.PublicSubnet.id
  }

  virtual_network_rule {
    id = azurerm_subnet.PrivateSubnet.id
  }
}

