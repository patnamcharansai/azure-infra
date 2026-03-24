targetScope = 'subscription'

@description('Azure region where resources will be deployed')
param location string

@description('Project name used to build resource group names')
param projectName string

@description('Deployment environment (dev, prod, test)')
param environment string = 'dev'

@description('Resource group name for hub network')
param hubRgName string = 'rg-${projectName}-${environment}hub'

@description('Resource group name for spoke network')
param spokeRgName string = 'rg-${projectName}-${environment}spoke'

resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: hubRgName
  location: location
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: spokeRgName
  location: location
}
