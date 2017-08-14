import requests
import json
import sys
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway


PROM_HOST = 'http://fermicloud149.fnal.gov'

# Meant to be run within docker container

registry = CollectorRegistry()

# Look at "prometheus:9090" for current metric value
prom_port = 9090
metric = 'num_reports_ran_today'
prom_url = '{0}:{1}/api/v1/query?query={2}'.format(PROM_HOST, prom_port, metric)

r = requests.get(prom_url)

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

g = Gauge(metric, 'number of reports that ran today', registry=registry)
g.set(new)

# Push new metric to host "pushgateway" (listening on 9091)
push_port = 9091
push_url = '{0}:{1}'.format(PROM_HOST, push_port)
push_to_gateway(push_url, job='py_push_test', registry=registry)

sys.exit(0)
