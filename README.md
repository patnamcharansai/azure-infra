# Azure Infrastructure Deployment with Bicep

This repository contains Bicep templates for deploying Azure hub-and-spoke network infrastructure.

## Prerequisites

- Azure CLI installed and logged in (`az login --use-device-code`)
- Appropriate permissions to deploy at subscription and resource group levels

## Parameters

The Bicep templates use the following parameters. Dynamic values like `location` and `environment` should be specified in the `parameters.json` files (e.g., `dev.parameters.json`, `prod.parameters.json`).

- `location`: Azure region for resource deployment (e.g., "eastus")
- `projectName`: Name of the project (used in resource naming)
- `environment`: Deployment environment (e.g., "dev", "prod", "test")
- `hubRgName`: Name for the hub resource group (defaults to `rg-{projectName}-{environment}hub`)
- `spokeRgName`: Name for the spoke resource group (defaults to `rg-{projectName}-{environment}spoke`)

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

### vm.prod.parameters.json fields
- `vmName`, `vmSize`, `osType`, etc. as above
- `adminPassword`: Key Vault reference block:
  - `keyVault.id`: Key Vault resource ID
  - `secretName`: Key Vault secret name

## Deployment Order

To deploy the infrastructure correctly, follow this sequence:

1. **main.bicep** (Subscription level): Creates resource groups. Use `dev.parameters.json` or `prod.parameters.json`.
2. **hub.bicep** (Hub resource group): Deploys hub VNet and subnets. Use `dev.parameters.json` or `prod.parameters.json`.
3. **spoke.bicep** (Spoke resource group): Deploys spoke VNet and subnets. Use `dev.parameters.json` or `prod.parameters.json`.
4. **vm.bicep** (Spoke resource group, optional): Deploys VMs. Use `vm.dev.parameters.json` for dev or `vm.prod.parameters.json` for prod.

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
  --location eastus \
  --template-file main.bicep \
  --parameters @dev.parameters.json

az deployment sub what-if \
  --location eastus \
  --template-file main.bicep \
  --parameters @prod.parameters.json
```

### Actual Deployments
```bash
az deployment sub create \
  --location eastus \
  --template-file main.bicep \
  --parameters @dev.parameters.json
```

### Hub Deployments
```bash
az deployment group create \
  --resource-group rg-myproject-devhub \
  --template-file hub.bicep \
  --parameters @dev.parameters.json

az deployment group create \
  --resource-group rg-myproject-prodhub \
  --template-file hub.bicep \
  --parameters @prod.parameters.json
```

### Spoke Deployments
```bash
az deployment group create \
  --resource-group rg-myproject-devspoke \
  --template-file spoke.bicep \
  --parameters @dev.parameters.json

az deployment group create \
  --resource-group rg-myproject-prodspoke \
  --template-file spoke.bicep \
  --parameters @prod.parameters.json
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

Note: Update resource group names and locations as needed based on your parameters.
