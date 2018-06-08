### udp2kafka

```
Docker container: golang:1.9.3-stretch
Run command: go get -v ./... && go run udp2kafka.go
Env variable: KAFKA_BROKER1, KAFKA_BROKER2, KAFKA_BROKER3 e.g. "export KAFKA_BROKER1=kafka-01.pootl.net:9092"
Ports: expose port 514 UDP, run on same host as prebid-server
```
