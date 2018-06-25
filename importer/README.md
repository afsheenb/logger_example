###Importer:

Connects to Postgres DB using env variables:
```
DB_HOST
DB_PASS
```

Dockerfile included

Runs alongside prebid-server, imports data from RDS and writes to flat files

Needs to share ``` /usr/src/ozone/prebid-server/static directory``` with prebid-server container

Run command: ``` python /usr/src/ozone-code/importer/importer.py```

