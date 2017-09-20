import urllib3

http = urllib3.PoolManager()
r = http.request('GET', 'https://www.google.com')

print r.status
print "Success"
