import lib/common
import os
import httpclient

type
  ConsulClient* = object
    host*: Uri
    token*: string

  ConsulClientError* = object of CatchableError
  ConsulHttpRequestError* = object of ConsulClientError
    requestMethod*: HttpMethod
    requestUri*: Uri
    requestHeaders*: HttpHeaders
    requestBody*: string
    responseCode*: HttpCode
    responseHeaders*: HttpHeaders
    responseBody*: string

const DEFAULT_CONSUL_ADDR* = "http://127.0.0.1:8500"

proc newConsulClient*(host, token: string): ConsulClient =
  ## Create ConsulClient
  ConsulClient(
    host: parseUri(host) / "v1",
    token: token
  )

proc newConsulClient*(host: string): ConsulClient =
  let token = getEnv("CONSUL_HTTP_TOKEN", "")
  newConsulClient(host, token)

proc newConsulClient*(): ConsulClient =
  let host = getEnv("CONSUL_HTTP_ADDR", DEFAULT_CONSUL_ADDR)
  let token = getEnv("CONSUL_HTTP_TOKEN", "")
  newConsulClient(host, token)

proc request(client: ConsulClient, httpMethod: HttpMethod, uri: Uri, headers: HttpHeaders = nil, data: JsonNode = nil): Future[JsonNode] {.async.} =
  let h = if headers.isNil: newHttpHeaders() else: headers
  
  # required. Otherwise if response payload is empty, httpclient hang
  h["Connection"] = "close" 
  
  # set token if any
  if client.token.len != 0:
    h["X-Consul-Token"] = client.token

  # serialize
  let payload = 
    if data.isNil: "" 
    else: $data
  
  when defined(debugVaultClient):
    echo httpMethod, " ", $uri, " ", h, " ", payload

  let agent = newAsyncHttpClient()
  let res = await agent.request($uri, httpMethod, payload, h)

  when defined(debugVaultClient):
    echo res.code, await res.body

  if not res.code.is2xx:
    var err = newException(ConsulHttpRequestError, res.status)
    err.requestMethod = httpMethod
    err.requestUri = uri
    err.requestHeaders = h
    err.requestBody = payload
    err.responseCode = res.code
    err.responseHeaders = res.headers
    err.responseBody = await res.body
    raise err

  # read whole body
  let body = await res.body()
  result = 
    if body.len == 0: newJNull() 
    else: parseJson(body)

proc get*(client: ConsulClient, path: string, headers: HttpHeaders = nil): Future[JsonNode] {.inline.} =
  let uri = client.host / path
  client.request(HttpGet, uri, headers)


proc put*(client: ConsulClient, path: string, data: JsonNode = nil): Future[JsonNode] {.inline.} =
  let headers = newHttpHeaders()
  headers["Content-Type"] = "application/json"
  let uri = client.host / path
  client.request(HttpPut, uri, headers, data)


proc delete*(client: ConsulClient, path: string): Future[JsonNode] {.inline.} =
  let uri = client.host / path
  client.request(HttpDelete, uri)