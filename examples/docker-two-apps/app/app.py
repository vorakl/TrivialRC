from flask import Flask
from flask import request
from flask import jsonify    
import socket

app = Flask(__name__)

@app.route("/")
def hello():

    return jsonify(host=socket.gethostname(),
                   host_url=request.host_url,
                   base_url=request.base_url,
                   headers={ k:v for k, v in request.headers },
                   cookies=request.cookies,
                   query_string=request.query_string.decode(),
                   path=request.path,
                   full_path=request.full_path,
                   method=request.method,
                   scheme=request.scheme)

if __name__ == "__main__":
    app.run()

