param laWksName string

param location string = resourceGroup().location
param tags object = {}

resource logAnalitycsWks 'Microsoft.OperationalInsights/workspaces@2020-10-01'={
  name: laWksName
  location: location
  properties:{
    
  }
  tags: tags
}

output resourceId string = logAnalitycsWks.id
output customerId  string = logAnalitycsWks.properties.customerId
output workSpaceName string = logAnalitycsWks.name
output rgName string = resourceGroup().name
