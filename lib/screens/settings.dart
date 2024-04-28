import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'package:open_mower_app/views/sensor_widget.dart';

import 'main_screen.dart';

class Settings extends GetView<SettingsController> {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return n.Column([
      GetBuilder<SettingsController>(
          builder: (val) => Card(
            elevation: 3,
                  child: n.Column([
                Text("MQTT Settings", style: Theme.of(context).textTheme.headlineMedium).niku..mb = 8,
                n.TextFormField(
                    label: "Host".n, controller: controller.hostnameController),
                n.TextFormField(
                    label: "Username".n,
                    controller: controller.mqttUsernameController),
                n.TextFormField(
                    label: "Password".n,
                    controller: controller.mqttPasswordController)
                    ..asPassword,
                n.TextFormField(
                    label: "Port".n, controller: controller.mqttPortController),
              ])
                    ..m = 16
                    ..crossAxisAlignment = CrossAxisAlignment.start)),
      Expanded(child: Container()),
      n.Row([
        n.Button.elevatedIcon("Save Settings".n, n.Icon(Icons.check),
            onPressed: controller.save)
          ..elevation = 2
          ..p = 24
      ])
        ..mainAxisAlignment = MainAxisAlignment.end
        ..gap = 8
        ..p = 16
        ..mt = 32
    ])
      ..p = 16
      ..fullSize;
  }
}
