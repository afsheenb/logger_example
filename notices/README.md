### notices

```
Docker container: golang:1.9.3-stretch
Run command: go get -v ./... && go run notices.go
Env variable: LOG_HOST, e.g. LOG_HOST="127.0.0.1:514"
Ports: expose port 8080 TCP
```

This program listens on an HTTP endpoint for win and loss notifications,
parses the notification payload data, and sends it serialized as JSON via 
raw UDP sockets to a udp2kafka bridge, to be delivered to a Kafka broker and
eventually on to S3.
