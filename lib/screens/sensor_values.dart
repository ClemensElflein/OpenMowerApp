import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/sensors_controller.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';
import 'package:open_mower_app/views/sensor_widget.dart';

// List the major known sensors in a constant order.
// New/unknown sensors get published behind.
final List<String> widgetSortList = [
  'om_gps_accuracy',
  'om_v_battery',
  'om_v_charge',
  'om_charge_current',
  'om_mow_motor_rpm',
  'om_mow_motor_current',
  'om_mow_motor_temp',
  'om_mow_esc_temp',
  'om_left_esc_temp',
  'om_right_esc_temp'
];

class SensorValues extends GetView<SensorsController> {
  const SensorValues({super.key});

  @override
  Widget build(BuildContext context) {
    return n.Stack(
      [
        n.Column([
          Obx(()=>
          n.GridView.extent(
            maxCrossAxisExtent: 200,
          )
            ..p = 16
            ..children = Map.fromEntries(
              controller.sensorStates.entries
              .toList(growable: false)
              ..sort((a, b) {
                int ai = widgetSortList.indexWhere((key) => key == a.key);
                int bi = widgetSortList.indexWhere((key) => key == b.key);

                // Append non-listed sensors (instead of prepend)
                if (ai < 0) ai = widgetSortList.length;
                if (bi < 0) bi = widgetSortList.length;

                return ai.compareTo(bi);
              }))
              .entries
                .map((e) => SensorWidget(sensor: e.value))
                .toList(growable: false)
          // ..backgroundColor = Colors.red
            ..wFull
            ..hFull
            ..crossAxisSpacing = 8
            ..mainAxisSpacing = 8
            ..expanded),
        ])
          ..mt=60,
        const RobotStateWidget()
      ],
    )..fullSize;
  }
}
