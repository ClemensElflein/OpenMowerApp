import 'package:bson/bson.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:typed_data/typed_data.dart';

class RemoteController extends GetxController {

  final SettingsController settingsController = Get.find();
  final MqttConnection _mqttConnection = Get.find();

  WebSocketChannel? channel;
  final joystickCommand = const JoystickCommand(0,0).obs;

  @override
  void onInit() {
    super.onInit();

    interval(joystickCommand, (callback) => {
      sendMessage(callback.x, callback.z)
    }, time: const Duration(milliseconds: 20));

    // for safety, if joystick command wasnt changed for some time, send a 0
    debounce(joystickCommand, (callback) => {sendMessage(0,0)}
        , time: const Duration(milliseconds: 100));

    // listen on hostname changes, then invalidate the channel
    ever(settingsController.hostname, (callback) => (){
      print("settings changed, resetting websocket");
      channel = null;
    });
  }

  void connectWebsocket() {
    if(kIsWeb && kReleaseMode) {
      // Release and web, we can just connect to the root of the current URL
      channel = WebSocketChannel.connect(Uri.parse('ws://${Uri.base.host}:9002'));
    } else {
      // Connect according to settings
      channel = WebSocketChannel.connect(Uri.parse('ws://${settingsController.hostname}:9002'));
    }

  }

  void sendMessage(double x, double r) {
    if(channel == null || channel?.closeCode != null) {
      // reconnect
      connectWebsocket();
    }
    if(channel != null) {
      final map = {"vx": x,
        "vz": r};
      final binary = BSON().serialize(map);
      channel?.sink.add(binary.byteList);
    }
  }

  void callAction(String action) {
    _mqttConnection.callAction(action);
  }
}