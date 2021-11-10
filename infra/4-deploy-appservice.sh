#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

source ./utilities.sh

ClusterInfraRG=$(GetClusterInfraRG)
ClusterName=$(GetClusterName)
StaticIP=$(az deployment group show -g "$RGName" -n "$AKSDeploymentName" -o tsv --query properties.outputs.staticIpAddress.value)

logAnalyticsWorkspaceId=$(az deployment group show -g "$RGName" -n "$AKSDeploymentName" -o tsv --query properties.outputs.logAnalytics.value.CustomerId)
logAnalyticsWorkspaceName=$(az deployment group show -g "$RGName" -n "$AKSDeploymentName" -o tsv --query properties.outputs.logAnalytics.value.Name)

logAnalyticsWorkspaceIdEnc=$(printf %s "$logAnalyticsWorkspaceId" | base64 -w0) 
logAnalyticsKey=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group "$RGName" \
    --workspace-name "$logAnalyticsWorkspaceName" \
    --query primarySharedKey \
    --output tsv)
logAnalyticsKeyEnc=$(printf %s "$logAnalyticsKey" | base64 -w0) # Needed for the next step


az aks get-credentials --resource-group "$RGName" --name "$ClusterName" --admin

az k8s-extension create \
    --resource-group "$ArcRGName" \
    --name $AppServiceExtensionName \
    --cluster-type connectedClusters \
    --cluster-name "$ArcClusterName" \
    --extension-type 'Microsoft.Web.Appservice' \
    --release-train stable \
    --auto-upgrade-minor-version true \
    --scope cluster \
    --release-namespace $AppServiceNamespace \
    --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" \
    --configuration-settings "appsNamespace=${AppServiceNamespace}" \
    --configuration-settings "clusterName=${ASEnvironmentName}" \
    --configuration-settings "loadBalancerIp=${StaticIP}" \
    --configuration-settings "keda.enabled=true" \
    --configuration-settings "buildService.storageClassName=default" \
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
    --configuration-settings "customConfigMap=${AppServiceNamespace}/kube-environment-config" \
    --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${ClusterInfraRG}" \
    --configuration-settings "logProcessor.appLogs.destination=log-analytics" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${logAnalyticsWorkspaceIdEnc}" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${logAnalyticsKeyEnc}"


extensionId=$(az k8s-extension show \
    --cluster-type connectedClusters \
    --cluster-name "$ArcClusterName" \
    --resource-group "$ArcRGName" \
    --name "$AppServiceExtensionName" \
    --query id \
    --output tsv)

az resource wait --ids "$extensionId" --custom "properties.installState!='Pending'" --api-version "2020-07-01-preview"

kubectl get pods -n $AppServiceNamespace


popd
set -euxo pipefail