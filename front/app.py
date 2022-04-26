#!/usr/bin/python3

# import urllib.request as req
import os
# from os import environ,getenv
from os import getenv
from dotenv import load_dotenv
import sys
import json
import requests
# import logging
from time import time 
# from psycopg2 import Error
from flask import Flask,request,render_template
import datetime
import psutil
from psutil import getloadavg
# from psutil import cpu_percent,getloadavg
# from prometheus_flask_exporter import PrometheusMetrics

host=getenv('HOSTNAME')
STRESSTIME=30
load_dotenv()

currtime = datetime.datetime.now()
current_time = currtime.strftime("%H:%M:%S")

backapp = "http://epamapp-back:8080"

def cpustress(seconds):
    assert type(seconds) == type(1) and seconds < 120
    start=time()
    while True:
        a=1
        while a < 1000:
            x=a*a
            x=1.3333*x/(a+7.7777)
            a+=1
        if (time() - start) > seconds:
            break

app = Flask(__name__)
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0

# metrics = PrometheusMetrics(app)

@app.route('/ping')
def ping():
    return "PONG! %s im alive!" %(host)

@app.route('/pingback')
def pingback():
    response = requests.get(backapp + "/back/ping")
    return response.json()
    
@app.route('/getdata')
def getdata():
    response = requests.get(backapp + "/back/getdata")
    return response.json()

@app.route('/cleandata')
def cleandata():
    tablewipe()
    response = requests.get(backapp + "/back/cleandata")
    return response.json()

# @app.route('/showmeallweather')
# def showmeallweather():
#     allweather()
#     return "index html from host %host ready at"+current_time

# @app.route('/stress/<int:seconds>')
# def stresssec(seconds):
#     pystress(seconds, 1)
#     return "shake me at %s" %(host)

@app.route("/stress")
def stress():
    cpustress(STRESSTIME)
    return "Host %s stressed for 30 sec.\n" %(host)

@app.route("/stressback")
def stressback():
    response = requests.get(backapp + "/back/stress")
    return response.json()   

@app.route("/cpu")
def cpu():
    out=getloadavg()[0]
    return "Host: %s, CPU load: %s\n" %(host, out)

@app.route("/cpuback")
def cpuback():
    response = requests.get(backapp + "/back/cpu")
    return response.json()     

@app.route('/')    
def homepage():
    return render_template('fill.html')
    
@app.route('/showmeweather')
def showmeweather():
    date = request.args.get('date')
    response = requests.get(backapp + "/showmeweather?date=" + date)
    rows = response.json()
    # print (answer)
    # data = '''
    # <html> <style> table,  td {border:1px solid black; }td</style><body><table>%s</table></body></html>'''%(rows)
    return render_template('shooooooooooooow.html', text=rows)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
    app.run(debug=True)

