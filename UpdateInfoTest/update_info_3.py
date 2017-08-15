import requests
import json
import sys
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
from datetime import datetime
from os import path


PROM_HOST = 'http://fermicloud149.fnal.gov'
STATEFILE = '/tmp/statefile.txt'
TIMEFORMAT = "%Y-%m-%d %H:%M:%S"
PROM_PORT = 9090
PUSH_PORT = 9091
METRIC = 'num_reports_ran_today'
dtnow = datetime.now()
registry = CollectorRegistry()

# Meant to be run within docker container


def checkfile():
    """ Get previous date from STATEFILE"""
    with open(STATEFILE, 'r') as f:
        prevdate = datetime.strptime(f.read(), TIMEFORMAT)
    print prevdate
    return prevdate


def getcurrentmetric():
    """ Look at "prometheus:9090" for current METRIC value """
    prom_url = '{0}:{1}/api/v1/query?query={2}'.format(PROM_HOST, PROM_PORT, METRIC)

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

    return m


def pushtogateway(new):
    g = Gauge(METRIC, 'number of reports that ran today', registry=registry)
    g.set(new)

    # Push new metric to host "pushgateway" (listening on 9091)
    push_url = '{0}:{1}'.format(PROM_HOST, PUSH_PORT)
    push_to_gateway(push_url, job='py_push_test', registry=registry)
    return


def main():
    if path.exists(STATEFILE):
        prevdate = checkfile()

        # If it's a new day, reset metric counter to 0
        if dtnow.day != prevdate.day:
            m = 0
        else:
            m = getcurrentmetric()
    else:
        m = 0

    new = str(m + 1)
    pushtogateway(new)

    # Update STATEFILE
    with open(STATEFILE, 'w') as f:
        dtwrite = datetime.strftime(dtnow, TIMEFORMAT)
        f.write(dtwrite)


if __name__ == '__main__':
    main()
    sys.exit(0)
