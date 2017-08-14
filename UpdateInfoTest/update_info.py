import requests
import json
import sys
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
import time
import datetime

# Meant to be run within docker container

metric = 'num_reports_ran_today'
registry = CollectorRegistry()
g = Gauge(metric, 'number of reports that ran today', registry=registry)

while True:
    if datetime.datetime.now().second < 5:
        g.set(str(0))
        print "resetting"
    else:
        # Look at prometheus:9090
        r = requests.get('http://prometheus:9090/api/v1/query?query={0}'.format(metric))

        if not r.status_code == requests.codes.ok:
            print r.status_code
            print "Error retrieving metric.  Exiting"
            sys.exit(1)

        j = json.loads(r.text)
        try:
            m = int(j[u'data'][u'result'][0][u'value'][1])
        except IndexError:
            m = 0
        new = str(m + 1)
        g.set(new)
    # Push new metric to pushgateway (listening on 9091)
    push_to_gateway('pushgateway:9091', job='py_push_test', registry=registry)
    time.sleep(5) 
