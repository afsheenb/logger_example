#!/usr/bin/env python

from datadog import initialize
import requests
import os
import sys

from http.server import BaseHTTPRequestHandler, HTTPServer

class heartbeat_handler(BaseHTTPRequestHandler):


    def log_to_datadog(self,status_code,message):

        api_key=os.environ['API_KEY']
        app_key=os.environ['APP_KEY']

        options = {
            'api_key': os.environ['API_KEY'],
            'app_key': os.environ['APP_KEY'],
        }        

        initialize(**options)

        # Use Datadog REST API client
        from datadog import api

        title = "Local Prebid-server call failed"
        text = 'Status code: {} Response: {}'.format(status_code,message)
        alert_type = "error"
        tags = ['version:1', 'application:pbs']
        api.Event.create(title=title, text=text, tags=tags, alert_type=alert_type)


    def do_GET(self):

        import validators

        url = os.environ['PBS_URL']

        if not validators.url(url):
            print("URL: {} is invalid".format(url))
            sys.exit(1)


        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:52.0) Gecko/20100101 Firefox/44.0 Cyberfox/52.6.1",
            "Accept-Language": "en-US"
        }

        data = {
            "id": "some-request-id",
            "imp": [{
                "id": "some-impression-id",
                "banner": {
                    "format": [{
                        "w": 300,
                        "h": 250
                    }, {
                        "w": 300,
                        "h": 600
                    }]
                },
                "debug": "1",
                "ext": {
                    "oappnexus": {
                        "placementId": 6546370
                    }
                }
            }],
            "test": 1,
            "tmax": 500,
            "site": {
                "page": "http://demo.the-ozone-project.com"
            }
        }

        r = requests.post(url, json=data,headers=headers)

        status_code=r.status_code
        message=r.text
        print(status_code,message)
        # Send response status code
        self.send_response(status_code)

        # Write content as utf-8 data
        self.wfile.write(bytes(message, "utf8"))
        if status_code != 200:
            self.log_to_datadog(status_code,message)
        return


def run():
    print('starting heartbeat server...')
    server_address = ('127.0.0.1', 8081)
    httpd = HTTPServer(server_address, heartbeat_handler)
    print('running heartbeat server...')
    httpd.serve_forever()

run()
