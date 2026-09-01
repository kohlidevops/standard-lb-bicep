param loadBalancerName string
param location string

@description('Load Balancer SKU. Recommended: Standard')
param sku string

@description('Frontend IP configuration name')
param frontendName string

@description('Public IP resource ID')
param publicIpId string

@description('Backend address pool name')
param backendPoolName string

@description('Backend IP addresses')
param backendAddresses array

@description('Health probe configuration')
param probe object

@description('Load balancing rule configuration')
param rule object


//===================================================
// RESOURCE IDS
//===================================================

var frontendIpConfigurationId = resourceId(
  'Microsoft.Network/loadBalancers/frontendIPConfigurations',
  loadBalancerName,
  frontendName
)

var backendAddressPoolId = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  loadBalancerName,
  backendPoolName
)

var probeId = resourceId(
  'Microsoft.Network/loadBalancers/probes',
  loadBalancerName,
  probe.name
)


//===================================================
// STANDARD LOAD BALANCER
//===================================================

resource loadBalancer 'Microsoft.Network/loadBalancers@2025-05-01' = {
  name: loadBalancerName
  location: location

  sku: {
    name: sku
    tier: 'Regional'
  }

  properties: {

    //=================================================
    // FRONTEND IP CONFIGURATION
    //=================================================

    frontendIPConfigurations: [
      {
        name: frontendName

        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]


    //=================================================
    // BACKEND ADDRESS POOL
    //=================================================

    backendAddressPools: [
      {
        name: backendPoolName

        properties: {
          loadBalancerBackendAddresses: [
            for backend in backendAddresses: {
              name: backend.name

              properties: {
                ipAddress: backend.ipAddress
              }
            }
          ]
        }
      }
    ]


    //=================================================
    // HEALTH PROBE
    //=================================================

    probes: [
      {
        name: probe.name

        properties: {
          protocol: probe.protocol
          port: probe.port
          requestPath: probe.requestPath

          intervalInSeconds: probe.intervalInSeconds
          numberOfProbes: probe.numberOfProbes
        }
      }
    ]


    //=================================================
    // LOAD BALANCING RULE
    //=================================================

    loadBalancingRules: [
      {
        name: rule.name

        properties: {
          frontendIPConfiguration: {
            id: frontendIpConfigurationId
          }

          backendAddressPool: {
            id: backendAddressPoolId
          }

          probe: {
            id: probeId
          }

          protocol: rule.protocol

          frontendPort: rule.frontendPort

          backendPort: rule.backendPort

          idleTimeoutInMinutes: rule.idleTimeoutInMinutes

          enableFloatingIP: rule.enableFloatingIp

          enableTcpReset: rule.enableTcpReset
        }
      }
    ]
  }
}


//===================================================
// OUTPUTS
//===================================================

output loadBalancerId string = loadBalancer.id

output frontendIpConfigurationId string = frontendIpConfigurationId

output backendAddressPoolId string = backendAddressPoolId

output loadBalancerName string = loadBalancer.name
