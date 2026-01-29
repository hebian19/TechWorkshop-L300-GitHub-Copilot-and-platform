# ZavaStorefront - Azure Infrastructure Workshop

This lab guides you through a series of practical exercises focused on modernising Zava's business applications and databases by migrating everything to Azure, leveraging GitHub Enterprise, Copilot, and Azure services. Each exercise is designed to deliver hands-on experience in governance, automation, security, AI integration, and observability, ensuring Zava's transition to Azure is robust, secure, and future-ready.

## Project Overview

The ZavaStorefront is a modern e-commerce web application built with ASP.NET Core and deployed on Azure using containerization and Azure OpenAI services for enhanced customer experiences.

### Architecture

- **Frontend/Backend**: ASP.NET Core 8.0 web application
- **Hosting**: Azure App Service (Linux) with Docker containers
- **Container Registry**: Azure Container Registry (ACR) with RBAC authentication
- **AI/ML**: Azure OpenAI Service (GPT-4o) for intelligent features
- **Monitoring**: Application Insights with Log Analytics
- **Infrastructure**: Azure Bicep with Azure Developer CLI (azd)

## Quick Start

### Prerequisites
- Azure subscription
- Azure CLI and Azure Developer CLI (azd)
- Git

### Deploy to Azure

```bash
# Clone the repository
git clone https://github.com/sfmc-lab/TechWorkshop-L300-GitHub-Copilot-and-platform.git
cd TechWorkshop-L300-GitHub-Copilot-and-platform

# Login and initialize
azd auth login
azd init

# Deploy infrastructure and application
azd up
```

For detailed deployment instructions, see:
- 📖 [Deployment Quick Start Guide](docs/DEPLOYMENT_QUICKSTART.md)
- 📖 [Infrastructure Documentation](infra/README.md)

## Repository Structure

```
.
├── src/                    # ASP.NET Core application source code
├── infra/                  # Azure Bicep infrastructure as code
│   ├── main.bicep         # Main orchestration file
│   ├── modules/           # Reusable Bicep modules
│   └── README.md          # Infrastructure documentation
├── docs/                   # Workshop documentation
├── Dockerfile             # Container image definition
├── azure.yaml             # Azure Developer CLI configuration
└── README.md              # This file
```

## Azure Resources

The infrastructure provisions the following Azure resources in a single resource group:

| Resource | Purpose | Configuration |
|----------|---------|---------------|
| **Resource Group** | Container for all resources | Region: westus3 |
| **App Service Plan** | Linux hosting plan | Tier: Basic (B1) |
| **App Service** | Web application host | Linux + Docker support |
| **Container Registry** | Docker image storage | RBAC authentication |
| **Application Insights** | Monitoring & telemetry | Linked to Log Analytics |
| **Log Analytics** | Centralized logging | 30-day retention |
| **Azure OpenAI** | AI/ML capabilities | GPT-4o deployment |

### Security Features
- ✅ Managed identities (no passwords/connection strings)
- ✅ RBAC-based ACR access
- ✅ HTTPS enforcement
- ✅ TLS 1.2+ minimum
- ✅ ACR admin credentials disabled

## Development

### Local Development

```bash
# Navigate to source directory
cd src

# Restore dependencies
dotnet restore

# Run locally
dotnet run
```

### Build Docker Image Locally (Optional)

```bash
# Build image
docker build -t zavastore:latest .

# Run container locally
docker run -p 8080:80 zavastore:latest
```

## Documentation

- [📘 Infrastructure Documentation](infra/README.md) - Detailed infrastructure guide
- [🚀 Deployment Quick Start](docs/DEPLOYMENT_QUICKSTART.md) - Step-by-step deployment
- [📚 Workshop Exercises](docs/) - Complete workshop materials

## Cost Estimation

Typical monthly costs for development environment:
- App Service (B1): ~$13/month
- Container Registry (Basic): ~$5/month  
- Application Insights: ~$2-5/month
- Log Analytics: First 5GB free
- Azure OpenAI: Pay-per-token (~$10-50/month)

**Total**: ~$30-90/month for dev workloads

💡 Use `azd down` to delete resources when not in use.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
