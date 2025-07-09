#!/bin/bash

# Post-start script for Azure App Config Demo devcontainer
echo "🔄 Running post-start setup..."

# Check if already logged into Azure
if ! az account show >/dev/null 2>&1; then
    echo "⚠️  Not logged into Azure. Run 'az login' to authenticate."
fi

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "⚠️  Terraform not initialized. Run 'terraform init' to initialize."
fi

# Display current Azure context if logged in
if az account show >/dev/null 2>&1; then
    echo "☁️  Current Azure context:"
    az account show --query "{subscriptionId:id, subscriptionName:name, tenantId:tenantId}" -o table
fi

# Check if app directory exists and has content
if [ -d "app" ] && [ "$(ls -A app)" ]; then
    echo "📱 App directory detected with content"
else
    echo "📁 App directory is empty or missing - sample content was created during setup"
fi

echo "✅ Post-start setup complete!"
