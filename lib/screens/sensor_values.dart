import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/sensors_controller.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';
import 'package:open_mower_app/views/sensor_widget.dart';

class SensorValues extends GetView<SensorsController> {
  const SensorValues({super.key});

  @override
  Widget build(BuildContext context) {
    return n.Stack(
      [
        n.Column([
          n.GridView.extent(
            maxCrossAxisExtent: 200,
          )
            ..p = 16
            ..children = controller.sensorStates.entries
                .map((e) => SensorWidget(sensor: e.value))
                .toList(growable: false)
          // ..backgroundColor = Colors.red
            ..wFull
            ..hFull
            ..crossAxisSpacing = 8
            ..mainAxisSpacing = 8
            ..expanded,
        ])
          ..mt=60,
        const RobotStateWidget()
      ],
    )..fullSize;
  }
}
