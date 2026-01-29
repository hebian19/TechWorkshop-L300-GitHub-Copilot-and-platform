@description('Name of the App Service')
param name string

@description('Azure region for the resource')
param location string

@description('Name of the existing App Service Plan')
param appServicePlanName string

@description('Name of the existing Container Registry')
param containerRegistryName string

@description('Name of the existing Application Insights')
param applicationInsightsName string

// Reference existing App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

// Reference existing Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

// Reference existing Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: 'app,linux,container'
  
  // CRITICAL: Enable System Assigned Managed Identity for identity-based authentication
  identity: {
    type: 'SystemAssigned'
  }
  
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/zavastore:latest'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        // NOTE: No API keys are stored here - identity-based access is used
      ]
    }
  }
}

@description('The default hostname of the App Service')
output defaultHostname string = 'https://${appService.properties.defaultHostName}'

@description('The principal ID of the App Service managed identity')
output principalId string = appService.identity.principalId

@description('The resource ID of the App Service')
output id string = appService.id

@description('The name of the App Service')
output name string = appService.name
