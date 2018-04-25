#!flask/bin/python
import json
import geoip2.database
import mmap
from flask import Flask,jsonify,abort,request

app = Flask(__name__)

@app.route('/filter/', methods=['POST'])
def filter():
    content = request.get_json(silent=True,force=True)
    reader = geoip2.database.Reader('/usr/src/ozone/ozone-code/geoip-databases/GeoIP2-City.mmdb')
    data = {}
    geodata = {}
    try:
      response = reader.city(content['IP'])
      geodata['city'] = response.city.name
      geodata['state'] = response.subdivisions.most_specific.name
      geodata['country'] = response.country.name
    except:
      geodata['geoip_enrichment_error'] = "No match in GeoIP database!" 
    if content['IP'] in open('ip_blacklist.txt').read():
      data ['status'] = True
    elif str(geodata['country']) in open('country_blacklist.txt').read():
      data ['status'] = True
    elif str(geodata['city']) in open('city_blacklist.txt').read():
      data ['status'] = True
    else:
      data['status'] = False
    json_data = json.dumps(data)
    return json_data 

@app.route('/check/', methods=['GET'])
def check():
    return "200 OK\n"

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=8082, debug=True)
