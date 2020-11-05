import lib/testutils
import lib/common
import base
import agent

suite "agent":
  let consul = newConsulProcess()

  asyncTest "register":
    let client = newConsulClient()

    # should success with error
    await client.registerService(%*{
      "Name": "consulclient_register_test",
    })

  asyncTest "listServices":
    let client = newConsulClient()

    # register consulclient_listServices_test
    await client.registerService(%*{
      "Name": "consulclient_listServices_test",
    })
    let json = await client.listServices()

    # echo json
    check: json.kind == JObject
    check: "consulclient_listServices_test" in json

  consul.stop()