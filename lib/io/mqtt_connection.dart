
import 'package:flutter/foundation.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:open_mower_app/controllers/sensors_controller.dart';
import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/robot_state.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:open_mower_app/models/map_overlay_model.dart';

import 'server.dart' if (dart.library.html) 'browser.dart' as mqttclient;
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'dart:math';
import 'dart:ui';
import 'package:bson/bson.dart';
import 'package:typed_data/typed_data.dart';

class MqttConnection  {


  static final MqttConnection _instance = MqttConnection._internal();
  int clientId = 0;
  // singleton constructor
  MqttConnection._internal() {
    final rng = Random();
    clientId = rng.nextInt(99999);
  }

  factory MqttConnection() {
    return _instance;
  }

  bool _connecting = false;

  final SettingsController settingsController = Get.find();
  final RobotStateController robotStateController = Get.find();
  final SensorsController sensorsController = Get.find();

  final RegExp exp = RegExp(r'sensors/(.*)/bson');

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

  void sendJoystick(double x, double r, bool highQos) {
    final map = {"vx": x,
    "vz": r};
    final binary = BsonCodec.serialize(map);
    final buffer = Uint8Buffer();
    buffer.addAll(binary.byteList);
    try {
      client.publishMessage("teleop", highQos ? MqttQos.atLeastOnce : MqttQos.atMostOnce, buffer);
    } catch(e) {
      debugPrint("error publishing to mqtt");
    }

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
    mapModel.centerY = -obj["d"]["meta"]["mapCenterY"] ?? 0;
    mapModel.dockX =       obj["d"]["docking_pose"]["x"] ?? 0;
    mapModel.dockY =       -obj["d"]["docking_pose"]["y"] ?? 0;
    mapModel.dockHeading = obj["d"]["docking_pose"]["heading"] ?? 0;

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

    debugPrint("Got a map with ${mapModel.mowingAreas.length} mowing areas and ${mapModel.navigationAreas.length} navigation areas. Size: ${mapModel.width} x ${mapModel.height}. Docking pos: ${mapModel.dockX}, ${mapModel.dockY}");

    final RobotStateController robotStateController = Get.find();
    robotStateController.map.value = mapModel;
    robotStateController.map.refresh();
  }

  void parseMapOverlay(obj) {
    final overlayModel = MapOverlayModel();
    final polys = obj["d"]["polygons"];
    if(polys != null) {
      for(final poly in polys) {
        bool first = true;
        Path path = Path();
        for (final pt in poly["poly"]) {
          if (first) {
            path.moveTo(pt["x"], -pt["y"]);
            first = false;
          } else {
            path.lineTo(pt["x"], -pt["y"]);
          }
        }
        if(path.isBlank != true && poly["is_closed"] > 0) {
          path.close();
        }
        overlayModel.polygons.add(OverlayPolygon(path, poly["is_closed"] > 0, poly["line_width"], poly["color"]));
      }
    }


    robotStateController.mapOverlay.value = overlayModel;
    robotStateController.mapOverlay.refresh();
  }

  void parseRobotState(obj) {
    RobotState state        = RobotState();
    state.isConnected       = true;
    state.posX              = obj["d"]["pose"]["x"];
    state.posY              = -obj["d"]["pose"]["y"];
    state.heading           = obj["d"]["pose"]["heading"];
    state.posAccuracy       = obj["d"]["pose"]["pos_accuracy"];
    state.headingAccuracy   = obj["d"]["pose"]["heading_accuracy"];
    state.headingValid      = obj["d"]["pose"]["heading_valid"] > 0;
    state.isEmergency       = obj["d"]["emergency"] > 0;
    state.isCharging        = obj["d"]["is_charging"] > 0;
    state.rainDetected      = obj["d"]["rain_detected"] > 0;
    state.currentState      = obj["d"]["current_state"];
    state.gpsPercent        = obj["d"]["gps_percentage"];
    state.batteryPercent    = obj["d"]["battery_percentage"];
    state.currentArea       = obj["d"]["current_area"];
    state.currentPath       = obj["d"]["current_path"];
    state.currentPathIndex  = obj["d"]["current_path_index"];
    robotStateController.robotState.value = state;
  }



  void parseSensorInfos(obj) {
    debugPrint("Got new sensor infos, refreshing");
    for (final sensorInfo in obj["d"]) {
      switch (sensorInfo["value_type"]) {
        case "DOUBLE":
          {
            // Got a double sensor
            final sensor = DoubleSensorState(
                sensorInfo["sensor_name"],
                sensorInfo["unit"],
                sensorInfo["min_value"],
                sensorInfo["max_value"],
                sensorInfo["has_min_max"] == 1,
                sensorInfo["lower_critical_value"],
                sensorInfo["has_critical_low"] == 1,
                sensorInfo["upper_critical_value"],
                sensorInfo["has_critical_high"] == 1);
            sensorsController.sensorStates[sensorInfo["sensor_id"]] = sensor;
          }
      }
    }
    sensorsController.sensorStates.refresh();
  }

