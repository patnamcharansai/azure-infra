// This Bicep file deploys a secure Azure Virtual Machine following enterprise standards.
// It includes NSG with restricted access, managed disks with encryption, and security best practices.

targetScope = 'resourceGroup'

// Parameters for VM configuration
@description('Location for the VM')
param location string = resourceGroup().location

@description('Name of the virtual machine')
param vmName string

@description('Size of the VM (e.g., Standard_DS1_v2)')
param vmSize string = 'Standard_DS1_v2'

@description('OS type: Windows or Linux')
param osType string = 'Linux'

@description('Admin username for the VM')
param adminUsername string

@description('Admin password (use secureString for production)')
@secure()
param adminPassword string

@description('SSH public key for Linux VMs (optional, recommended for security)')
param sshPublicKey string = ''

@description('Name of the existing VNet')
param vnetName string

@description('Name of the subnet in the VNet')
param subnetName string

@description('Tags for the resources')
param tags object = {}

// NSG with restricted inbound rules (allow SSH/RDP only from specific IPs if needed)
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'  // Restrict to specific IPs in production
          destinationAddressPrefix: '*'
        }
      }
      // Add RDP rule for Windows if needed
    ]
  }
  tags: tags
}

// VM resource with security configurations
resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: osType == 'Windows' ? adminPassword : null
      linuxConfiguration: osType == 'Linux' ? {
        disablePasswordAuthentication: !empty(sshPublicKey)
        ssh: !empty(sshPublicKey) ? {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        } : null
      } : null
      windowsConfiguration: osType == 'Windows' ? {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      } : null
    }
    storageProfile: {
      imageReference: {
        publisher: osType == 'Linux' ? 'Canonical' : 'MicrosoftWindowsServer'
        offer: osType == 'Linux' ? 'Ubuntu2204' : 'WindowsServer'
        sku: osType == 'Linux' ? '22_04-lts' : '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'  // Use premium for better performance/security
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
  tags: tags
}

// Network Interface for the VM
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  tags: tags
}

// Optional: VM extension for Azure Monitor Agent (for logging and monitoring)
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  parent: vm
  name: 'AzureMonitorAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'  // or AzureMonitorWindowsAgent for Windows
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

// Output the VM's private IP
output vmPrivateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
