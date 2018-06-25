### Importer:

Connects to Postgres DB using env variables:
```
DB_HOST
DB_PASS
```

Dockerfile included in this directory.

Intended to run alongside prebid-server on the same host, imports data from RDS and writes to flat files

Needs to share ``` /usr/src/ozone/prebid-server/static directory``` with prebid-server container on the host

Run command for task: ``` python /usr/src/ozone-code/importer/importer.py```

