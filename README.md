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

Update the `parameters.json` files with your specific values before deployment.

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

Note: Update resource group names and locations as needed based on your parameters.
