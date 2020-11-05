import lib/common
import base

proc listServices*(client: ConsulClient): Future[JsonNode] =
  ## https://www.consul.io/api-docs/agent/service#list-services
  client.get("agent/services")

proc listServices*(client: ConsulClient, query: openArray[(string, string)]): Future[JsonNode] =
  client.get("agent/services?" & encodeQuery(query))

proc getServiceConfiguration*(client: ConsulClient, serviceId: string): Future[JsonNode] =
  ## https://www.consul.io/api-docs/agent/service#get-service-configuration
  client.get(fmt"agent/service/{serviceId}")  

proc getLocalServiceHealth*(client: ConsulClient, serviceName: string): Future[JsonNode] =
  ## https://www.consul.io/api-docs/agent/service#get-local-service-health
  client.get(fmt"agent/health/service/name/{serviceName}")  
  
proc getLocalServiceHealthById*(client: ConsulClient, serviceId: string): Future[JsonNode] =
  ## https://www.consul.io/api-docs/agent/service#get-local-service-health-by-its-id
  client.get(fmt"agent/health/service/id/{serviceId}")  

proc registerService*(client: ConsulClient, body: JsonNode): Future[void] {.async.} =
  ## https://www.consul.io/api-docs/agent/service#register-service
  discard await client.put(fmt"agent/service/register", body)  

proc deregisterService*(client: ConsulClient, serviceId: string, body: JsonNode): Future[JsonNode] =
  ## https://www.consul.io/api-docs/agent/service#register-service
  client.put(fmt"agent/service/deregister/{serviceId}", body)

proc enableMaintenanceMode*(client: ConsulClient, serviceId: string, query: openArray[(string, string)]): Future[JsonNode] =
  ## https://www.consul.io/api-docs/agent/service#enable-maintenance-mode
  client.put(fmt"agent/service/maintenance/{serviceId}?" & encodeQuery(query))  