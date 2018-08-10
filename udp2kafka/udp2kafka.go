package main

import (
	"encoding/json"
	"fmt"
	"github.com/Shopify/sarama"
	"github.com/Jeffail/gabs"
	sp "gopkg.in/snowplow/snowplow-golang-tracker.v1/tracker"
	"log"
	"net"
	"os"
	"runtime"
	"strings"
	"time"
)

func split(r rune) bool {
	return r == '@'
}

func checkError(err error) {
	if err != nil {
		fmt.Println("Error: ", err)
		os.Exit(0)
	}
}

func main() {
	serverAddr, err := net.ResolveUDPAddr("udp", ":514")
	checkError(err)

	serverConn, err := net.ListenUDP("udp", serverAddr)
	checkError(err)
	defer serverConn.Close()

	kafkaConfig := sarama.NewConfig()
	kafkaConfig.Producer.Retry.Max = 3
	kafkaConfig.Producer.Return.Successes = true
	kafkaConfig.Producer.Return.Errors = true
	kafkaConfig.Producer.Compression = sarama.CompressionSnappy
	kafkaConfig.Producer.Flush.Frequency = 200 * time.Millisecond
	kafkaConfig.Producer.Flush.Messages = 2500
	hostname, _ := os.Hostname()
	broker := []string{os.Getenv("KAFKA_BROKER1"), os.Getenv("KAFKA_BROKER2"), os.Getenv("KAFKA_BROKER3")}
	log.Printf("Starting up udp2kafka bridge now...")
	log.Printf("Starting on %s, PID %d", hostname, os.Getpid())
	log.Printf("Machine has %d cores", runtime.NumCPU())
	log.Printf("Bridging messages received on UDP port 514 to Kafka broker %s", broker[0])
	subject := sp.InitSubject()
	emitter := sp.InitEmitter(sp.RequireCollectorUri("tech-hereford-f39dac8.collector.snplow.net"))
	tracker := sp.InitTracker(sp.RequireEmitter(emitter), sp.OptionSubject(subject))


	for {
	    buf := make([]byte, 524288)
		n, _, err := serverConn.ReadFromUDP(buf)
		p := strings.FieldsFunc(string(buf[0:n]), split)
		producer, err := sarama.NewAsyncProducer(broker, kafkaConfig)
		if err != nil {
			fmt.Println("Critical error connecting to kafka broker: %v", err)
		}
		topic := string(p[0])
		msg := &sarama.ProducerMessage{
			Topic: topic,
			Value: sarama.StringEncoder(p[1]),
		}
		producer.Input() <- msg

		if errs := producer.Close(); errs != nil {
			for _, err := range errs.(sarama.ProducerErrors) {
				fmt.Println("Write to kafka failed: ", err)
			}
		}
		if topic == "httpreq" {
			data := string(p[1])
			dataMap := make(map[string]interface{})
			value, _ := gabs.ParseJSON([]byte(data))
			err := json.Unmarshal([]byte(data), &dataMap)
			if err != nil { fmt.Println(err) }
			ua := value.Path("device.ua").String()
			ip := value.Path("device.ip").String()
                        subject.SetUseragent(ua)
                        subject.SetIpAddress(ip)
			sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/httpreqs/jsonschema/2-0-0", dataMap)
			tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{ Event: sdj, })
			//fmt.Println(data)
		}
		if topic == "bidresponse" {
			data := string(p[1])
			dataMap := make(map[string]interface{})
			value, _ := gabs.ParseJSON([]byte(data))
			err := json.Unmarshal([]byte(data), &dataMap)
			if err != nil { fmt.Println(err) }
			ua := value.Path("ext.debug.resolvedrequest.device.ua").String()
			ip := value.Path("ext.debug.resolvedrequest.device.ip").String()
                        subject.SetUseragent(ua)
                        subject.SetIpAddress(ip)
			sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/bidresponses/jsonschema/1-0-0", dataMap)
			tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{ Event: sdj, })
			//fmt.Println(data)
		}
	}
}
