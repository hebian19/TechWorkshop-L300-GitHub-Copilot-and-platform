# Azure Infrastructure for ZavaStorefront

This directory contains Bicep Infrastructure as Code (IaC) files for provisioning the ZavaStorefront web application on Azure using Azure Developer CLI (azd).

## Architecture Overview

The infrastructure provisions a complete development environment in Azure with the following components:

### Core Resources
- **Resource Group**: Single resource group containing all resources
- **Linux App Service**: Web app for hosting the containerized ZavaStorefront application
- **App Service Plan**: Linux-based plan supporting container deployments (B1 tier for dev)
- **Azure Container Registry (ACR)**: Private registry for Docker images with RBAC authentication
- **Application Insights**: Application monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging and analytics

### AI/ML Resources
- **Azure OpenAI Service (Microsoft Foundry)**: Cognitive Services account with GPT-4o deployment
  - GPT-4o model deployed with GlobalStandard SKU (available in westus3)
  - Uses system-assigned managed identity

## Security Features

✅ **RBAC-based Authentication**: App Service uses managed identity to pull images from ACR (no passwords)
✅ **HTTPS Only**: App Service enforces HTTPS connections
✅ **Managed Identities**: System-assigned identities for App Service and Azure OpenAI
✅ **TLS 1.2+**: Minimum TLS version enforced
✅ **Admin User Disabled**: ACR admin credentials disabled

## Prerequisites

Before deploying, ensure you have:

