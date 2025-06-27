#!/usr/bin/env python
# -*- coding: utf-8 -*-
import paho.mqtt.client as mqtt 
import time
import bson
import random

topic = "python/mqtt"
client_id = f'python-mqtt-{random.randint(0, 1000)}'

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, reason_code, properties):
    print(f"Connected with result code {reason_code}")

def on_connect_fail(client, userdata, flags, rc):
    print('error')

def on_subscribe(client, userdata, mid, reason_code_list, properties):
    # Since we subscribed only for a single channel, reason_code_list contains
    # a single entry
    if reason_code_list[0].is_failure:
        print(f"Broker rejected you subscription: {reason_code_list[0]}")
    else:
        print(f"Broker granted the following QoS: {reason_code_list[0].value}")

def on_unsubscribe(client, userdata, mid, reason_code_list, properties):
    # Be careful, the reason_code_list is only present in MQTTv5.
    # In MQTTv3 it will always be empty
    if len(reason_code_list) == 0 or not reason_code_list[0].is_failure:
        print("unsubscribe succeeded (if SUBACK is received in MQTTv3 it success)")
    else:
        print(f"Broker replied with failure: {reason_code_list[0]}")
    client.disconnect()



# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

def robot_state_publish():
    
    j ={ "d":
        {
        "battery_percentage": 0.8,
        "gps_percentage": 0.9,
        "current_action_progress": 0.56,
        "current_state": "AREA_RECORDING",
        "current_sub_state": "",
        "current_area": 10,
        "current_path": 0,
        "current_path_index": 0,
        "emergency": 0,
        "is_charging": 0,
        "rain_detected": 0,
        "pose": {
            "x": 0,
            "y": 0,
            "heading": 0,
            "pos_accuracy": 0,
            "heading_accuracy": 0,
            "heading_valid": 0
            }   
        }
    }

    topic_data = bson.dumps(j)
    client.publish("robot_state/bson", topic_data)


    


def publish(client):
    while True:
        time.sleep(1)
        robot_state_publish()

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
client.on_connect = on_connect
client.on_connect_fail = on_connect_fail
client.on_message = on_message
client.on_subscribe = on_subscribe
client.on_unsubscribe = on_unsubscribe
client.connect('127.0.0.1', 1883, 60)
client.subscribe("actions/bson")
client.loop_start()
publish(client)
client.loop_stop()    