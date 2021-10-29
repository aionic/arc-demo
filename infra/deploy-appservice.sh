#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

ClusterName=$(az deployment group show -g ali-aks -n ali-aks-aks -o tsv --query properties.outputs.clusterName.value)
StaticIP=$(az deployment group show -g "$RGName" -n "$AKSDeployName" -o tsv --query properties.outputs.staticIpAddress.value)

logAnalyticsWorkspaceId=$(az deployment group show -g ali-aks -n ali-aks-aks -o tsv --query properties.outputs.logAnalytics.value.CustomerId)
logAnalyticsWorkspaceName=$(az deployment group show -g ali-aks -n ali-aks-aks -o tsv --query properties.outputs.logAnalytics.value.Name)

logAnalyticsWorkspaceIdEnc=$(printf %s "$logAnalyticsWorkspaceId" | base64 -w0) 
logAnalyticsKey=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group "$RGName" \
    --workspace-name "$logAnalyticsWorkspaceName" \
    --query primarySharedKey \
    --output tsv)
logAnalyticsKeyEnc=$(printf %s "$logAnalyticsKey" | base64 -w0) # Needed for the next step

extensionName="appservice-ext"
namespace="appservice-ns"

az k8s-extension create \
    --resource-group "$ArcRGName" \
    --name $extensionName \
    --cluster-type connectedClusters \
    --cluster-name "$ArcClusterName" \
    --extension-type 'Microsoft.Web.Appservice' \
    --release-train stable \
    --auto-upgrade-minor-version true \
    --scope cluster \
    --release-namespace $namespace \
    --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" \
    --configuration-settings "appsNamespace=${namespace}" \
    --configuration-settings "clusterName=${EnvironmentName}" \
    --configuration-settings "loadBalancerIp=${StaticIP}" \
    --configuration-settings "keda.enabled=true" \
    --configuration-settings "buildService.storageClassName=default" \
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
    --configuration-settings "customConfigMap=${namespace}/kube-environment-config" \
    --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${RGName}" \
    --configuration-settings "logProcessor.appLogs.destination=log-analytics" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${logAnalyticsWorkspaceIdEnc}" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${logAnalyticsKeyEnc}"


extensionId=$(az k8s-extension show \
    --cluster-type connectedClusters \
    --cluster-name $ArcClusterName \
    --resource-group $ArcRGName \
    --name $extensionName \
    --query id \
    --output tsv)
popd
set -euxo pipefail