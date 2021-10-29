#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

az deployment sub create -l "$Location" -n "$ArcRGName"'deploy' -f ResourceGroup.bicep \
-p location="$Location" \
-p resourcegroupName="$ArcRGName"

StaticIP=$(az deployment group show -g "$RGName" -n "$AKSDeployName" -o tsv --query properties.outputs.staticIpAddress.value)
ClusterName=$(az deployment group show -g "$RGName" -n "$AKSDeployName" -o tsv --query properties.outputs.clusterName.value)


az aks get-credentials --resource-group "$RGName" --name "$ClusterName" --admin
kubectl get ns

az connectedk8s connect --resource-group $ArcRGName --name $ArcClusterName
az connectedk8s show --resource-group $ArcRGName --name $ArcClusterName

popd
set -euxo pipefail