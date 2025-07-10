# App Configuration Demo

The following repo contains everything required to showcase how to use an Azure Web App, integrating with Azure App Configuration Service and Key Vault to do configuration management for an application.

## 🚀 Features

### Pre-installed Tools
- **Azure CLI** - For Azure resource management
- **Azure Developer CLI (azd)** - For modern Azure development workflows
- **Terraform** - For infrastructure as code
- **Docker** - For containerization
- **.NET SDK** (6.0, 7.0, 8.0) - For .NET development

### VS Code Extensions
- HashiCorp Terraform
- Azure Terraform
- Azure Resource Groups
- Azure App Service
- Azure Container Apps
- Docker
- .NET and C# support
- Python support
- GitHub Copilot
- Azure CLI Tools
- Bicep

## 📁 Directory Structure

```
├── README.md
├── app  # Provides a containerized application that shows the app config settings.  
│   ├── AppConfigDemo.csproj
│   ├── Dockerfile
│   ├── Program.cs
│   ├── README.md
│   ├── docker-compose.yml
│   ├── obj
│   │   ├── AppConfigDemo.csproj.nuget.dgspec.json
│   │   ├── AppConfigDemo.csproj.nuget.g.props
│   │   ├── AppConfigDemo.csproj.nuget.g.targets
│   │   ├── project.assets.json
│   │   └── project.nuget.cache
│   ├── run.sh
│   └── test-local.sh
└── infra # Provides infrastructure-as-code to support deploying the infrastructure.  
    ├── README.md
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── terraform.tfvars.example
    └── variables.tf
```

## 🛠️ Getting Started

### 1. Open in DevContainer

1. Open the project in VS Code
2. Install the "Dev Containers" extension if not already installed
3. Press `F1` and select "Dev Containers: Reopen in Container"
4. Wait for the container to build and initialize

### 2. Authenticate with Azure

```bash
# Connect to azure government
az cloud set --name AzureUSGovernment

# Login to Azure
az login --use-device-code

# Verify your account
az account show

# Set subscription if needed
az account set --subscription "your-subscription-id"
```

### 3. Create a tfvars file

You can go to the "./infra" directory and find an example of a tfvar file named "environment.tfvars":

Update this to have the configuration for your environment.  

### 4. Deploy Infrastructure

```bash
# Navigate to the infra directory:
cd ./infra

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=./environment.tfvars

# Apply infrastructure
terraform apply -var-file=./environment.tfvars
```

### 5. Build and Deploy Your App

```bash
# Navigate to app directory
cd app

# Build container image
docker build -t settings-app:latest .

# Test locally
docker run -p 8080:80 myapp

# Tag for ACR (replace with your ACR name from terraform output)
docker tag myapp <acr-name>.azurecr.io/myapp:latest

# Push to ACR
docker push <acr-name>.azurecr.io/myapp:latest
```

## 🔧 VS Code Tasks

The devcontainer includes pre-configured tasks accessible via `Ctrl+Shift+P` → "Tasks: Run Task":

### Terraform Tasks
- **Terraform: Init** - Initialize Terraform
- **Terraform: Validate** - Validate configuration
- **Terraform: Plan** - Plan deployment
- **Terraform: Apply** - Apply infrastructure
- **Terraform: Destroy** - Destroy infrastructure
- **Terraform: Format** - Format code

### Docker Tasks
- **Docker: Build App** - Build container image
- **Docker: Run App Locally** - Run container locally

### Azure Tasks
- **Azure: Login** - Login to Azure
- **Azure: Show Account** - Show current account

### Combined Tasks
- **Build and Deploy: Full Pipeline** - Complete build and deployment

## 🐛 Debugging

### .NET Application Debugging
1. Set breakpoints in your .NET code
2. Use the "Debug .NET App (Local)" configuration
3. Or attach to a running container with "Attach to .NET App in Container"

### Container Debugging
1. Build and run your container locally
2. Use `docker exec -it <container-name> /bin/bash` to access the container
3. Check logs with `docker logs <container-name>`

## 🌐 Port Forwarding

The devcontainer automatically forwards these ports:
- **3000** - Frontend development server
- **5000** - .NET app (HTTP)
- **5001** - .NET app (HTTPS)
- **8080** - Container app
- **8081** - Additional container port

## 📝 Development Workflow

1. **Edit Infrastructure**: Modify `.tf` files for infrastructure changes
2. **Plan Changes**: Run `terraform plan` to see what will change
3. **Apply Changes**: Run `terraform apply` to update infrastructure
4. **Develop App**: Work in the `app/` directory
5. **Build Container**: Use Docker tasks to build and test
6. **Deploy**: Push to ACR and update App Service

## 🔐 Security Notes

- The devcontainer runs as the `vscode` user for security
- Docker socket is mounted for container operations
- All Azure authentication uses your personal credentials
- Terraform state is stored locally (consider remote state for production)

## 📚 Additional Resources

- [Azure DevContainer Images](https://github.com/devcontainers/images)
- [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Configuration](https://docs.microsoft.com/azure/azure-app-configuration/)
- [Azure Key Vault](https://docs.microsoft.com/azure/key-vault/)

## 🆘 Troubleshooting

### Container Won't Start
- Check Docker is running on your host
- Verify you have sufficient disk space
- Check the devcontainer logs in VS Code

### Terraform Issues
- Ensure you're logged into Azure: `az login`
- Check your subscription: `az account show`
- Verify permissions on the subscription

### Azure Authentication
- Try `az login --use-device-code` for authentication issues
- Clear credentials: `az logout` then `az login`
- Check tenant: `az account tenant list`
