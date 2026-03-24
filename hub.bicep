// This Bicep file defines the hub virtual network (VNet) for the Azure infrastructure.
// It creates a VNet with subnets for Azure Firewall and VPN Gateway, and optionally Bastion.

// Set the deployment scope to the resource group level (resources will be created in the RG passed during deployment)
targetScope = 'resourceGroup'

// Parameter: Name of the project, used in resource naming
@description('Project name')
param projectName string

// Parameter: Deployment environment (e.g., dev, prod), used in resource naming
@description('Deployment environment (dev, prod, test)')
param environment string

// Parameter: Name for the hub VNet, defaults to a formatted string combining project and environment
@description('Hub VNet name')
param hubVnetName string = 'vnet-hub-${projectName}-${environment}'

// Parameter: Address space for the hub VNet, defaults to 10.0.0.0/16
@description('Hub VNet address space')
param hubAddressSpace array = [
  '10.0.0.0/16'
]

// Resource: Create the hub virtual network
resource hubVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  // Name of the VNet, using the parameter value
  name: hubVnetName
  // Location: Use the location of the resource group
  location: resourceGroup().location
  properties: {
    // Define the address space for the VNet
    addressSpace: {
      addressPrefixes: hubAddressSpace
    }
    // Define the subnets within the VNet
    subnets: [
      // Subnet for Azure Firewall (required name: AzureFirewallSubnet)
      {
        name: 'AzureFirewallSubnet'
        properties: { addressPrefix: '10.0.1.0/24' }
      }
      // Subnet for VPN Gateway (required name: GatewaySubnet)
      {
        name: 'GatewaySubnet'
        properties: { addressPrefix: '10.0.2.0/24' }
      }
      // Commented out: Optional subnet for Azure Bastion (required name: AzureBastionSubnet)
      // Uncomment if Bastion is needed for secure VM access
      /*
      {
        name: 'AzureBastionSubnet'
        properties: { addressPrefix: '10.0.3.0/24' }
      }
      */
      // Commented out: Optional subnet for Azure Application Gateway
      // Uncomment if Application Gateway is needed for load balancing and web traffic management
      /*
      {
        name: 'ApplicationGatewaySubnet'
        properties: { addressPrefix: '10.0.4.0/24' }
      }
      */
    ]
  }
}
