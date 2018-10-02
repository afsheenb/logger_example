package main

import (
	//"bufio"
	"io/ioutil"
	"encoding/json"
	"fmt"
	"github.com/DataDog/datadog-go/statsd"
	"github.com/Jeffail/gabs"
	"github.com/Shopify/sarama"
	sp "gopkg.in/snowplow/snowplow-golang-tracker.v1/tracker"
	"runtime"
	"log"
	"net"
	"os"
	"strings"
	"sync"
	"time"
)

var wg sync.WaitGroup

func main() {
	statsd_host := string(os.Getenv("STATSD_HOST"))
	socket_file := string(os.Getenv("LOGGER_SOCKET_FILE"))
	log.Printf("Starting up tcp2kafka bridge now...")
	hostname, _ := os.Hostname()
	broker := []string{os.Getenv("KAFKA_BROKER1"), os.Getenv("KAFKA_BROKER2"), os.Getenv("KAFKA_BROKER3")}
	log.Printf("Starting on %s, PID %d", hostname, os.Getpid())
	log.Printf("Machine has %d cores", runtime.NumCPU())
	log.Printf("Bridging messages to Kafka broker %s", broker[0])
	app_env := string(os.Getenv("APP_ENV_ID"))
	subject := sp.InitSubject()
	emitter := sp.InitEmitter(sp.RequireCollectorUri("tech-hereford-f39dac8.collector.snplow.net"))
	tracker := sp.InitTracker(sp.RequireEmitter(emitter), sp.OptionSubject(subject), sp.OptionAppId(app_env))
	kafkaConfig := sarama.NewConfig()
	kafkaConfig.Producer.Retry.Max = 3
	kafkaConfig.Producer.Return.Successes = true
	kafkaConfig.Producer.Return.Errors = true
	kafkaConfig.Producer.Compression = sarama.CompressionSnappy
	kafkaConfig.Producer.Flush.Frequency = 200 * time.Millisecond
	kafkaConfig.Producer.Flush.Messages = 2500
	reqproducer, err := sarama.NewSyncProducer(broker, kafkaConfig)
	if err != nil {
		fmt.Println("Critical error connecting to kafka broker for requests: %v", err)
	}
	respproducer, _ := sarama.NewSyncProducer(broker, kafkaConfig)
	if err != nil {
		fmt.Println("Critical error connecting to kafka broker for responses: %v", err)
	}
	count := 0

	wg.Add(2)
	listen, err := net.Listen("unix", socket_file)
	if err != nil {
		log.Fatal(err)
	}
	defer listen.Close()
        defer os.Remove(socket_file)

	go func() {

		for {
			conn, err := listen.Accept()
			if err != nil {
				log.Fatal(err)
                                os.Remove(socket_file)
			}

			//scanner := bufio.NewScanner(conn)
			//for scanner.Scan() {
                        text , err := ioutil.ReadAll(conn)
				//dataBuf := string(scanner.Text())
				dataBuf := string(text)
				p := strings.Split(string(dataBuf), "@")
				reqtopic := string(p[0])
				resptopic := string(p[2])

				if reqtopic == "httpreq" {
					reqmsg := &sarama.ProducerMessage{
						Topic: string(reqtopic),
						Value: sarama.StringEncoder(p[1]),
					}

					_, _, reqerr := reqproducer.SendMessage(reqmsg)
						if reqerr != nil {
							fmt.Println(reqerr)
					}

					data := string(p[1])
					pingdom_in_httpreq := 0
					dataMap := make(map[string]interface{})
					err := json.Unmarshal([]byte(data), &dataMap)
					if err != nil {
						fmt.Println(err)
					}

					value, _ := gabs.ParseJSON([]byte(data))
					ua := value.Path("device.ua").String()
					ip := value.Path("device.ip").String()
					host_to_httpreq_tracker := value.Path("page_name").String()
					if host_to_httpreq_tracker == "\"pingdom.the-ozone-project.com\"" {
						c, _ := statsd.New(statsd_host)
						pingdom_in_httpreq++
						c.Namespace = "logger."
						c.Incr("pingdom_to_httpreq_snplow", nil, float64(pingdom_in_httpreq))
					}
					subject.SetUseragent(ua)
					subject.SetIpAddress(ip)
					sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/httpreqs/jsonschema/2-0-4", dataMap)
					tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{Event: sdj})
					//fmt.Println(data)
				}
				if resptopic == "bidresponse" {
					data := string(p[3])
					dataMap := make(map[string]interface{})
					err := json.Unmarshal([]byte(data), &dataMap)
					if err != nil {
						fmt.Println(err)
					}
					respmsg := &sarama.ProducerMessage{
						Topic: string(resptopic),
						Value: sarama.StringEncoder(p[3]),
					}
					_, _, resperr := respproducer.SendMessage(respmsg)
						if resperr != nil {
							fmt.Println(resperr)
					}
					value, _ := gabs.ParseJSON([]byte(data))
					ua := value.Path("ext.debug.resolvedrequest.device.ua").String()
					ip := value.Path("ext.debug.resolvedrequest.device.ip").String()
					host_to_bidresp_tracker := value.Path("page_name").String()
					pingdom_in_bidresp := 0
					if host_to_bidresp_tracker == "\"pingdom.the-ozone-project.com\"" {
						c, _ := statsd.New(statsd_host)
						// Prefix every metric with the app name
						pingdom_in_bidresp++
						c.Namespace = "logger."
						c.Incr("pingdom_to_bidresp_snplow", nil, float64(pingdom_in_bidresp))
					}
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
					//fmt.Println(data)
		}
			//}
			fmt.Println(count)
			count++
			conn.Close()
		}
		if errs := reqproducer.Close(); errs != nil {
			for _, err := range errs.(sarama.ProducerErrors) {
				fmt.Println("Write to kafka failed: ", err)
			}
		}
		if errs := respproducer.Close(); errs != nil {
			for _, err := range errs.(sarama.ProducerErrors) {
				fmt.Println("Write to kafka failed: ", err)
			}
		}
	}()

	wg.Wait()
}
