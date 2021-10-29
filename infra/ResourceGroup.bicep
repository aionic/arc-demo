targetScope='subscription'
param resourcegroupName string
param location string

resource aksRG 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: resourcegroupName
  location: location
}
