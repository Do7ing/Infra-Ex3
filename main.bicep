param acrName string 
param location string 
param appServicePlanName string
param webAppName string ='zdakhqan-webapp'
param containerRegistryImageName string = 'flask-demo'
param containerRegistryImageVersion string = 'latest'

param keyVaultName string
param keyVaultSecretNameACRUsername string = 'acr-username'
param keyVaultSecretNameACRPassword1 string = 'acr-password1'

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
 }

// Azure Container Registry module
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
 }

module serverfarm './ResourceModules-main/modules/web/serverfarm/main.bicep' = {
  name: '${appServicePlanName}-deploy'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

// Azure Web App for Linux containers module
module site './ResourceModules-main/modules/web/site/main.bicep' = {
  name: webAppName
  dependsOn: [
    serverfarm
    acr
    keyvault
  ]
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: serverfarm.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
    }
    dockerRegistryServerUrl: 'https://${acrName}.azurecr.io'
    dockerRegistryServerUserName: keyvault.getSecret(keyVaultSecretNameACRUsername)
    dockerRegistryServerPassword: keyvault.getSecret(keyVaultSecretNameACRPassword1)
  }
}
