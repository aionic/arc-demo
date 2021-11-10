param uniqueSuffix string=uniqueString(resourceGroup().id)
param AdmingGroupObjectId string
param location string = 'eastus'

param logAnalyticsWksName string = 'log-${uniqueSuffix}'
param aksClusterName string = 'aks-${uniqueSuffix}'
param aksNodeResourceGroup string = 'MC_${aksClusterName}_${location}'

param ipAddressName string = 'ip-${uniqueSuffix}'

param defaultTags object = {}
param vmSize string = 'Standard_D2ds_v4'

module la 'logAnalytics.bicep'={
  name: 'loganalytics'
  params:{
    laWksName: logAnalyticsWksName
    tags: defaultTags
  }
}

module cluster 'aks.bicep'={
  name: aksClusterName
  params:{
    clusterName: aksClusterName
    nodeResourceGroup: aksNodeResourceGroup
    vmSize: vmSize
    logAnalyticsWorkspaceId: la.outputs.resourceId
    adminGroupObjectId: AdmingGroupObjectId
    tags: defaultTags
  }
}


var aksNodeScope = resourceGroup(aksNodeResourceGroup)

//TODO: This is really part of ARC deployment need to move it there
module ipAddress 'ipAddress.bicep'={
  name: ipAddressName
  scope: aksNodeScope
  
  params:{
    ipaddressName: ipAddressName
    tags: defaultTags
    dummy: cluster
  }
}


output staticIpAddress string = ipAddress.outputs.ipAddress
output subscriptionId string = subscription().subscriptionId
output subscriptionName string = subscription().displayName
output tenantId string = subscription().tenantId
output aksResourceGroup string = resourceGroup().name
output clusterName string = cluster.outputs.aksClusterName
output clusterNodesRg string = cluster.outputs.nodesRg

output LogAnalytics object = {
  Name : la.outputs.workSpaceName
  ResourceId : la.outputs.resourceId
  CustomerId : la.outputs.customerId
  RgName : la.outputs.rgName
}