1. **Azure CLI** installed ([Install Guide](https://learn.microsoft.com/cli/azure/install-azure-cli))
2. **Azure Developer CLI (azd)** installed ([Install Guide](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd))
3. **Azure Subscription** with appropriate permissions to create resources
4. **Docker** (optional, only needed for local image builds)

## Quick Start

### 1. Initialize Azure Developer CLI

```bash
# Login to Azure
azd auth login

# Initialize the environment (first time only)
azd init

# When prompted:
# - Environment name: dev (or your preferred name)
# - Azure subscription: Select your subscription
# - Azure location: westus3 (required for this configuration)
```

### 2. Deploy Infrastructure

```bash
# Provision all Azure resources
azd provision

# This will:
# - Create the resource group
# - Deploy all Bicep modules
# - Configure RBAC permissions
# - Output connection strings and endpoints
```

### 3. Deploy Application (Optional)

```bash
# Build and deploy the application
azd deploy

# Or do both provision and deploy in one command
azd up
```

## Configuration

### Environment Variables

The deployment uses these environment variables (automatically managed by azd):

- `AZURE_ENV_NAME`: Environment name (e.g., dev, staging, prod)
- `AZURE_LOCATION`: Azure region (default: westus3)
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

### Parameters

You can customize the deployment by modifying `main.parameters.json`:

```json
{
  "environmentName": {
    "value": "dev"
  },
  "location": {
    "value": "westus3"
  }
}
```

## Resource Naming Convention

Resources follow Azure naming best practices:

| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Resource Group | `rg-{appName}-{env}-{location}` | `rg-zavastore-dev-westus3` |
| App Service Plan | `plan-{appName}-{token}` | `plan-zavastore-abc123` |
| Web App | `app-{appName}-{token}` | `app-zavastore-abc123` |
| Container Registry | `acr{appName}{token}` | `acrzavastoreab123` |
| App Insights | `appi-{appName}-{token}` | `appi-zavastore-abc123` |
| Log Analytics | `log-{appName}-{token}` | `log-zavastore-abc123` |
| AI Services | `ai-{appName}-{token}` | `ai-zavastore-abc123` |

*Note: `{token}` is a unique string generated from subscription ID, environment, and location to ensure globally unique names.*

## Modules

### main.bicep
Main orchestration file that:
- Creates the resource group at subscription scope
- Calls all module deployments
- Defines outputs for downstream consumption

### modules/logAnalytics.bicep
Provisions Log Analytics workspace with:
- PerGB2018 pricing tier
- 30-day retention period
- 1GB daily quota cap for cost management

### modules/appInsights.bicep
Creates Application Insights resource:
- Linked to Log Analytics workspace
- Web application type
- Connection string output for app configuration

### modules/acr.bicep
Deploys Azure Container Registry:
- Basic SKU (suitable for dev environments)
- Admin user disabled (RBAC only)
- Public network access enabled
- 7-day retention policy (disabled by default)

### modules/appService.bicep
Provisions Linux App Service with:
- Linux-based App Service Plan (B1 tier)
- Container deployment support
- System-assigned managed identity
- AcrPull role assignment for image pulls
- Application Insights integration
- Docker configuration for ACR

### modules/aiFoundry.bicep
Creates Azure OpenAI Service:
- OpenAI account type
- S0 (Standard) SKU
- GPT-4o model deployment (GlobalStandard, 10K TPM capacity)
- System-assigned managed identity
- Custom subdomain for API access

## Regional Considerations

### westus3 Region
The infrastructure is configured for **westus3** which supports:
- ✅ All App Service and Container Registry features
- ✅ Application Insights and Log Analytics
- ✅ Azure OpenAI Service (OpenAI kind)
- ✅ GPT-4o with GlobalStandard deployment

### AI Model Availability
- **GPT-4o**: Available via GlobalStandard deployment (2024-08-06 version)
- **Phi Models**: May require manual configuration via Azure Portal after initial deployment
  - Model availability varies by subscription and capacity
  - Check [Azure OpenAI Models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models) for current availability

## Deployment Outputs

After successful deployment, azd provides these outputs:

```bash
AZURE_RESOURCE_GROUP              # Resource group name
AZURE_CONTAINER_REGISTRY_NAME     # ACR name
AZURE_CONTAINER_REGISTRY_ENDPOINT # ACR login server
AZURE_APP_SERVICE_NAME            # App Service name
AZURE_APP_SERVICE_URL             # Application URL
AZURE_AI_FOUNDRY_NAME             # Azure OpenAI account name
AZURE_AI_FOUNDRY_ENDPOINT         # Azure OpenAI endpoint URL
APPLICATIONINSIGHTS_CONNECTION_STRING  # App Insights connection string
```

These values are automatically stored in `.azure/{environment}/.env` and can be used by the application.

## Updating Infrastructure

To update the infrastructure after making changes to Bicep files:

```bash
# Preview changes
azd provision --preview

# Apply changes
azd provision
```

## Cleanup

To delete all resources:

```bash
# Delete all resources and the resource group
azd down

# Delete with purge (removes soft-deleted resources like Key Vaults, AI Services)
azd down --purge
```

## Troubleshooting

### Common Issues

1. **Region Capacity**: If you encounter capacity issues in westus3, you can change the location:
   ```bash
   azd env set AZURE_LOCATION eastus
   azd provision
   ```

2. **Quota Limits**: Check your subscription quotas for:
   - App Service Plans
   - Container Registries
   - Azure OpenAI Service

3. **Role Assignment Delays**: RBAC role assignments can take a few minutes to propagate. If the App Service can't pull images immediately, wait 2-3 minutes.

4. **AI Model Deployment**: If GPT-4o deployment fails, verify:
   - Your subscription has Azure OpenAI access
   - The region supports the requested model
   - You have available quota

### Validation

To validate the deployment:

```bash
# Check resource group exists
az group show --name rg-zavastore-dev-westus3

# List all resources
az resource list --resource-group rg-zavastore-dev-westus3 --output table

# Test App Service
az webapp show --name <app-service-name> --resource-group <rg-name>

# Verify ACR
az acr list --resource-group <rg-name> --output table
```

## Cost Considerations

Estimated monthly costs for dev environment (as of 2024):
- App Service Plan (B1): ~$13/month
- Azure Container Registry (Basic): ~$5/month
- Application Insights: Pay-per-use (~$2-5/month for dev workloads)
- Log Analytics: First 5GB free, then ~$2.50/GB
- Azure OpenAI (S0): Pay-per-token (~$10-50/month depending on usage)

**Total**: ~$30-90/month for typical dev usage

💡 **Tip**: To minimize costs, use `azd down` to delete resources when not in use.

## Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section above
2. Review Azure service health and quotas
3. Open an issue in the repository
