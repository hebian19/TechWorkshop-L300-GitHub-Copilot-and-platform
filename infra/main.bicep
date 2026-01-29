targetScope = 'resourceGroup'

@description('The base name for all resources')
param baseName string

@description('The Azure region for resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
param environmentName string = 'dev'

// Existing resources - reference by name
@description('Name of the existing Azure AI Services account')
param aiServicesName string

@description('Name of the existing App Service')
param appServiceName string

@description('Name of the existing App Service Plan')
param appServicePlanName string

@description('Name of the existing Container Registry')
param containerRegistryName string

@description('Name of the existing Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('Name of the existing Application Insights')
param applicationInsightsName string

// Import modules
module aiServices 'modules/ai-services.bicep' = {
  name: 'ai-services-deployment'
  params: {
    name: aiServicesName
    location: location
  }
}

module appService 'modules/app-service.bicep' = {
  name: 'app-service-deployment'
  params: {
    name: appServiceName
    location: location
    appServicePlanName: appServicePlanName
    containerRegistryName: containerRegistryName
    applicationInsightsName: applicationInsightsName
  }
}

module roleAssignments 'modules/role-assignments.bicep' = {
  name: 'role-assignments-deployment'
  params: {
    aiServicesName: aiServicesName
    appServicePrincipalId: appService.outputs.principalId
  }
  dependsOn: [
    aiServices
    appService
  ]
}

// Outputs
output appServiceUrl string = appService.outputs.defaultHostname
output aiServicesEndpoint string = aiServices.outputs.endpoint
output appServicePrincipalId string = appService.outputs.principalId
