#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

./deploy-cluster.sh
./deploy-arc.sh
./deploy-appservice.sh

# InfraRG=$(az deployment group show -g "$RGName" -n "$AKSDeployNamein" -o tsv --query properties.outputs.clus
# terNodesRg.value)

# infra_rg=$(az aks show --resource-group $aksClusterGroupName --name $aksName --output tsv --query nodeResourceGroup)
# az network public-ip create --resource-group $infra_rg --name MyPublicIP --sku STANDARD
# staticIp=$(az network public-ip show --resource-group $infra_rg --name MyPublicIP --output tsv --query ipAddress)

#az deployment sub create -l eastus -n lima -f main.json
#az deployment sub show -n lima --query "properties.outputs"

popd
set +euxo pipefail