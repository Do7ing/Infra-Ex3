param location string
param keyVaultName string
param acrName string
param keyVaultSecretNameACRUsername string ='acr-username'
param keyVaultSecretNameACRPassword1 string ='acr-password1'

module keyvault './ResourceModules-main/modules/key-vault/vault/main.bicep' = {
  name: keyVaultName
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module acr './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: acrName
  dependsOn: [
    keyvault
  ]
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
  }
}
