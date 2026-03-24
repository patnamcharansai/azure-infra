targetScope = 'resourceGroup'

@description('Project name')
param projectName string

@description('Deployment environment (dev, prod, test)')
param environment string

@description('Hub VNet name')
param hubVnetName string = 'vnet-hub-${projectName}-${environment}'

@description('Hub VNet address space')
param hubAddressSpace array = [
  '10.0.0.0/16'
]

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: hubVnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: hubAddressSpace
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: { addressPrefix: '10.0.1.0/24' }
      }
      {
        name: 'GatewaySubnet'
        properties: { addressPrefix: '10.0.2.0/24' }
      }
    ]
  }
}
