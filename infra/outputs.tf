output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.main.name
}

output "container_registry_login_server" {
  description = "Login server URL for the Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.main.name
}

output "app_configuration_endpoint" {
  description = "Endpoint of the App Configuration service"
  value       = azurerm_app_configuration.main.endpoint
}

output "app_configuration_name" {
  description = "Name of the App Configuration service"
  value       = azurerm_app_configuration.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "app_service_managed_identity_client_id" {
  description = "Client ID of the App Service managed identity"
  value       = azurerm_user_assigned_identity.app_service.client_id
}

output "app_service_managed_identity_principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = azurerm_user_assigned_identity.app_service.principal_id
}

output "app_config_managed_identity_client_id" {
  description = "Client ID of the App Configuration managed identity"
  value       = azurerm_user_assigned_identity.app_config.client_id
}

output "app_config_managed_identity_principal_id" {
  description = "Principal ID of the App Configuration managed identity"
  value       = azurerm_user_assigned_identity.app_config.principal_id
}
