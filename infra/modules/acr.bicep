@description('Name of the Azure Container Registry')
param name string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object = {}

@description('SKU for the Container Registry')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    policies: {
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
  }
}

output id string = acr.id
output name string = acr.name
output loginServer string = acr.properties.loginServer
