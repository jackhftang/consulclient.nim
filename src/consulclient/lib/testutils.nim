import common
import macros, osproc, streams

import unittest, asyncdispatch
export unittest, asyncdispatch

macro asyncTest*(name: static[string], code: untyped): untyped = 
  result = quote do:
    test `name`:
      proc doTest {.async.} =
        `code`
      let fut = doTest()
      while not fut.finished:
        poll()
      if fut.failed:
        echo fut.readError.msg
        # do not abort
        check false
      

type
  ConsulProcess* = object
    process: Process

proc newConsulProcess*(): ConsulProcess =
  # consul is required to run test
  result.process = startProcess(
    "consul",
    args=["agent", "-dev"],
    options={poUsePath, poStdErrToStdOut}
  )

  var line = newStringOfCap(120).TaintedString
  while true:
    if result.process.outputStream.readLine(line):
      if "Consul agent running" in line:
        break

proc stop*(consul: ConsulProcess) =
  if consul.process.running:
    consul.process.terminate()
    discard consul.process.waitForExit()
    # let code = consul.process.waitForExit()
    # assert code == 1
    consul.process.close()