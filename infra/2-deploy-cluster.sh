#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"


SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

source ./Utilities.sh

az deployment sub create -l "$Location" -n "$RGName"-deployment -f ResourceGroup.bicep \
-p location="$Location" \
-p resourcegroupName="$RGName"

AdmingGroupObjectId=$(GetAdminGroupObjectId)

az deployment group create -g "$RGName" -n "$AKSDeploymentName" -f main.bicep \
-p location="$Location" \
-p AdmingGroupObjectId="$AdmingGroupObjectId"

ClusterName=$(GetClusterName)

az aks get-credentials --resource-group "$RGName" --name "$ClusterName" --overwrite-existing --admin
kubectl get ns

popd
set -euxo pipefail