param publicIpName string
param location string

param sku string
param allocationMethod string


resource publicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: publicIpName
  location: location

  sku: {
    name: sku
    tier: 'Regional'
  }

  properties: {
    publicIPAllocationMethod: allocationMethod
    publicIPAddressVersion: 'IPv4'
  }
}


output publicIpId string = publicIp.id

output publicIpAddress string = publicIp.properties.ipAddress
