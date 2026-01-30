# Azure Infrastructure Deployment - Quick Start Guide

This guide provides step-by-step instructions for deploying the ZavaStorefront infrastructure to Azure using Azure Developer CLI (azd).

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Deployment Steps](#deployment-steps)
4. [Post-Deployment](#post-deployment)
5. [Verification](#verification)
6. [Next Steps](#next-steps)

## Prerequisites

Before you begin, ensure you have:

- ✅ An active Azure subscription ([Free trial available](https://azure.microsoft.com/free/))
- ✅ Permissions to create resources in Azure (Contributor role or higher)
- ✅ A GitHub account (for source code access)
- ✅ Basic familiarity with command-line interfaces

## Installation

### 1. Install Azure CLI

#### Windows
```powershell
# Using winget
winget install Microsoft.AzureCLI

# Or download the MSI installer from:
# https://learn.microsoft.com/cli/azure/install-azure-cli-windows
```

#### macOS
```bash
brew update && brew install azure-cli
```

#### Linux
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Verify installation:
```bash
az --version
```

### 2. Install Azure Developer CLI (azd)

#### Windows
```powershell
# Using winget
winget install Microsoft.Azd

# Or using PowerShell
powershell -ex AllSigned -c "Invoke-RestMethod 'https://aka.ms/install-azd.ps1' | Invoke-Expression"
```

#### macOS/Linux
```bash
curl -fsSL https://aka.ms/install-azd.sh | bash
```

Verify installation:
```bash
azd version
```

### 3. Clone the Repository

```bash
git clone https://github.com/sfmc-lab/TechWorkshop-L300-GitHub-Copilot-and-platform.git
cd TechWorkshop-L300-GitHub-Copilot-and-platform
```

## Deployment Steps

### Step 1: Login to Azure

```bash
# Login to Azure (opens browser for authentication)
azd auth login

# Alternatively, if you're already logged in with Azure CLI:
az login
```

### Step 2: Initialize the Environment

```bash
# Initialize azd environment
azd init

# You'll be prompted for:
# 1. Environment name: Enter "dev" (or your preferred name)
# 2. Azure subscription: Select from the list
# 3. Azure location: Enter "westus3" (recommended)
```

**Note**: The environment name will be used in resource naming (e.g., `rg-zavastore-dev-westus3`).

### Step 3: Provision Infrastructure

```bash
# Deploy all Azure resources
azd provision
```

This command will:
1. ✅ Validate Bicep templates
2. ✅ Create a resource group in westus3
3. ✅ Deploy Log Analytics workspace
4. ✅ Deploy Application Insights
5. ✅ Create Azure Container Registry
6. ✅ Deploy Linux App Service with Docker support
7. ✅ Configure Azure OpenAI Service with GPT-4o
8. ✅ Set up RBAC permissions for ACR access
9. ✅ Configure Application Insights integration

**Expected Duration**: 5-10 minutes

### Step 4: Deploy Application (Optional)

```bash
# Build and deploy the containerized application
azd deploy
```

This will:
1. Build the Docker image from the Dockerfile
2. Push the image to Azure Container Registry
3. Update the App Service to use the new image
4. Restart the App Service

**Alternative**: Deploy everything at once:
```bash
# Provision infrastructure AND deploy application
azd up
```

## Post-Deployment

### Review Deployment Outputs

After successful deployment, azd will display important outputs:

```
AZURE_RESOURCE_GROUP: rg-zavastore-dev-westus3
AZURE_CONTAINER_REGISTRY_NAME: acrzavastoreXXXXX
AZURE_APP_SERVICE_NAME: app-zavastoreXXXXX
AZURE_APP_SERVICE_URL: https://app-zavastoreXXXXX.azurewebsites.net
AZURE_AI_FOUNDRY_ENDPOINT: https://ai-zavastoreXXXXX.openai.azure.com/
```

These values are automatically saved in `.azure/dev/.env` for use by your application.

### Access Your Resources

#### Azure Portal
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to "Resource Groups"
3. Find `rg-zavastore-dev-westus3`
4. Explore your deployed resources

#### Application URL
Open the `AZURE_APP_SERVICE_URL` in your browser:
```bash
# From the terminal
echo "https://$(azd env get-value AZURE_APP_SERVICE_NAME).azurewebsites.net"
```

## Verification

### 1. Verify Resource Group

```bash
az group show --name rg-zavastore-dev-westus3
```

### 2. List All Resources

```bash
az resource list --resource-group rg-zavastore-dev-westus3 --output table
```

Expected resources:
- App Service Plan (plan-zavastore-XXXXX)
- App Service (app-zavastore-XXXXX)
- Container Registry (acrzavastoreXXXXX)
- Application Insights (appi-zavastore-XXXXX)
- Log Analytics Workspace (log-zavastore-XXXXX)
- Azure OpenAI Account (ai-zavastore-XXXXX)

### 3. Test App Service

```bash
# Get the App Service URL
APP_URL=$(azd env get-value AZURE_APP_SERVICE_URL)
echo "App URL: $APP_URL"

# Test the endpoint
curl -I $APP_URL
```

### 4. Verify Container Registry

```bash
ACR_NAME=$(azd env get-value AZURE_CONTAINER_REGISTRY_NAME)
az acr repository list --name $ACR_NAME
```

### 5. Check Application Insights

```bash
# View App Insights in Azure Portal
az monitor app-insights component show \
  --app appi-zavastore-XXXXX \
  --resource-group rg-zavastore-dev-westus3
```

### 6. Verify Azure OpenAI Deployment

```bash
AI_NAME=$(azd env get-value AZURE_AI_FOUNDRY_NAME)
RG_NAME=$(azd env get-value AZURE_RESOURCE_GROUP)

# List deployments
az cognitiveservices account deployment list \
  --name $AI_NAME \
  --resource-group $RG_NAME
```

Expected output should show `gpt-4o` deployment.

## Next Steps

### 1. Configure Application Settings

Add custom environment variables to your App Service:

```bash
az webapp config appsettings set \
  --name <app-service-name> \
  --resource-group <rg-name> \
  --settings KEY1=value1 KEY2=value2
```

### 2. View Application Logs

```bash
# Stream logs from App Service
az webapp log tail \
  --name <app-service-name> \
  --resource-group <rg-name>
```

### 3. Scale Resources (if needed)

```bash
# Scale App Service Plan
az appservice plan update \
  --name <plan-name> \
  --resource-group <rg-name> \
  --sku P1V2
```

### 4. Set Up Continuous Deployment

Configure GitHub Actions or Azure DevOps pipelines to automate deployments:

```bash
# Generate GitHub Actions workflow
azd pipeline config
```

### 5. Monitor with Application Insights

1. Open Azure Portal
2. Navigate to Application Insights resource
3. Explore:
   - Live Metrics
   - Performance
   - Failures
   - Application Map

### 6. Use Azure OpenAI Service

Get the endpoint and keys:

```bash
# Get endpoint
AI_ENDPOINT=$(azd env get-value AZURE_AI_FOUNDRY_ENDPOINT)
echo "Azure OpenAI Endpoint: $AI_ENDPOINT"

# Get API key (for testing - use managed identity in production)
az cognitiveservices account keys list \
  --name $AI_NAME \
  --resource-group $RG_NAME
```

## Managing Environments

### Create Additional Environments

```bash
# Create a staging environment
azd env new staging
azd provision

# Switch between environments
azd env select dev
azd env select staging
```

### Update Infrastructure

After modifying Bicep files:

```bash
# Preview changes
azd provision --preview

# Apply changes
azd provision
```

### Delete Resources

```bash
# Delete all resources in the current environment
azd down

# Delete with confirmation bypass
azd down --force

# Delete and purge soft-deleted resources
azd down --purge
```

## Troubleshooting

### Issue: Region doesn't support service

**Solution**: Change the region
```bash
azd env set AZURE_LOCATION eastus
azd provision
```

### Issue: Insufficient quota

**Solution**: Request quota increase or choose different SKU
```bash
# Check current quotas
az vm list-usage --location westus3 --output table
```

### Issue: RBAC permissions not working

**Solution**: Wait 2-3 minutes for role assignments to propagate, then restart the App Service
```bash
az webapp restart --name <app-name> --resource-group <rg-name>
```

### Issue: Docker image not found

**Solution**: Ensure the image is built and pushed to ACR
```bash
# Build and push manually
docker build -t <acr-name>.azurecr.io/zavastore:latest .
az acr login --name <acr-name>
docker push <acr-name>.azurecr.io/zavastore:latest
```

### Get Help

```bash
# View azd help
azd --help

# View help for specific command
azd provision --help

# Check azd status
azd env list
azd env get-values
```

## Useful Commands Reference

```bash
# Authentication
azd auth login                    # Login to Azure
azd auth logout                   # Logout from Azure

# Environment Management
azd init                          # Initialize new environment
azd env list                      # List all environments
azd env select <name>             # Switch environment
azd env get-values                # Show environment variables
azd env set <key> <value>         # Set environment variable

# Deployment
azd provision                     # Deploy infrastructure only
azd deploy                        # Deploy application only
azd up                            # Provision + Deploy
azd down                          # Delete all resources

# Monitoring
azd monitor                       # Open Application Insights

# Pipeline
azd pipeline config               # Configure CI/CD pipeline
```

## Resources

- 📖 [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- 📖 [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- 📖 [App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- 📖 [Azure OpenAI Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- 💬 [GitHub Discussions](https://github.com/Azure/azure-dev/discussions)

## Cost Management

Monitor costs in the Azure Portal:
1. Go to "Cost Management + Billing"
2. Select "Cost analysis"
3. Filter by resource group: `rg-zavastore-dev-westus3`

Set up budget alerts:
```bash
# Create a budget (example: $100/month)
az consumption budget create \
  --budget-name zavastore-dev-budget \
  --amount 100 \
  --resource-group rg-zavastore-dev-westus3 \
  --time-grain Monthly
```

---

**🎉 Congratulations!** You've successfully deployed the ZavaStorefront infrastructure to Azure.

For detailed documentation about the infrastructure components, see [infra/README.md](../infra/README.md).
