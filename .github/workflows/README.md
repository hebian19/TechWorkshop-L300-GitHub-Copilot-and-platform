# GitHub Actions Deployment Setup

This workflow builds and deploys the ZavaStorefront app as a container to Azure App Service.

## Prerequisites

- Azure resources deployed via `azd up` (ACR, App Service, etc.)
- GitHub repository with Actions enabled

## Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions → Secrets** and add:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Service principal or managed identity client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

## Configure GitHub Variables

Go to **Settings → Secrets and variables → Actions → Variables** and add:

| Variable | Example Value |
|----------|---------------|
| `AZURE_CONTAINER_REGISTRY` | `acrzavastorepkvnsahglhdpi` |
| `AZURE_WEBAPP_NAME` | `app-zavastore-pkvnsahglhdpi` |

## Create Federated Credential (OIDC)

```bash
# Create app registration
az ad app create --display-name "github-zavastore"

# Create federated credential for main branch
az ad app federated-credential create \
  --id <APP_OBJECT_ID> \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<OWNER>/<REPO>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Assign roles to the service principal
az role assignment create --assignee <APP_CLIENT_ID> --role "AcrPush" --scope <ACR_RESOURCE_ID>
az role assignment create --assignee <APP_CLIENT_ID> --role "Contributor" --scope <WEBAPP_RESOURCE_ID>
```

## Usage

Push to `main` or `dev` branch to trigger deployment, or run manually from Actions tab.
