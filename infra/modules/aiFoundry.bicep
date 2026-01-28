@description('Name of the Azure AI Services resource')
param name string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object = {}

@description('SKU for the AI Services')
@allowed(['S0', 'F0'])
param sku string = 'S0'

// Azure AI Services (formerly Cognitive Services)
resource aiServices 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// GPT-4o model deployment (available in westus3 with GlobalStandard)
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    name: 'GlobalStandard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
    raiPolicyName: 'Microsoft.Default'
  }
}

// Note: Phi models can be added via Azure Portal after deployment
// Model availability varies by region and subscription

output id string = aiServices.id
output name string = aiServices.name
output endpoint string = aiServices.properties.endpoint
output principalId string = aiServices.identity.principalId
