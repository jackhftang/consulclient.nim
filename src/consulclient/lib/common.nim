import json, sequtils, strutils, strformat, asyncdispatch, uri, httpcore
export json, sequtils, strutils, strformat, asyncdispatch, uri, httpcore

import os
export os.`/`

template isNotNil*(x: typed): bool = not x.isNil