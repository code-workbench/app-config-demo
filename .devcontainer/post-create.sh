#!/bin/bash

# Post-create script for Azure App Config Demo devcontainer
echo "🚀 Setting up Azure App Config Demo development environment..."

# Update package lists
sudo apt-get update

# Install additional tools for Azure development
echo "📦 Installing additional development tools..."

# Install Azure Developer CLI (azd)
curl -fsSL https://aka.ms/install-azd.sh | bash

# Install kubectl for container management
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Helm for Kubernetes package management
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# Install additional .NET tools
dotnet tool install --global dotnet-ef
dotnet tool install --global Microsoft.Web.LibraryManager.Cli

# Create app directory if it doesn't exist
mkdir -p /workspace/app

# Initialize Terraform in the root directory
echo "🏗️ Initializing Terraform..."
cd /workspace
if [ -f "main.tf" ]; then
    terraform init
    echo "✅ Terraform initialized successfully"
else
    echo "⚠️ No main.tf found - Terraform initialization skipped"
fi

# Set up git hooks for Terraform formatting
if [ -d ".git" ]; then
    echo "📝 Setting up git hooks..."
    mkdir -p .git/hooks
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Format Terraform files before commit
terraform fmt -recursive .
git add *.tf
EOF
    chmod +x .git/hooks/pre-commit
fi

# Create sample app structure if app directory is empty
if [ ! "$(ls -A /workspace/app 2>/dev/null)" ]; then
    echo "📁 Creating sample app structure..."
    cd /workspace/app
    
    # Create a simple .NET web app structure
    cat > README.md << 'EOF'
# Sample Container Application

This directory contains a sample application that can be containerized and deployed to Azure.

## Getting Started

1. Build the application:
   ```bash
   cd app
   docker build -t myapp .
   ```

2. Run locally:
   ```bash
   docker run -p 8080:80 myapp
   ```

3. Deploy to Azure Container Registry (after terraform apply):
   ```bash
   # Tag and push to ACR
   docker tag myapp <acr-name>.azurecr.io/myapp:latest
   docker push <acr-name>.azurecr.io/myapp:latest
   ```
EOF

    # Create a simple Dockerfile
    cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copy static content
COPY index.html /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

    # Create a simple index.html
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Azure App Config Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f0f2f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #0078d4; }
        .config { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Azure App Config Demo</h1>
        <p>This is a sample application demonstrating Azure App Configuration integration.</p>
        
        <div class="config">
            <h3>Configuration Values</h3>
            <p><strong>TEST_KEY:</strong> <span id="test-key">Loading...</span></p>
            <p><strong>TEST_SECRET:</strong> <span id="test-secret">Loading...</span></p>
        </div>
        
        <p>Replace this with your actual application that reads from Azure App Configuration using managed identity.</p>
    </div>
    
    <script>
        // In a real app, these would come from your backend API
        // that reads from Azure App Configuration
        document.getElementById('test-key').textContent = 'This is a test key in the app config';
        document.getElementById('test-secret').textContent = '****** (Secret from Key Vault)';
    </script>
</body>
</html>
EOF
fi

echo "✅ Development environment setup complete!"
echo ""
echo "🔧 Available tools:"
echo "  - Terraform (terraform)"
echo "  - Azure CLI (az)"
echo "  - Azure Developer CLI (azd)"  
echo "  - Docker (docker)"
echo "  - kubectl"
echo "  - Helm"
echo "  - .NET SDK"
echo "  - Node.js"
echo "  - Python"
echo ""
echo "📁 Workspace structure:"
echo "  - /workspace (root) - Terraform infrastructure"
echo "  - /workspace/app - Container application code"
echo ""
echo "🚀 Next steps:"
echo "  1. Run 'az login' to authenticate with Azure"
echo "  2. Run 'terraform plan' to see what will be created"
echo "  3. Run 'terraform apply' to deploy infrastructure"
echo "  4. Build and deploy your app in the /workspace/app directory"
