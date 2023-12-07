param acrName string 
param appServicePlanName string
param webAppName string ='zdakhqan-webapp'
param location string = 'Sweden'
param containerRegistryImageName string = 'flask-demo'
param containerRegistryImageVersion string = 'latest'
param DOCKER_REGISTRY_SERVER_USERNAME string 
@secure()
param DOCKER_REGISTRY_SERVER_PASSWORD string
param DOCKER_REGISTRY_SERVER_URL string 

module registry './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: acrName
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
  }
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

module site './ResourceModules-main/modules/web/site/main.bicep' = {
  name: 'siteModule'
  params: {
    kind: 'app'
    name: webAppName
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${containerRegistryImageName }:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs : {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: DOCKER_REGISTRY_SERVER_URL 
      DOCKER_REGISTRY_SERVER_USERNAME: DOCKER_REGISTRY_SERVER_USERNAME
      DOCKER_REGISTRY_SERVER_PASSWORD: DOCKER_REGISTRY_SERVER_PASSWORD
    }
  }
}
