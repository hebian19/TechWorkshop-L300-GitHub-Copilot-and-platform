using './main.bicep'

// Environment configuration - update these values to match your deployment
param baseName = 'zavastore'
param location = 'westus3'
param environmentName = 'dev'

// Existing resource names - these should match your deployed resources
param aiServicesName = 'ai-zavastore-pkvnsahglhdpi'
param appServiceName = 'app-zavastore-pkvnsahglhdpi'
param appServicePlanName = 'plan-zavastore-pkvnsahglhdpi'
param containerRegistryName = 'acrzavastorepkvnsahglhdpi'
param logAnalyticsWorkspaceName = 'log-zavastore-pkvnsahglhdpi'
param applicationInsightsName = 'appi-zavastore-pkvnsahglhdpi'
