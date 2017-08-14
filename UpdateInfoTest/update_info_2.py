import requests
import json
import sys
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

# Meant to be run within docker container

metric = 'num_reports_ran_today'
registry = CollectorRegistry()
g = Gauge(metric, 'number of reports that ran today', registry=registry)

# Look at "prometheus:9090" for current metric value
r = requests.get('http://fermicloud149.fnal.gov:9090/api/v1/query?query={0}'.format(metric))

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

# Push new metric to host "pushgateway" (listening on 9091)
push_to_gateway('http://fermicloud149.fnal.gov:9091', job='py_push_test', registry=registry)

sys.exit(0)
