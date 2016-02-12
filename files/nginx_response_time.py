import json
import time
import re
from datetime import datetime

def response_time(log, line):
    json_line = json.loads(line)
    p = '%Y-%m-%dT%H:%M:%S+00:00'
    epoch = datetime(1970, 1, 1)
    timestamp = int((datetime.strptime(json_line['time'], p) - epoch).total_seconds())

    base = re.match(r'^(/\w*)', json_line['uri'])

    return ('dotcom_nginx_response_time',
            timestamp,
            json_line['request_time'],
            { 'metric_type': 'gauge',
              'tags': [ 'uri:' + json_line['uri'], 'base:' + base.group(1) ]
            }
    )