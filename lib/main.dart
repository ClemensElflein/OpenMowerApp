import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/sensors_controller.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:open_mower_app/screens/main_screen.dart';

void main() async {
  await GetStorage.init();

  // Put the settings controller first, other controllers might need it.
  final settingsController = Get.put(SettingsController());
  settingsController.load();

  // Second the robotStateController. MQTTConnection needs it
  final robotStateController = Get.put(RobotStateController());
  final sensorStateController = Get.put(SensorsController());

  initServices();
  final MqttConnection mqttConnection = Get.find();

  mqttConnection.start();

  Get.put(RemoteController());

  // Periodic MQTT reconnect
  Timer.periodic(const Duration(seconds: 1), (timer) {
    mqttConnection.tryConnect();
  });






  runApp(const MyApp());
}


Future<void> initServices() async {
  if(!Get.isRegistered<MqttConnection>()) {
    Get.put<MqttConnection>(MqttConnection(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OpenMower',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
          useMaterial3: false,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light
      ),
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => MainScreen())
      ],
    );
  }


}
