az login --use-device-code

cd "/c/Users/patna/OneDrive/Desktop/Azure Learning/azurebiceps/azure-infra"

az deployment sub what-if \
  --location eastus \
  --template-file main.bicep \
  --parameters @dev.parameters.json

az deployment sub what-if \
  --location eastus \
  --template-file main.bicep \
  --parameters @prod.parameters.json
=====================================================================================================

az deployment sub create \
  --location eastus \
  --template-file main.bicep \
  --parameters @dev.parameters.json

===========================================================================================


az deployment group create \
  --resource-group rg-myproject-devspoke \
  --template-file spoke.bicep \
  --parameters @dev.parameters.json


az deployment group create \
  --resource-group rg-myproject-prodspoke \
  --template-file spoke.bicep \
  --parameters @prod.parameters.json
