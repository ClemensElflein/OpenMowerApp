import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:get_storage/get_storage.dart';


class SettingsController extends GetxController {
  var hostname = "";
  var mqttUsername = "";
  var mqttPassword = "";
  var mqttPort = 0;

  final hostnameController = TextEditingController();
  final mqttUsernameController = TextEditingController();
  final mqttPasswordController = TextEditingController();
  final mqttPortController = TextEditingController();

  void load() {
    final box = GetStorage();
    hostname = box.read("mqtt_hostname") ?? "127.0.0.1";
    mqttUsername = box.read("mqtt_username") ?? "";
    mqttPassword = box.read("mqtt_password") ?? "";
    mqttPort = box.read("mqtt_port") ?? 9001;

    hostnameController.text = hostname;
    mqttUsernameController.text = mqttUsername;
    mqttPasswordController.text = mqttPassword;
    mqttPortController.text = mqttPort.toString();
    update();
  }

  void save() {
    final box = GetStorage();

    hostname = hostnameController.text;
    mqttUsername = mqttUsernameController.text;
    mqttPassword = mqttPasswordController.text;
    mqttPort = int.tryParse(mqttPortController.text) ?? 1883;

    box.write("mqtt_hostname", hostname);
    box.write("mqtt_username", mqttUsername);
    box.write("mqtt_password", mqttPassword);
    box.write("mqtt_port", mqttPort);
    box.save();

    hostnameController.text = hostname;
    mqttUsernameController.text = mqttUsername;
    mqttPasswordController.text = mqttPassword;
    mqttPortController.text = mqttPort.toString();
    update();

    // reconnect mqtt
    final MqttConnection mqttConnection = Get.find();
    mqttConnection.connect();
  }
}