import urllib.request
from urllib.error import HTTPError

try:
    with urllib.request.urlopen("http://localhost:8000/api/admin/analytics/daily?days=7") as r:
        print(r.read())
except HTTPError as e:
    print(e.read().decode())
