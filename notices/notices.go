package main

import (
	"log"
	"fmt"
	"net"
	"os"
	"runtime"
	"strconv"
	"time"

	"net/http"
)

func main() {
	hostname, _ := os.Hostname()
	log.Printf("Starting up notices logger now...")
	log.Printf("Starting on %s, PID %d", hostname, os.Getpid())
	log.Printf("Machine has %d cores", runtime.NumCPU())
	log.Printf("Logging win notices received at /nurl to udp2kafka host %s", os.Getenv("LOG_HOST"))
	log.Printf("Logging loss notices received at /lurl to udp2kafka host %s", os.Getenv("LOG_HOST"))
	http.HandleFunc("/nurl", nurl)
	http.HandleFunc("/lurl", lurl)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func nurl(rw http.ResponseWriter, req *http.Request) {

	if err := req.ParseForm(); err != nil {
		log.Printf("Error parsing form: %s", err)
		return
	}
	strTime := strconv.Itoa(int(time.Now().Unix()))
	partner := req.Form.Get("partner")
	impId := req.Form.Get("impid")
	bidId := req.Form.Get("bidid")
	bidCur := req.Form.Get("bidcur")
	auction := req.Form.Get("auction")
	price := req.Form.Get("price")
	clickurl := req.Form.Get("clickurl")


	noticePayload := "{\"timestamp\": " + strTime + ", \"partner\": \"" + partner + "\", \"impid\": \"" + impId + "\", \"auction\": \"" + auction + "\", \"clickurl\": \"" + clickurl + "\", \"price\": \"" + price + "\", \"bidid\": \"" + bidId + "\", \"bidcur\": \"" + bidCur + "\" }"


	RemoteAddr, err := net.ResolveUDPAddr("udp", os.Getenv("LOG_HOST"))
	conn, err := net.DialUDP("udp", nil, RemoteAddr)
	defer conn.Close()
	if err != nil {
		log.Println(err)
	}
	noticetopicPayload := "winnotice|"
	nmessage := []byte(noticePayload)
	ntopic := []byte(noticetopicPayload)
	_, err = conn.Write(append(ntopic, nmessage...))
	if err != nil {
		log.Println(err)
	}
}

func lurl(rw http.ResponseWriter, req *http.Request) {

	if err := req.ParseForm(); err != nil {
		log.Printf("Error parsing form: %s", err)
		return
	}
	strTime := strconv.Itoa(int(time.Now().Unix()))
	partner := req.Form.Get("partner")

	fmt.Println(partner + " sent loss notification at " + strTime)
}
