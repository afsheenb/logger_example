###udp2kafka


Docker container: golang:1.9.3-stretch
Run command: go get -v ./... && go run udp2kafka.go
Env variable: KAFKA_BROKER, e.g. `export KAFKA_BROKER=[kafka-01.pootl.net:9092]1
Ports: expose port 514 UDP, run on same host as prebid-server
