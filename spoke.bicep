targetScope = 'resourceGroup'

@description('Project name')
param projectName string

@description('Deployment environment (dev, prod, test)')
param environment string

@description('Spoke VNet name')
param spokeVnetName string = 'vnet-spoke-${projectName}-${environment}'

@description('Address space for spoke VNet')
param spokeAddressSpace array = [
  '10.1.0.0/16'
]

resource spokeVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: spokeVnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: spokeAddressSpace
    }
    subnets: [
      {
        name: 'apps-subnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}
