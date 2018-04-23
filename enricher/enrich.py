#!flask/bin/python
import geoip2.database
from referer_parser import Referer
import json
from flask import Flask,jsonify,abort,request

app = Flask(__name__)

@app.route('/enrich/', methods=['POST'])
def enrich():
    content = request.get_json(silent=True,force=True)
    reader = geoip2.database.Reader('/usr/src/geoip-databases/GeoIP2-City.mmdb')
    data = {}

    try:
      response = reader.city(content['IP'])
      data['city'] = response.city.name
      data['state'] = response.subdivisions.most_specific.name
      data['country'] = response.country.name
    except:
      data['geoip_enrichment_error'] = "No match in GeoIP database!"  
    
    try:
      r = Referer(content['Referer'])
      data['referer'] = r.referer
      data['referer_medium'] = r.medium
    except:
      data['referer_enrichment_error'] = "No match in Referer database!"  

    json_data = json.dumps(data)
    json_data = json_data + '\n'
    return json_data 

@app.route('/check/', methods=['GET'])
def check():
    return "200 OK\n"

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=8081, debug=True)
