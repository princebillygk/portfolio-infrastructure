terraform {
  cloud {
    organization = "princebillygk"
    workspaces {
      name = "MyPortfolio"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

