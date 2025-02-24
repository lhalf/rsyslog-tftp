#!/usr/bin/python3

import sys
import pysisl
import json
from datetime import datetime, timezone

def to_iso8601_timestamp(unix_timestamp: str) -> str:
    return datetime.fromtimestamp(int(unix_timestamp), tz=timezone.utc).isoformat()

for line in sys.stdin:
    sisl = pysisl.loads(line)

    properties = {
        "pri": sisl.get("pri"),
        "timestamp": to_iso8601_timestamp(sisl.get("timestamp")),
        "hostname": sisl.get("hostname"),
        "syslogtag": sisl.get("syslogtag"),
        "msg": sisl.get("msg")
    }

    sys.stdout.write(json.dumps(properties) + "\n")
    sys.stdout.flush()
