// This Bicep file deploys a secure Azure Storage Account following enterprise standards.
// It includes encryption, network restrictions, and access controls for data security.

targetScope = 'resourceGroup'

// Parameters for Storage Account configuration
@description('Location for the Storage Account')
param location string = resourceGroup().location

@description('Name of the Storage Account (must be globally unique, lowercase, 3-24 chars)')
param storageAccountName string

@description('SKU for the Storage Account (e.g., Standard_LRS, Standard_GRS)')
param sku string = 'Standard_LRS'

@description('Kind of Storage Account (StorageV2, BlobStorage, etc.)')
param kind string = 'StorageV2'

@description('Access tier (Hot, Cool)')
param accessTier string = 'Hot'

@description('Allow blob public access (false for security)')
param allowBlobPublicAccess bool = false

@description('Enable HTTPS only')
param supportsHttpsTrafficOnly bool = true

@description('Minimum TLS version (1.2 recommended)')
param minimumTlsVersion string = 'TLS1_2'

@description('Network ACLs for restricting access')
param networkAcls object = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
}

@description('Tags for the resources')
param tags object = {}

// Storage Account resource with security configurations
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    minimumTlsVersion: minimumTlsVersion
    networkAcls: networkAcls
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
  tags: tags
}

// Output the Storage Account name and primary endpoints
output storageAccountName string = storageAccount.name
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output primaryFileEndpoint string = storageAccount.properties.primaryEndpoints.file
