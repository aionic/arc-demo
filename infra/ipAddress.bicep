param ipaddressName string
param location string = resourceGroup().location
param dummy object
param tags object = {}

resource ip 'Microsoft.Network/publicIPAddresses@2020-06-01'={
  name: ipaddressName
  location: location
  sku:{
    name:'Standard'
  }
  properties:{
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
}

output ipAddress string = ip.properties.ipAddress
output id string = ip.id
output nothing object = dummy

