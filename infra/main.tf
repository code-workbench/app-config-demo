# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  environment = "usgovernment"
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data source to get current client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# User Assigned Managed Identity for App Service
resource "azurerm_user_assigned_identity" "app_service" {
  name                = "${var.prefix}-app-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}

# User Assigned Managed Identity for App Configuration
resource "azurerm_user_assigned_identity" "app_config" {
  name                = "${var.prefix}-config-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "${var.prefix}-kv-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable RBAC authorization instead of access policies
  enable_rbac_authorization = true

  # Security settings
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = var.tags
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = var.tags
}

# App Configuration
resource "azurerm_app_configuration" "main" {
  name                = "${var.prefix}-appconfig-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "free"

  # Assign the managed identity to App Configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_config.id]
  }

  tags = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.prefix}-asp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = var.tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "${var.prefix}-app-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  # Assign the managed identity to App Service
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_service.id]
  }

  site_config {
    # Configure for container deployment
    always_on = false

    application_stack {
      docker_image_name   = "${azurerm_container_registry.main.login_server}/settings-app:latest"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  # App settings for App Configuration connection
  app_settings = {
    "AZURE_APP_CONFIG_ENDPOINT"           = azurerm_app_configuration.main.endpoint
    "AZURE_CLIENT_ID"                     = azurerm_user_assigned_identity.app_service.client_id
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "TEST_KEY"                            = "@Microsoft.AppConfiguration(Endpoint=${azurerm_app_configuration.main.endpoint}; Key=TEST_KEY)"
    "TEST_SECRET"                         = "@Microsoft.AppConfiguration(Endpoint=${azurerm_app_configuration.main.endpoint}; Key=TEST_SECRET)"
  }

  tags = var.tags
}

# Role Assignments

# App Service identity can read from App Configuration
resource "azurerm_role_assignment" "app_service_to_app_config" {
  scope                = azurerm_app_configuration.main.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_user_assigned_identity.app_service.principal_id
}

# App Service identity can pull from Container Registry
resource "azurerm_role_assignment" "app_service_to_acr" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app_service.principal_id
}

# App Configuration identity can read secrets from Key Vault
resource "azurerm_role_assignment" "app_config_to_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_config.principal_id
}

# Current user/service principal access to Key Vault (for management)
resource "azurerm_role_assignment" "current_user_to_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}


# TEST_SECRET Key Vault Secret
resource "azurerm_key_vault_secret" "test_secret" {
  name         = "TEST-SECRET"
  value        = "SuperSecret"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.current_user_to_keyvault]

  tags = var.tags
}

# Sample App Configuration Key-Value
resource "azurerm_app_configuration_key" "test_key" {
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = "TEST_KEY"
  value                  = "This is a test key in the app config"

  tags = var.tags
}

# App Configuration Key-Value that references Key Vault secret for TEST_SECRET
resource "azurerm_app_configuration_key" "test_secret_reference" {
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = "TEST_SECRET"
  type                   = "vault"
  vault_key_reference    = azurerm_key_vault_secret.test_secret.versionless_id

  tags = var.tags
}

# App Configuration Key-Value that references Key Vault secret
resource "azurerm_app_configuration_key" "keyvault_reference" {
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = "app:database:connectionstring"
  type                   = "vault"
  vault_key_reference    = azurerm_key_vault_secret.test_secret.versionless_id
  label                  = "production"

  tags = var.tags
}
