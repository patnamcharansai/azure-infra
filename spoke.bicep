// This Bicep file defines the spoke virtual network (VNet) for application workloads.
// It creates a VNet with subnets for apps in the spoke resource group.

// Set the deployment scope to the resource group level (resources deploy into the specified RG)
targetScope = 'resourceGroup'

// Parameter: Name of the project, used in resource naming
@description('Project name')
param projectName string

// Parameter: Deployment environment
@description('Deployment environment (dev, prod, test)')
param environment string

// Parameter: Name for the spoke VNet (auto-generated)
@description('Spoke VNet name')
param spokeVnetName string = 'vnet-spoke-${projectName}-${environment}'

// Parameter: Address space for the spoke VNet
@description('Address space for spoke VNet')
param spokeAddressSpace array = [
  '10.1.0.0/16'
]

// Resource: Create the spoke virtual network
resource spokeVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  // Name of the VNet
  name: spokeVnetName
  // Location: Use the resource group's location
  location: resourceGroup().location
  properties: {
    // Define the address space for the VNet
    addressSpace: {
      addressPrefixes: spokeAddressSpace
    }
    // Define subnets within the VNet
    subnets: [
      // Subnet for application workloads
      {
        name: 'apps-subnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}
