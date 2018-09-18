package main

import (
	"encoding/json"
	"fmt"
	"bytes"
	"compress/gzip"
	"io/ioutil"
	"github.com/Jeffail/gabs"
	"github.com/Shopify/sarama"
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
		dataBuf := bytes.NewBuffer(buf[0:n])
		gzipReader, err := gzip.NewReader(dataBuf)
		if err != nil {
			log.Println("Error creating gzip Reader for udp packet: ", err)
			continue
		}

		unzipped, err := ioutil.ReadAll(gzipReader)
		if err != nil {
			log.Println("Error unzipping udp packet: ", err)
			log.Println("Message payload: ", dataBuf)
			continue
		}

		p := strings.FieldsFunc(string(unzipped), split)
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
			if err != nil {
				fmt.Println(err)
			}
			ua := value.Path("device.ua").String()
			ip := value.Path("device.ip").String()
			subject.SetUseragent(ua)
			subject.SetIpAddress(ip)
			sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/httpreqs/jsonschema/2-0-1", dataMap)
			tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{Event: sdj})
			fmt.Println(data)
		}
		if topic == "bidresponse" {
			data := string(p[1])
			dataMap := make(map[string]interface{})
			value, _ := gabs.ParseJSON([]byte(data))
			err := json.Unmarshal([]byte(data), &dataMap)
			if err != nil {
				fmt.Println(err)
			}
			ua := value.Path("ext.debug.resolvedrequest.device.ua").String()
			ip := value.Path("ext.debug.resolvedrequest.device.ip").String()
			user_id := value.Path("user.id").String()
			contextArray := []sp.SelfDescribingJson{
			  *sp.InitSelfDescribingJson(
				  "iglu:tech.hereford/bidresponses_context/jsonschema/1-0-1",
			    map[string]interface{}{
			      "userid_ctxt": user_id,
			    },
			  ),
			}
			subject.SetUseragent(ua)
			subject.SetIpAddress(ip)
			sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/bidresponses/jsonschema/1-0-1", dataMap)
			tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{Event: sdj, Contexts: contextArray})
			fmt.Println(data)
		}
	}
}
