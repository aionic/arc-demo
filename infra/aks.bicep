targetScope = 'resourceGroup'

param clusterName string
param logAnalyticsWorkspaceId string
param adminGroupObjectId string

param location string = resourceGroup().location
param agentCount int = 3
param vmSize string = 'Standard_D2ds_v4'
param nodeResourceGroup string = '${resourceGroup().name}_MC_${clusterName}_${location}'

param tags object = {}

resource aks 'Microsoft.ContainerService/managedClusters@2020-12-01'={
  name: clusterName
  location: location
  identity:{
    type:'SystemAssigned'
  }
  sku: {
    name:'Basic'
    tier: 'Free'
  }
  properties:{
    nodeResourceGroup: nodeResourceGroup
    aadProfile:{
      managed:true
      adminGroupObjectIDs:[
        '${adminGroupObjectId}'
      ]
    }
    // kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: clusterName
    agentPoolProfiles:[
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: agentCount
        vmSize: vmSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones:[
          '1'
          '2'
          '3'
        ]
      }
    ]
    networkProfile:{
      loadBalancerSku: 'standard'
      networkPlugin: 'kubenet'
    }
    apiServerAccessProfile:{
      enablePrivateCluster: false
    }
    addonProfiles:{
      omsAgent:{
        enabled: true
        config:{
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
  tags: tags
}

output nodesRg string = aks.properties.nodeResourceGroup
output aksClusterName string = aks.name
