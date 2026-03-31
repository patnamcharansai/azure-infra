# Azure Infrastructure Deployment with Bicep

This repository contains Bicep templates for deploying Azure hub-and-spoke network infrastructure.

## Prerequisites

- Azure CLI installed and logged in (`az login --use-device-code`)
- Appropriate permissions to deploy at subscription and resource group levels

## Parameters

Each Bicep template has specific parameter files for dev and prod environments. Use the corresponding parameter files with each template:

**Common parameters across templates:**
- `projectName`: Name of the project (used in resource naming)
- `environment`: Deployment environment (e.g., "dev", "prod")

**main.bicep parameters (Subscription level):**
- `location`: Azure region for resource deployment (e.g., "CentralIndia", "westeurope")
- `projectName`: Project name
- `environment`: Environment name
- Files: `main.dev.parameters.json`, `main.prod.parameters.json`

**hub.bicep & spoke.bicep parameters (Resource group level):**
- `projectName`: Project name
- `environment`: Environment name
- `hubAddressSpace` / `spokeAddressSpace`: VNet address space (e.g., "10.0.0.0/16")
- (Location is inherited from the resource group, no `location` parameter needed)
- Files: `hub.dev.parameters.json`, `hub.prod.parameters.json`, `spoke.dev.parameters.json`, `spoke.prod.parameters.json`

## Parameter Field Guide (JSON rules)

- *Do not add comments* in `.parameters.json` files. JSON does not support inline or block comments.
- Use human-friendly explanation in this README or a dedicated `parameters-guide.md`.
- Example values should be placed as strings in the `.parameters.json` values.

### vm.dev.parameters.json fields
- `vmName`: VM resource name (e.g., `my-vm-dev`)
- `vmSize`: VM SKU (e.g., `Standard_DS1_v2`)
- `osType`: `Linux` or `Windows`
- `adminUsername`: Admin account name
- `adminPassword`: For dev, a secret string; for prod, use Key Vault reference in `vm.prod.parameters.json`
- `sshPublicKey`: SSH key string (Linux only, recommended)
- `vnetName`: existing spoke VNet name
- `subnetName`: existing subnet name in that VNet
- `tags`: metadata fields

### storage.dev.parameters.json fields
- `storageAccountName`: Unique storage account name (lowercase, 3-24 chars)
- `sku`: Storage SKU (e.g., Standard_LRS)
- `kind`: Account kind (e.g., StorageV2)
- `accessTier`: Hot or Cool
- `allowBlobPublicAccess`: false (security)
- `supportsHttpsTrafficOnly`: true
- `minimumTlsVersion`: TLS1_2
- `networkAcls`: Network access rules
- `tags`: metadata fields

### storage.prod.parameters.json fields
- `storageAccountName`, `sku`, `kind`, etc. as above
- `networkAcls`: For prod, set `bypass: "None"` and add specific VNet rules if needed

## Deployment Order

To deploy the infrastructure correctly, follow this sequence:

1. **main.bicep** (Subscription level): Creates resource groups. Use `main.dev.parameters.json` for dev or `main.prod.parameters.json` for prod.
2. **hub.bicep** (Hub resource group): Deploys hub VNet and subnets. Use `hub.dev.parameters.json` for dev or `hub.prod.parameters.json` for prod.
3. **spoke.bicep** (Spoke resource group): Deploys spoke VNet and subnets. Use `spoke.dev.parameters.json` for dev or `spoke.prod.parameters.json` for prod.
4. **vm.bicep** (Spoke resource group, optional): Deploys VMs. Use `vm.dev.parameters.json` for dev or `vm.prod.parameters.json` for prod.
5. **storage.bicep** (Spoke resource group, optional): Deploys Storage Accounts. Use `storage.dev.parameters.json` for dev or `storage.prod.parameters.json` for prod.

Each step uses specific parameter files as indicated in the commands below.

## Deployment Commands

### Login and Navigate
```bash
az login --use-device-code
cd "/c/Users/patna/OneDrive/Desktop/Azure Learning/azurebiceps/azure-infra"
```

### What-If (Preview) Deployments
```bash
az deployment sub what-if \
  --location CentralIndia \
  --template-file main.bicep \
  --parameters @main.dev.parameters.json

az deployment sub what-if \
  --location westeurope \
  --template-file main.bicep \
  --parameters @main.prod.parameters.json
```

### Main Deployments (Subscription Level)
```bash
# Dev environment
az deployment sub create \
  --location CentralIndia \
  --template-file main.bicep \
  --parameters @main.dev.parameters.json

# Prod environment
az deployment sub create \
  --location westeurope \
  --template-file main.bicep \
  --parameters @main.prod.parameters.json
```

### Hub Deployments
```bash
az deployment group create \
  --resource-group rg-charanlab-devhub \
  --template-file hub.bicep \
  --parameters @hub.dev.parameters.json

az deployment group create \
  --resource-group rg-myproject-prodhub \
  --template-file hub.bicep \
  --parameters @hub.prod.parameters.json
```

### Spoke Deployments
```bash
az deployment group create \
  --resource-group rg-charanlab-devspoke \
  --template-file spoke.bicep \
  --parameters @spoke.dev.parameters.json

az deployment group create \
  --resource-group rg-myproject-prodspoke \
  --template-file spoke.bicep \
  --parameters @spoke.prod.parameters.json
```

### VM Deployments (Optional)
```bash
# Dev environment
az deployment group create \
  --resource-group rg-myproject-devspoke \
  --template-file vm.bicep \
  --parameters @vm.dev.parameters.json

# Prod environment (uses Key Vault for secrets)
az deployment group create \
  --resource-group rg-myproject-prodspoke \
  --template-file vm.bicep \
  --parameters @vm.prod.parameters.json
```

### Storage Deployments (Optional)
```bash
# Dev environment
az deployment group create \
  --resource-group rg-myproject-devspoke \
  --template-file storage.bicep \
  --parameters @storage.dev.parameters.json

# Prod environment
az deployment group create \
  --resource-group rg-myproject-prodspoke \
  --template-file storage.bicep \
  --parameters @storage.prod.parameters.json
```
