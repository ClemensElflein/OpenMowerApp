
import 'package:mqtt5_client/mqtt5_client.dart';

import 'server.dart' if (dart.library.html) 'browser.dart' as mqttclient;
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';

class MqttConnection  {

  static final MqttConnection _instance = MqttConnection._internal();

  // singleton constructor
  MqttConnection._internal();

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
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.autoReconnect = false;
    client.resubscribeOnAutoReconnect = false;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }


  void onConnected() {
    print("MQTT connected");
    robotStateController.setConnected(true);
    //
    // client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    //   print(c);
    //   final recMess = c[0].payload as MqttPublishMessage;
    //   final pt = MqttUtilities.bytesToStringAsString(recMess.payload.message!);
    //
    //   /// The above may seem a little convoluted for users only interested in the
    //   /// payload, some users however may be interested in the received publish message,
    //   /// lets not constrain ourselves yet until the package has been in the wild
    //   /// for a while.
    //   /// The payload is a byte buffer, this will be specific to the topic
    //   print(
    //       'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    //   print('');
    // });

    client.subscribe("sensors/+/info", MqttQos.atLeastOnce);
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


    // final connMess = MqttConnectMessage()
    // .withProtocolName("mqtt")
    // .withProtocolName("websocket")
    // .startClean()
    //     .withClientIdentifier("client-11");
      // .authenticateAs(settingsController.mqttUsername, settingsController.mqttPassword);

    print('Mosquitto client connecting to ${client.server} on ${client.port}....');
    // client.connectionMessage = connMess;

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