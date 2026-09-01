using '../modules/main.bicep'


//===================================================
// ENVIRONMENT
//===================================================

param environment = 'dev'

param location = 'centralus'


//===================================================
// LANDING ZONES
//===================================================

param landingZones = {

  //=================================================
  // RESOURCE GROUPS
  //=================================================

  resourceGroups: [

    {
      rgName: 'rg-loadbalancer-dev'

      location: location

      tags: {
        Environment: environment
        Application: 'LoadBalancer'
        ManagedBy: 'Bicep'
        Team: 'CloudOps'
      }
    }
  ]


  //=================================================
  // PUBLIC IPs
  //=================================================

  publicIps: [

    {
      publicIpName: 'pip-loadbalancer-dev'

      resourceGroupName: 'rg-loadbalancer-dev'

      location: location

      sku: 'Standard'

      allocationMethod: 'Static'
    }
  ]


  //=================================================
  // LOAD BALANCERS
  //=================================================

  loadBalancers: [

    {
      loadBalancerName: 'lb-dev'

      resourceGroupName: 'rg-loadbalancer-dev'

      location: location

      sku: 'Standard'


      //=============================================
      // FRONTEND
      //=============================================

      frontend: {

        name: 'public-frontend'

        publicIpName: 'pip-loadbalancer-dev'
      }


      //=============================================
      // BACKEND POOL
      //=============================================

      backendPool: {

        name: 'backend-pool'

        addresses: [

          {
            name: 'backend-server-01'

            ipAddress: '10.10.2.10'
          }

          {
            name: 'backend-server-02'

            ipAddress: '10.10.2.11'
          }
        ]
      }


      //=============================================
      // HEALTH PROBE
      //=============================================

      probe: {

        name: 'http-health-probe'

        protocol: 'Http'

        port: 80

        requestPath: '/'

        intervalInSeconds: 15

        numberOfProbes: 2
      }


      //=============================================
      // LOAD BALANCING RULE
      //=============================================

      rule: {

        name: 'http-rule'

        protocol: 'Tcp'

        frontendPort: 80

        backendPort: 80

        idleTimeoutInMinutes: 4

        enableFloatingIp: false

        enableTcpReset: true
      }
    }
  ]
}
