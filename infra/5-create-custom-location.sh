#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

source ./utilities.sh

az connectedk8s enable-features --features cluster-connect custom-locations -n "$ArcClusterName" -g "$ArcRGName"

az deployment sub create -l "$Location" -n "$CustomLocationRGName"'deploy'"$Location" -f ResourceGroup.bicep \
-p location="$Location" \
-p resourcegroupName="$CustomLocationRGName"

ConnectedClusterId=$(az connectedk8s show --resource-group "$ArcRGName" --name "$ArcClusterName" --query id --output tsv)
ExtensionId=$(az k8s-extension show -g "$ArcRGName" -t connectedClusters -c "$ArcClusterName" -n "$AppServiceExtensionName" -o tsv --query id)

az customlocation create \
    --resource-group "$CustomLocationRGName" \
    --name "$CustomLocationName" \
    --host-resource-id "$ConnectedClusterId" \
    --namespace "$AppServiceNamespace" \
    --cluster-extension-ids "$ExtensionId"

az customlocation show --resource-group "$CustomLocationRGName" --name "$CustomLocationName"

popd
set -euxo pipefail