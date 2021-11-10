#! /bin/bash


GetClusterInfraRG(){
    local RGName
    RGName="$(az aks show --resource-group "$ClusterRGName" --name "$ClusterName" --output tsv --query nodeResourceGroup)"
    echo "$RGName"
}


GetAdminGroupObjectId(){
    local AdmingGroupObjectId
    AdmingGroupObjectId=$(az ad group list --display-name "$AKSAdmingGroupName" -o tsv --query [0].objectId)
    echo "$AdmingGroupObjectId"
}

GetClusterName(){
    local ClusterName
    ClusterName=$(az deployment group show -g "$RGName" -n "$AKSDeploymentName" -o tsv --query properties.outputs.clusterName.value)
    echo "$ClusterName"
}