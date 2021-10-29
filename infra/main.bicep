param namePrefix string

param location string = 'eastus'

param logAnalyticsWksName string = 'log-${namePrefix}'
param aksClusterName string = 'aks-${namePrefix}'
param aksNodeResourceGroup string = 'MC_${aksClusterName}_${location}'

param ipAddressName string = 'ip-${namePrefix}'

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
    tags: defaultTags
  }
}


var aksNodeScope = resourceGroup(aksNodeResourceGroup)

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
