# Consul Client

HTTP client for HashiCorp Consul.

## Usage 

```nim
import asyncdispatch

# let client = newConsulClient("http://127.0.0.1:8500", "access_token")
# or read form environemnt variables CONSUL_HTTP_ADDR and CONSUL_HTTP_TOKEN
let client = newConsulClient()

waitFor client.registerService(%*{
  "Name": "my awesome service"
})

let services = waitFor client.listServices()
assert "my awesome service" in services
```