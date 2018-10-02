package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"github.com/DataDog/datadog-go/statsd"
	"github.com/Jeffail/gabs"
	"github.com/Shopify/sarama"
	sp "gopkg.in/snowplow/snowplow-golang-tracker.v1/tracker"
	"io"
	"log"
	"net"
	"os"
	"runtime"
	"strings"
	"sync"
	"time"
)

func checkError(err error) {
	if err != nil {
		fmt.Println("Error: ", err)
		os.Exit(0)
	}
}

func stringInArray(str string, list []string) bool {
	for _, v := range list {
		if strings.HasSuffix(str, v) {
			return true
		}
	}
	return false
}

type conn struct {
	net.Conn

	IdleTimeout   time.Duration
	MaxReadBuffer int64
}

func (c *conn) Write(p []byte) (n int, err error) {
	c.updateDeadline()
	n, err = c.Conn.Write(p)
	return
}

func (c *conn) Read(b []byte) (n int, err error) {
	c.updateDeadline()
	r := io.LimitReader(c.Conn, c.MaxReadBuffer)
	n, err = r.Read(b)
	return
}

func (c *conn) Close() (err error) {
	err = c.Conn.Close()
	return
}

func (c *conn) updateDeadline() {
	idleDeadline := time.Now().Add(c.IdleTimeout)
	c.Conn.SetDeadline(idleDeadline)
}

type Server struct {
	Addr         string
	IdleTimeout  time.Duration
	MaxReadBytes int64

	listener   net.Listener
	conns      map[*conn]struct{}
	mu         sync.Mutex
	inShutdown bool
}

func (srv *Server) ListenAndServe() error {
	addr := string(os.Getenv("LOGGER_SOCKET_FILE"))
	if addr == "" {
		addr = "/var/run/logger/logger.sock"
	}
	hostname, _ := os.Hostname()
	log.Printf("Starting server on %v\n", addr)
	log.Printf("Starting on %s, PID %d", hostname, os.Getpid())
	log.Printf("Machine has %d cores", runtime.NumCPU())

	listener, err := net.Listen("unix", addr)
	if err != nil {
		return err
	}
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
	broker := []string{os.Getenv("KAFKA_BROKER1"), os.Getenv("KAFKA_BROKER2"), os.Getenv("KAFKA_BROKER3")}
	reqproducer, err := sarama.NewSyncProducer(broker, kafkaConfig)
	respproducer, err := sarama.NewSyncProducer(broker, kafkaConfig)
	defer listener.Close()
	srv.listener = listener
	conn_count :=0
	for {
		// should be guarded by mu
		if srv.inShutdown {
			break
		}
		newConn, err := listener.Accept()
		if err != nil {
			log.Printf("error accepting connection %v", err)
			continue
		}
		log.Printf("accepted connection from %v", newConn.RemoteAddr())
		conn := &conn{
			Conn:          newConn,
			IdleTimeout:   srv.IdleTimeout,
			MaxReadBuffer: srv.MaxReadBytes,
		}
		srv.trackConn(conn)
		conn.SetDeadline(time.Now().Add(conn.IdleTimeout))
		conn_count++
		fmt.Println(conn_count)
		go srv.handle(conn, subject, emitter, tracker, reqproducer, respproducer)
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
	return nil
}

func (srv *Server) trackConn(c *conn) {
	defer srv.mu.Unlock()
	srv.mu.Lock()
	if srv.conns == nil {
		srv.conns = make(map[*conn]struct{})
	}
	srv.conns[c] = struct{}{}
}

func (srv *Server) handle(conn *conn, subject *sp.Subject, emitter *sp.Emitter, tracker *sp.Tracker, reqproducer sarama.SyncProducer, respproducer sarama.SyncProducer) error {
	statsd_host := string(os.Getenv("STATSD_HOST"))

	defer func() {
		log.Printf("closing connection from %v", conn.RemoteAddr())
		conn.Close()
		srv.deleteConn(conn)
	}()
	r := bufio.NewReader(conn)
	scanr := bufio.NewScanner(r)
        count := 0
	sc := make(chan bool)
	deadline := time.After(conn.IdleTimeout)
	for {
		go func(s chan bool) {
			s <- scanr.Scan()
		}(sc)
		select {
		case <-deadline:
			return nil
		case scanned := <-sc:
			if !scanned {
				if err := scanr.Err(); err != nil {
					return err
				}
				return nil
			}
			//fmt.Println(scanr.Text())
			dataBuf := string(scanr.Text())
			p := strings.Split(string(dataBuf), "@")
			/* producer, err := sarama.NewSyncProducer(broker, kafkaConfig)
			if err != nil {
				fmt.Println("Critical error connecting to kafka broker: %v", err)
			}
			*/
			reqtopic := string(p[0])
			resptopic := string(p[2])

			if reqtopic == "httpreq" {
				//reqproducer, err := sarama.NewSyncProducer(broker, kafkaConfig)
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
				var dataMap = struct{
				    sync.RWMutex
				    m map[string]interface{}
				}{m: make(map[string]interface{})}
				//dataMap := make(map[string]interface{})
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
                                dataMap.Lock()
				subject.SetUseragent(ua)
				subject.SetIpAddress(ip)
				sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/httpreqs/jsonschema/2-0-4", dataMap)
				tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{Event: sdj})
                                dataMap.Unlock()
				fmt.Println(data)
			}
			if resptopic == "bidresponse" {

				data := string(p[3])
				//dataMap := make(map[string]interface{})
				var dataMap = struct{
				    sync.RWMutex
				    m map[string]interface{}
				}{m: make(map[string]interface{})}
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
                                dataMap.Lock()
				subject.SetUseragent(ua)
				subject.SetIpAddress(ip)
                                dataMap.Unlock()
				sdj := sp.InitSelfDescribingJson("iglu:tech.hereford/bidresponses/jsonschema/1-0-1", dataMap)
				tracker.TrackSelfDescribingEvent(sp.SelfDescribingEvent{Event: sdj, Contexts: contextArray})
				fmt.Println(data)
			}
                        count++
                        fmt.Println(count)
			deadline = time.After(conn.IdleTimeout)
		}
	}
	return nil
}

func (srv *Server) deleteConn(conn *conn) {
	defer srv.mu.Unlock()
	srv.mu.Lock()
	delete(srv.conns, conn)
}

func (srv *Server) Shutdown() {
	// should be guarded by mu
	srv.inShutdown = true
	log.Println("shutting down...")
	srv.listener.Close()
	ticker := time.NewTicker(500 * time.Millisecond)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
			log.Printf("waiting on %v connections", len(srv.conns))
		}
		if len(srv.conns) == 0 {
			return
		}
	}
}

func main() {

	addr := string(os.Getenv("LOGGER_SOCKET_FILE"))
	srv := Server{
		Addr:         addr,
		IdleTimeout:  10 * time.Second,
		MaxReadBytes: 8000,
	}
	go srv.ListenAndServe()
	time.Sleep(10 * time.Second)
	//srv.Shutdown()
	select {}
}


