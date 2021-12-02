#! /bin/bash
set -euxo pipefail


#This script will:
#- Create a resource group for Arc resources
#- Connects the cluster in the deployment to Arc

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

source ./utilities.sh

#Create a resource group for Arc
az deployment sub create -l "$Location" -n "$ArcRGName"'deploy'"$Location" -f ResourceGroup.bicep \
-p location="$Location" \
-p resourcegroupName="$ArcRGName"

ClusterName=$(GetClusterName)

#connect to the cluster
az aks get-credentials --resource-group "$RGName" --name "$ClusterName" --overwrite-existing --admin
kubectl get ns

#connect the cluster
az connectedk8s connect --resource-group "$ArcRGName" --name "$ArcClusterName" --location "$Location"
az connectedk8s show --resource-group "$ArcRGName" --name "$ArcClusterName"

az connectedk8s enable-features --features cluster-connect -n "$ArcClusterName" -g "$ArcRGName"

popd
set -euxo pipefail