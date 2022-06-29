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

locals {
  cosmodb_allowed_ip = [
    // My current ip
    "${var.admin_ip}/32",
    # Azure portal ip address
    "51.4.229.218/32",
    "52.244.48.71/32",
    "52.244.48.71/32",
    "104.42.195.92/32",
    "40.76.54.131/32",
    "52.176.6.30/32",
    "52.169.50.45/32",
    "52.187.184.26/32"
  ]
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
  ip_range_filter                   = join(",", local.cosmodb_allowed_ip)
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

output "mongodb_endpoint" {
  value = azurerm_cosmosdb_account.princebillygk-portfolio-mongodb.endpoint
}
output "mongodb_connection_strings" {
  value     = azurerm_cosmosdb_account.princebillygk-portfolio-mongodb.connection_strings
  sensitive = true
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
      docker_image     = "princebillygk/portfolio-backend"
      docker_image_tag = "latest"
    }
  }
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://ghcr.io"
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_env.username
    DOCKER_REGISTRY_SERVER_PASSWORD = var.docker_env.password

    MONGODB_URI = var.app_env.mongodb_uri
    RESUME_OBJ_ID = var.app_env.resume_obj_id
  }
}

