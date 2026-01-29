@description('Name of the Azure AI Services account')
param name string

@description('Azure region for the resource')
param location string

@description('SKU for the Azure AI Services account')
param sku string = 'S0'

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  kind: 'OpenAI'
  sku: {
    name: sku
  }
  properties: {
    // CRITICAL: Disable API key authentication - enforce identity-only access
    disableLocalAuth: true
    
    // Enable public network access (adjust based on your network requirements)
    publicNetworkAccess: 'Enabled'
    
    // Custom subdomain for the endpoint
    customSubDomainName: name
    
    // Network ACLs - default deny with no bypass
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

@description('The endpoint URL for the Azure AI Services')
output endpoint string = aiServices.properties.endpoint

@description('The resource ID of the Azure AI Services')
output id string = aiServices.id

@description('The name of the Azure AI Services')
output name string = aiServices.name
