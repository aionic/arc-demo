#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

customLocationId=$(az customlocation show --resource-group "$CustomLocationRGName" --name "$CustomLocationName" --query id --output tsv)

az appservice kube create \
    --resource-group "$ASEnvironmentRGName" \
    --name "$ASEnvironmentName" \
    --custom-location "$customLocationId" \

az appservice kube show --resource-group $ASEnvironmentRGName --name $ASEnvironmentName

popd
set -euxo pipefail