  void parseSensorData(sensorId, obj) {
    final sensor = sensorsController.sensorStates[sensorId];
    if(sensor != null) {
      sensor.value = obj["d"];
    }
    sensorsController.sensorStates.refresh();
  }

  void parseVersion(obj) {
    final String versionString = obj["version"];
    robotStateController.softwareVersion.value = versionString;
  }

  void parseActionInfos(obj) {
      final Set<String> newActionSet = {};
      for(final action in obj["d"]) {
        if(action["enabled"] > 0) {
          newActionSet.add(action["action_id"]);
        }
      }

      debugPrint("available actions: $newActionSet");
      // FIXME: invalid_use_of_protected_member
      robotStateController.availableActions.value = newActionSet;
  }

  void onConnected() {
    debugPrint("MQTT connected");
    robotStateController.setConnected(true);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {

      for (var msg in c) {
          debugPrint("got message on ${msg.topic}");
          final payload = msg.payload as MqttPublishMessage;
          switch(msg.topic) {
            case "version": {
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BsonCodec.deserialize(BsonBinary.from(bytes));
              parseVersion(object);
            }
            break;
            case "actions/bson": {
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BsonCodec.deserialize(BsonBinary.from(bytes));
              parseActionInfos(object);
            }
            break;
            case "map/bson": {
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BsonCodec.deserialize(BsonBinary.from(bytes));
              parseMap(object);
            }
            break;
            case "map_overlay/bson": {
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BsonCodec.deserialize(BsonBinary.from(bytes));
              parseMapOverlay(object);
            }
            break;
            case "robot_state/bson": {
              // Got the robot state
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BsonCodec.deserialize(BsonBinary.from(bytes));
              parseRobotState(object);
            }
            break;
            case "sensor_infos/bson": {
              // Got the robot state
              final bytes = payload.payload.message?.toList(growable: false);
              if(bytes == null || bytes.isBlank == true) {
                continue;
              }
              final object = BsonCodec.deserialize(BsonBinary.from(bytes));
              parseSensorInfos(object);
            }
            break;
            default: {
              if(msg.topic != null) {
                // It's probably some sensor data, get ID
                final match = exp.firstMatch(msg.topic!);
                if (match != null) {
                  // Got sensor data bson
                  final bytes = payload.payload.message?.toList(growable: false);
                  if(bytes == null || bytes.isBlank == true) {
                    continue;
                  }
                  final object = BsonCodec.deserialize(BsonBinary.from(bytes));
                  parseSensorData(match[1], object);
                } else {
                  debugPrint("got unknown message on topic: ${msg.topic}");
                }
              }
            }
            break;
          }
      }
    });

    client.subscribe("actions/bson", MqttQos.exactlyOnce);
    client.subscribe("map/bson", MqttQos.atLeastOnce);
    client.subscribe("map_overlay/bson", MqttQos.atMostOnce);
    client.subscribe("sensor_infos/bson", MqttQos.atLeastOnce);
    client.subscribe("robot_state/bson", MqttQos.atMostOnce);
    client.subscribe("robot_state/bson", MqttQos.atMostOnce);
    client.subscribe("sensors/+/bson", MqttQos.atMostOnce);
    client.subscribe("version", MqttQos.atLeastOnce);
  }

  void onDisconnected() {
    debugPrint("MQTT disconnected");
    robotStateController.setConnected(false);
  }

  void connect() async {
    if(_connecting) {
      debugPrint("MQTT already connecting, ignoring connect() call");
      return;
    }
    _connecting = true;

    client.disconnect();


    if(kIsWeb && kReleaseMode) {
      // Connect according to settings
      if(mqttclient.isWebSocket()) {
        client.server = "ws://${Uri.base.host}/";
      } else{
        client.server = Uri.base.host;
      }
      client.port = 9001;
    } else {
      // Connect according to settings
      if(mqttclient.isWebSocket()) {
        client.server = "ws://${settingsController.hostname}/";
      } else{
        client.server = settingsController.hostname.value;
      }
      client.port = settingsController.mqttPort.value;
    }



    final connMess = MqttConnectMessage()
    // .withProtocolName("mqtt")
    // .withProtocolName("websocket")
    // .startClean()
        .withClientIdentifier("om-client-$clientId");
      // .authenticateAs(settingsController.mqttUsername, settingsController.mqttPassword);

    debugPrint('Mosquitto client connecting to ${client.server} on ${client.port}....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      debugPrint('EXAMPLE::client exception - $e');
      client.disconnect();
      _connecting = false;

      return;
    }
    debugPrint("MQTT connect success!");
    _connecting = false;
  }

  void tryConnect() {
    if(client.connectionStatus?.state == MqttConnectionState.connected || client.connectionStatus?.state == MqttConnectionState.connecting) {
      return;
    }
    debugPrint("trying reconnect MQTT");
    connect();
  }

  void callAction(String action) {
    final builder = MqttPayloadBuilder();
    builder.addString(action);
    try {
      client.publishMessage("action", MqttQos.exactlyOnce, builder.payload!);
    } catch(e) {
      debugPrint("error publishing to mqtt");
    }
  }

}