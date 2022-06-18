provider "azurerm" {
  features {}
  subscription_id = var.azure.subscription_id
  client_id       = var.azure.client_id
  client_secret   = var.azure.client_secret
  tenant_id       = var.azure.tenant_id
}

resource "azurerm_resource_group" "MyPortfolioRg" {
  name     = "MyPortfolioRg"
  location = "East US"
  tags     = local.common_tags
}


resource "azurerm_cosmosdb_account" "princebillygk-portfolio-mongodb" {
  name                              = "princebillygk-portfolio-mongodb"
  location                          = azurerm_resource_group.MyPortfolioRg.location
  resource_group_name               = azurerm_resource_group.MyPortfolioRg.name
  tags                              = local.common_tags
  offer_type                        = "Standard"
  kind                              = "MongoDB"
  enable_free_tier                  = true
  is_virtual_network_filter_enabled = true
  capacity {
    total_throughput_limit = 1000
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.MyPortfolioRg.location
    failover_priority = 0
  }
}


resource "azurerm_service_plan" "MyPortfolioAppPlan" {
  name                = "MyPortfolioAppPlan"
  resource_group_name = azurerm_resource_group.MyPortfolioRg.name
  location            = azurerm_resource_group.MyPortfolioRg.location
  os_type             = "Linux"
  sku_name            = "F1"
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "princebillygk-portfolio" {
  name                = "princebillygk"
  resource_group_name = azurerm_resource_group.MyPortfolioRg.name
  location            = azurerm_resource_group.MyPortfolioRg.location
  service_plan_id     = azurerm_service_plan.MyPortfolioAppPlan.id
  site_config {
    always_on = false
    application_stack {
      docker_image = "princebillygk/portfolio-backend:latest"
      docker_image_tag = "latest"
    }
  }
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://ghcr.io"
    # PORT = 80
    # WEBSITES_PORTS = 80
  }
}
