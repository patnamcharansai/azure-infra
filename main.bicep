// This Bicep file sets up the foundational resource groups for a hub-and-spoke network architecture.
// It creates resource groups at the subscription level for hub and spoke environments.

// Set the deployment scope to the subscription level (allows creating resource groups across the sub)
targetScope = 'subscription'

// Parameter: Azure region for deploying resources
@description('Azure region where resources will be deployed')
param location string

// Parameter: Name of the project, used in naming conventions
@description('Project name used to build resource group names')
param projectName string

// Parameter: Deployment environment (defaults to 'dev')
@description('Deployment environment (dev, prod, test)')
param environment string = 'dev'

// Parameter: Name for the hub resource group (auto-generated)
@description('Resource group name for hub network')
param hubRgName string = 'rg-${projectName}-${environment}hub'

// Parameter: Name for the spoke resource group (auto-generated)
@description('Resource group name for spoke network')
param spokeRgName string = 'rg-${projectName}-${environment}spoke'

// Resource: Create the hub resource group
resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  // Name of the resource group
  name: hubRgName
  // Location for the resource group
  location: location
}

// Resource: Create the spoke resource group
resource spokeRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  // Name of the resource group
  name: spokeRgName
  // Location for the resource group
  location: location
}
