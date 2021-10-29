#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

az deployment sub create -l "$Location" -n "$RGName"'deploy' -f ResourceGroup.bicep \
-p location="$Location" \
-p resourcegroupName="$RGName"

az deployment group create -g "$RGName" -n "$AKSDeployName" -f main.bicep \
-p location="$Location" \
-p namePrefix="$NamePrefix"

ClusterName=$(az deployment group show -g "$RGName" -n "$AKSDeployName" -o tsv --query properties.outputs.clusterName.value)

az aks get-credentials --resource-group "$RGName" --name "$ClusterName" --admin
kubectl get ns

popd
set -euxo pipefail