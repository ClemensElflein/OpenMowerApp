import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:get_storage/get_storage.dart';


class SettingsController extends GetxController {
  var hostname = "".obs;
  var mqttUsername = "".obs;
  var mqttPassword = "".obs;
  var mqttPort = 0.obs;

  final hostnameController = TextEditingController();
  final mqttUsernameController = TextEditingController();
  final mqttPasswordController = TextEditingController();
  final mqttPortController = TextEditingController();

  void load() {
    final box = GetStorage();
    hostname.value = box.read("mqtt_hostname") ?? "127.0.0.1";
    mqttUsername.value = box.read("mqtt_username") ?? "";
    mqttPassword.value = box.read("mqtt_password") ?? "";
    mqttPort.value = box.read("mqtt_port") ?? 9001;

    hostnameController.text = hostname.value;
    mqttUsernameController.text = mqttUsername.value;
    mqttPasswordController.text = mqttPassword.value;
    mqttPortController.text = mqttPort.value.toString();
    update();
  }

  void save() {
    final box = GetStorage();

    hostname.value = hostnameController.text;
    mqttUsername.value = mqttUsernameController.text;
    mqttPassword.value = mqttPasswordController.text;
    mqttPort.value = int.tryParse(mqttPortController.text) ?? 1883;

    box.write("mqtt_hostname", hostname.value);
    box.write("mqtt_username", mqttUsername.value);
    box.write("mqtt_password", mqttPassword.value);
    box.write("mqtt_port", mqttPort.value);
    box.save();

    hostnameController.text = hostname.value;
    mqttUsernameController.text = mqttUsername.value;
    mqttPasswordController.text = mqttPassword.value;
    mqttPortController.text = mqttPort.value.toString();
    update();

    // reconnect mqtt
    final MqttConnection mqttConnection = Get.find();
    mqttConnection.connect();
  }
}