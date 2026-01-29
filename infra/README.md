# Zava Storefront Infrastructure

This folder contains Bicep templates for deploying the Zava Storefront infrastructure to Azure with **identity-only access** (no API keys).

## Security Features

### Identity-Only Access for Azure AI Services

The templates enforce the following security best practices:

1. **API Keys Disabled**: The Azure AI Services account has `disableLocalAuth: true`, which disables API key authentication.

2. **Managed Identity Enabled**: The App Service uses System Assigned Managed Identity for authentication.

3. **RBAC Role Assignment**: The App Service managed identity is granted the `Cognitive Services OpenAI User` role on the Azure AI Services resource.

4. **No Secrets in App Settings**: No API keys or secrets are stored in application settings.

## File Structure

```
infra/
├── main.bicep              # Main orchestration template
├── main.bicepparam         # Parameter file with environment-specific values
├── README.md               # This file
└── modules/
    ├── ai-services.bicep   # Azure AI Services with identity-only auth
    ├── app-service.bicep   # App Service with managed identity
    └── role-assignments.bicep # RBAC assignments for identity-based access
```

## Deployment

### Prerequisites

- Azure CLI installed and configured
- Bicep CLI installed (comes with Azure CLI)
- Appropriate Azure permissions (Owner or User Access Administrator + Contributor)

### Deploy with Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-zavastore-dev-westus3"
LOCATION="westus3"

# Deploy the infrastructure
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

### Deploy with Azure Developer CLI (azd)

If you have `azure.yaml` configured:

```bash
azd provision
```

## Validating Identity-Only Access

After deployment, verify the configuration:

```bash
# Check that API keys are disabled on AI Services
az cognitiveservices account show \
  --name ai-zavastore-pkvnsahglhdpi \
  --resource-group rg-zavastore-dev-westus3 \
  --query "properties.disableLocalAuth"

# Check that managed identity is enabled on App Service
az webapp show \
  --name app-zavastore-pkvnsahglhdpi \
  --resource-group rg-zavastore-dev-westus3 \
  --query "identity.type"

# Check role assignments
az role assignment list \
  --scope "/subscriptions/{subscription-id}/resourceGroups/rg-zavastore-dev-westus3/providers/Microsoft.CognitiveServices/accounts/ai-zavastore-pkvnsahglhdpi" \
  --query "[].{role:roleDefinitionName, principalType:principalType}"
```

## Best Practices Implemented

| Practice | Implementation |
|----------|----------------|
| No API keys | `disableLocalAuth: true` on AI Services |
| Managed Identity | System Assigned identity on App Service |
| Least Privilege | `Cognitive Services OpenAI User` role (read-only) |
| HTTPS Only | `httpsOnly: true` on App Service |
| TLS 1.2+ | `minTlsVersion: '1.2'` on App Service |
| No FTP | `ftpsState: 'Disabled'` on App Service |

## Troubleshooting

### Error: "Access denied" when calling Azure AI Services

1. Verify the managed identity is enabled on the App Service
2. Check that the role assignment exists and uses the correct principal ID
3. Wait a few minutes for RBAC propagation (can take up to 10 minutes)

### Error: "Local authentication is disabled"

This is expected! It confirms that API key access is blocked. Ensure your application code uses `DefaultAzureCredential` or `ManagedIdentityCredential` for authentication.
