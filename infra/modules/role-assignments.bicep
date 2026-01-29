@description('Name of the Azure AI Services account')
param aiServicesName string

@description('Principal ID of the App Service managed identity')
param appServicePrincipalId string

// Built-in role definition IDs
// Cognitive Services OpenAI User - allows read access to OpenAI resources
var cognitiveServicesOpenAIUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

// Reference existing AI Services account
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: aiServicesName
}

// CRITICAL: Role assignment for App Service to access Azure AI Services using managed identity
// This enables identity-only access without API keys
resource aiServicesRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.id, appServicePrincipalId, cognitiveServicesOpenAIUserRoleId)
  scope: aiServices
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAIUserRoleId)
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
    description: 'Allow App Service to access Azure AI Services using managed identity'
  }
}

@description('The role assignment ID')
output roleAssignmentId string = aiServicesRoleAssignment.id
