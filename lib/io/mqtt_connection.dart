
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/robot_state.dart';

import 'server.dart' if (dart.library.html) 'browser.dart' as mqttclient;
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'dart:math';
import 'dart:ui';
import 'package:bson/bson.dart';

class MqttConnection  {

  static final MqttConnection _instance = MqttConnection._internal();
  int _client_id = 0;
  // singleton constructor
  MqttConnection._internal() {
    final rng = Random();
    _client_id = rng.nextInt(99999);
  }

  factory MqttConnection() {
    return _instance;
  }

  bool _connecting = false;

  final SettingsController settingsController = Get.find();
  final RobotStateController robotStateController = Get.find();

  final client = mqttclient.get();


  void disconnect() {
    client.autoReconnect = false;
    client.onDisconnected = null;
    client.disconnect();
  }

  void start() {
    // client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.autoReconnect = false;
    client.resubscribeOnAutoReconnect = false;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }

  MapAreaModel convertAreaToPath(area) {
    Path areaPoly = Path();
    {
      bool first = true;
      for (final pt in area["outline"]) {
        if (first) {
          areaPoly.moveTo(pt["x"], -pt["y"]);
          first = false;
        } else {
          areaPoly.lineTo(pt["x"], -pt["y"]);
        }
      }
      areaPoly.close();
    }
    final List<Path> obstaclePolys = [];
    {
      final obs = area["obstacles"] ?? [];
      for (final list in obs) {
        Path obstaclePoly = Path();
        bool first = true;
        for (final pt in list) {
          if (first) {
            obstaclePoly.moveTo(pt["x"], -pt["y"]);
            first = false;
          } else {
            obstaclePoly.lineTo(pt["x"], -pt["y"]);
          }
        }
        obstaclePoly.close();
        obstaclePolys.add(obstaclePoly);
      }
    }


    return MapAreaModel(areaPoly, obstaclePolys);
  }

  void parseMap(obj) {
    final mapModel = MapModel();

    mapModel.width =   obj["d"]["meta"]["mapWidth"] ?? 0;
    mapModel.height =  obj["d"]["meta"]["mapHeight"] ?? 0;
    mapModel.centerX = obj["d"]["meta"]["mapCenterX"] ?? 0;
    mapModel.centerY = obj["d"]["meta"]["mapCenterY"] ?? 0;

    final wa = obj["d"]["working_areas"];
    if(wa != null) {
      for(final area in wa) {
        mapModel.mowingAreas.add(convertAreaToPath(area));
      }
    }
    final na = obj["d"]["navigation_areas"];
    if(na != null) {
      for(final area in na) {
        mapModel.navigationAreas.add(convertAreaToPath(area));
      }
    }

    print("Got a map with ${mapModel.mowingAreas.length} mowing areas and ${mapModel.navigationAreas.length} navigation areas. Size: ${mapModel.width} x ${mapModel.height}");

    final RobotStateController robotStateController = Get.find();
    robotStateController.map.value = mapModel;
    robotStateController.map.refresh();
  }

  void parseRobotState(obj) {
    RobotState state = RobotState();
    state.posX = obj["d"]["pose"]["x"];
    state.posY = obj["d"]["pose"]["y"];
    state.heading = obj["d"]["pose"]["heading"];
    state.posAccuracy = obj["d"]["pose"]["pos_accuracy"];
    state.headingAccuracy = obj["d"]["pose"]["heading_accuracy"];
    state.headingValid = obj["d"]["pose"]["heading_valid"] > 0;
    robotStateController.robotState.value = state;
  }

  void onConnected() {
    print("MQTT connected");
    robotStateController.setConnected(true);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {

      for (var msg in c) {
          // print("got message on ${msg.topic}");
          final payload = msg.payload as MqttPublishMessage;
          switch(msg.topic) {
            case "map/bson": {
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BSON().deserialize(BsonBinary.from(bytes));
              parseMap(object);
            }
            break;
            case "robot_state/bson": {
              // Got the robot state
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BSON().deserialize(BsonBinary.from(bytes));
              parseRobotState(object);
            }
            break;
          }
      }
    });

    client.subscribe("map/bson", MqttQos.atLeastOnce);
    client.subscribe("robot_state/bson", MqttQos.atMostOnce);
  }

  void onDisconnected() {
    print("MQTT disconnected");
    robotStateController.setConnected(false);
  }

  void connect() async {
    if(_connecting) {
      print("MQTT already connecting, ignoring connect() call");
      return;
    }
    _connecting = true;

    client.disconnect();

    if(mqttclient.isWebSocket()) {
      client.server = "ws://${settingsController.hostname}/";
    } else{
      client.server = settingsController.hostname;
    }
    client.port = settingsController.mqttPort;


    final connMess = MqttConnectMessage()
    // .withProtocolName("mqtt")
    // .withProtocolName("websocket")
    // .startClean()
        .withClientIdentifier("om-client-$_client_id");
      // .authenticateAs(settingsController.mqttUsername, settingsController.mqttPassword);

    print('Mosquitto client connecting to ${client.server} on ${client.port}....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
      _connecting = false;

      return;
    }
    print("MQTT connect success!");
    _connecting = false;
  }

  void tryConnect() {
    if(client.connectionStatus?.state == MqttConnectionState.connected || client.connectionStatus?.state == MqttConnectionState.connecting) {
      return;
    }
    print("trying reconnect MQTT");
    connect();
  }

}