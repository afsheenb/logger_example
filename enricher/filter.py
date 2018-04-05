#!flask/bin/python
import json
from flask import Flask,jsonify,abort,request

app = Flask(__name__)

@app.route('/filter/', methods=['POST'])
def filter():
    content = request.get_json(silent=True,force=True)
    data = {}
    f = open('blacklist.txt')
    s = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
    if s.find(content['IP']) != -1:
        data ['status'] = 'allowed'
    else:
      data['status'] = "No match in IP blacklist database!"  
    
    json_data = json.dumps(data)
    json_data = json_data + '\n'
    return json_data 

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=80, debug=True)
