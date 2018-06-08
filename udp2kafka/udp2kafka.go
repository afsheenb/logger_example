package main

import (
	"fmt"
	"net"
	"os"
	"log"
	"github.com/Shopify/sarama"
	"strings"
	"runtime"
	"time"
)

func split(r rune) bool {
	return r == '|'
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

	buf := make([]byte, 65535)
	kafkaConfig := sarama.NewConfig()
	kafkaConfig.Producer.Retry.Max = 3
	kafkaConfig.Producer.Return.Successes = true
	kafkaConfig.Producer.Return.Errors = true
	kafkaConfig.Producer.Compression = sarama.CompressionSnappy
	kafkaConfig.Producer.Flush.Frequency = 200 * time.Millisecond
	kafkaConfig.Producer.Flush.Messages = 2500
	hostname, _ := os.Hostname()
        broker := []string {os.Getenv("KAFKA_BROKER1"), os.Getenv("KAFKA_BROKER2"), os.Getenv("KAFKA_BROKER3")}
	log.Printf("Starting up udp2kafka bridge now...")
	log.Printf("Starting on %s, PID %d", hostname, os.Getpid())
	log.Printf("Machine has %d cores", runtime.NumCPU())
	log.Printf("Bridging messages received on UDP port 514 to Kafka broker %s", broker[0])

	for {
		n, _, err := serverConn.ReadFromUDP(buf)
		p := strings.FieldsFunc(string(buf[0:n]), split)
		producer, err := sarama.NewAsyncProducer(broker, kafkaConfig)
		if err != nil {
			fmt.Println("Critical error connecting to kafka broker: %v", err)
		}
		topic := string(p[0])
		msg := &sarama.ProducerMessage{
			Topic:     topic,
			Value:     sarama.StringEncoder(p[1]),
		}
		producer.Input() <- msg

		if err := producer.Close(); err != nil {
			fmt.Println("Critical error closing kafka connection: %v", err)
			}

	}
}
