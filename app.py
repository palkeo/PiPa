#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys
import logging

from flask import Flask
from flask import render_template, jsonify
from flask.ext.socketio import SocketIO
from flask.ext.socketio import emit

from emoncms import EmoncmsClient

from sources import StupidCount, CpuUsage
from sources_emoncms import EmoncmsSource

from ctrl_api import api as ctrl_api

## manage emoncms data source
with open("emonsrc_config_grange.txt") as emoncfg:
    url = emoncfg.readline().strip()
    key_beytan = emoncfg.readline().strip()
    emoncms_grange = EmoncmsClient(url, key_beytan)

## manage emoncms data source
with open("emonsrc_config_maison.txt") as emoncfg:
    url = emoncfg.readline().strip()
    key_beytan = emoncfg.readline().strip()
    emoncms_maison = EmoncmsClient(url, key_beytan)

# data source configuration
sources = [
    StupidCount("count", update_freq=10),
    CpuUsage("cpu"),
    EmoncmsSource("ext_temp", emoncms_grange, feedid=34, unit="°C"),
    EmoncmsSource("ext_hum", emoncms_grange, feedid=38, unit="%"),
    EmoncmsSource("grange_temp", emoncms_grange, feedid=40, unit="°C"),
    EmoncmsSource("conso_pc", emoncms_maison, feedid=54, unit="W"),
]

logger = logging.getLogger()

# index of sources by name
source_idx = {
    src.name: src for src in sources
}

## Build the app
app = Flask(__name__)
app.debug = False
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

app.register_blueprint(ctrl_api, url_prefix="/ctrl")

@app.route("/")
def index():
    return render_template('index.html')

@socketio.on('connect', namespace="/dash")
def dash_client_connect():
    print "Connected to dash"
    emit('Connected', {"ok":"ok"})

@app.route("/dash/<dname>")
def switch_dash(dname):
    res = {}
    res["dash"] = dname
    socketio.emit('update', res, namespace="/dash")
    res["comment"] = "This new dash has been asked, it should be ok..."
    return jsonify(res)

@app.route("/source")
def sources_list():
    res = {}
    res["nb"] = len(sources)
    res["sources"] = [src.desc() for src in sources]
    return jsonify(res)

@app.route("/source/<source>")
def source_get(source):
    src = source_idx[source]
    res = src.export()
    return jsonify(res)

def register_source(src):
    namespace = '/source/'+src.name

    def change_callback():
        socketio.emit('update', src.export(), namespace=namespace)
    src.on_change(change_callback)

    def on_connect():
        print "Connected to %s" % namespace
        emit('Connected', src.desc())
    socketio.on('connect', namespace=namespace)(on_connect)

# plug change callback
for src in sources:
    register_source(src)

# run sources
for src in sources:
    src.start()

if __name__ == '__main__':
    ## logger
    level = logging.DEBUG
    logger.setLevel(level)
    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(level)
    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s:%(levelname)s:%(name)s:%(message)s')
    ch.setFormatter(formatter)
    # add the handlers to the logger
    logger.addHandler(ch)

    socketio.run(app, host="0.0.0.0", port=5005)

