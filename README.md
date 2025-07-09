# Azure App Configuration Demo Infrastructure

This Terraform configuration deploys an Azure infrastructure stack with:

- **App Service** (Linux) with managed identity
- **Container Registry** for container images
- **App Configuration Service** for centralized configuration
- **Key Vault** for secrets management
- **Managed Identities** and **Role Assignments** for secure access

## Architecture

The infrastructure implements the following security patterns:

1. **App Service** uses a user-assigned managed identity to:
   - Read configuration from App Configuration Service
   - Pull container images from Container Registry

2. **App Configuration Service** uses a user-assigned managed identity to:
   - Read secrets from Key Vault (for configuration values that reference secrets)

3. **Role Assignments** ensure least-privilege access:
   - App Service → App Configuration: `App Configuration Data Reader`
   - App Service → Container Registry: `AcrPull`
   - App Configuration → Key Vault: `Key Vault Secrets User`

## Prerequisites

- Azure CLI installed and logged in
- Terraform installed (use `winget install HashiCorp.Terraform` on Windows)
- Appropriate Azure subscription permissions

## Deployment

1. **Clone and navigate to the repository**:
   ```bash
   cd /home/kemack/github-projects/app-config-demo-infra
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Create a terraform.tfvars file** (optional):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired values
   ```

4. **Validate the configuration**:
   ```bash
   terraform validate
   ```

5. **Plan the deployment**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply -auto-approve
   ```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `resource_group_name` | Name of the resource group | `rg-app-config-demo` | No |
| `location` | Azure region | `East US` | No |
| `prefix` | Prefix for resource names | `appconfigdemo` | No |
| `tags` | Tags to apply to resources | See variables.tf | No |

### Example Usage

The deployed App Service can access configuration using the Azure App Configuration SDK:

```csharp
// Example C# code for accessing App Configuration
var builder = WebApplication.CreateBuilder(args);

// Add Azure App Configuration
builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(new Uri(Environment.GetEnvironmentVariable("AZURE_APP_CONFIG_ENDPOINT")),
                    new DefaultAzureCredential())
           .ConfigureKeyVault(kv =>
           {
               kv.SetCredential(new DefaultAzureCredential());
           });
});
```

## Resources Created

- Resource Group
- User-Assigned Managed Identities (2)
- App Service Plan (Linux, B1)
- App Service (Linux Web App)
- Container Registry (Basic SKU)
- App Configuration Service (Free tier)
- Key Vault (Standard SKU)
- Role Assignments for secure access
- Sample configuration key-value pairs
- Sample Key Vault secret

## Security Features

- **No admin accounts enabled** on Container Registry
- **RBAC-based access** to Key Vault (no access policies)
- **Managed identities** for all service-to-service authentication
- **Least privilege** role assignments
- **Key Vault references** in App Configuration for sensitive values

## Clean Up

To destroy the infrastructure:

```bash
terraform destroy
```

## Outputs

After deployment, Terraform will output important information including:

- App Service URL
- Container Registry login server
- App Configuration endpoint
- Key Vault URI
- Managed identity client IDs

## Next Steps

1. **Deploy your application container** to the Container Registry
2. **Configure the App Service** to use your container image
3. **Add configuration values** to App Configuration Service
4. **Store secrets** in Key Vault and reference them from App Configuration
