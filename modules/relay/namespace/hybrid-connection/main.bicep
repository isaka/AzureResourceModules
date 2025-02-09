metadata name = 'Relay Namespace Hybrid Connections'
metadata description = 'This module deploys a Relay Namespace Hybrid Connection.'
metadata owner = 'Azure/module-maintainers'

@description('Conditional. The name of the parent Relay Namespace for the Relay Hybrid Connection. Required if the template is used in a standalone deployment.')
@minLength(6)
@maxLength(50)
param namespaceName string

@description('Required. The name of the hybrid connection.')
@minLength(6)
@maxLength(50)
param name string

@description('Required. The user metadata is a placeholder to store user-defined string data for the hybrid connection endpoint. For example, it can be used to store descriptive data, such as a list of teams and their contact information. Also, user-defined configuration settings can be stored.')
param userMetadata string

@description('Optional. A value indicating if this hybrid connection requires client authorization.')
param requiresClientAuthorization bool = true

@description('Optional. Authorization Rules for the Relay Hybrid Connection.')
param authorizationRules array = [
  {
    name: 'RootManageSharedAccessKey'
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
  {
    name: 'defaultListener'
    rights: [
      'Listen'
    ]
  }
  {
    name: 'defaultSender'
    rights: [
      'Send'
    ]
  }
]

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments roleAssignmentType

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

var enableReferencedModulesTelemetry = false

var builtInRoleNames = {
  'Azure Relay Listener': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '26e0b698-aa6d-4085-9386-aadae190014d')
  'Azure Relay Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2787bf04-f1f5-4bfe-8383-c8a24483ee38')
  'Azure Relay Sender': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '26baccc8-eea7-41f1-98f4-1762cc7f685d')
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator (Preview)': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f58310d9-a9f6-439a-9e8d-f62e7b41a168')
  'User Access Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
}

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource namespace 'Microsoft.Relay/namespaces@2021-11-01' existing = {
  name: namespaceName
}

resource hybridConnection 'Microsoft.Relay/namespaces/hybridConnections@2021-11-01' = {
  name: name
  parent: namespace
  properties: {
    requiresClientAuthorization: requiresClientAuthorization
    userMetadata: userMetadata
  }
}

module hybridConnection_authorizationRules 'authorization-rule/main.bicep' = [for (authorizationRule, index) in authorizationRules: {
  name: '${deployment().name}-AuthorizationRule-${index}'
  params: {
    namespaceName: namespaceName
    hybridConnectionName: hybridConnection.name
    name: authorizationRule.name
    rights: contains(authorizationRule, 'rights') ? authorizationRule.rights : []
    enableDefaultTelemetry: enableReferencedModulesTelemetry
  }
}]

resource hybridConnection_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.'
  }
  scope: hybridConnection
}

resource hybridConnection_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, index) in (roleAssignments ?? []): {
  name: guid(hybridConnection.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName) ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName] : roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    description: roleAssignment.?description
    principalType: roleAssignment.?principalType
    condition: roleAssignment.?condition
    conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
    delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
  }
  scope: hybridConnection
}]

@description('The name of the deployed hybrid connection.')
output name string = hybridConnection.name

@description('The resource ID of the deployed hybrid connection.')
output resourceId string = hybridConnection.id

@description('The resource group of the deployed hybrid connection.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}?

type roleAssignmentType = {
  @description('Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device' | null)?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?
