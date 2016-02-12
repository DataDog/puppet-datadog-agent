import json
import time
import re
from datetime import datetime

def parse_nginx(log, line):
    json_line = json.loads(line)
    p = '%Y-%m-%dT%H:%M:%S+00:00'
    epoch = datetime(1970, 1, 1)
    timestamp = int((datetime.strptime(json_line['time'], p) - epoch).total_seconds())

    if json_line['status'][0] == "2":
        status = '2xx'
    elif json_line['status'][0] == "3":
        status = '3xx'
    elif json_line['status'][0] == "4":
        status = '4xx'
    elif json_line['status'][0] == "5":
        status = '5xx'

    base = re.match(r'^(/\w*)', json_line['uri'])

    return ('dotcom_nginx',
            timestamp,
            1,
            { 'metric_type': 'gauge',
              'tags': [ 'uri:' + json_line['uri'],
                        'base:' + base.group(1),
                        'status:' + status,
                        'request_time:' + json_line['request_time'],
                        'upstream_response_time:' + json_line['upstream_response_time']
                      ]
            }
    )