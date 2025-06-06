terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.32.0"
    }
  }

  backend "azurerm" {      
    use_msi              = true                               
    use_azuread_auth     = true                                   
    tenant_id            = "9011785c-300d-4d38-8cb2-c9fcfa21f771" 
    client_id            = "b5d2582d-5f06-48e5-a278-d4f28e742651" 
    #resource_group_name = "dc-1_group"                             
    storage_account_name = "insiiblebk"                              # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"                               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "test.terraform.tfstate"                # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}

provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  subscription_id = var.sub-id
  features {}
}
