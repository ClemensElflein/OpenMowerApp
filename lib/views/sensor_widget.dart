import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_mower_app/controllers/sensors_controller.dart';
import 'package:open_mower_app/models/sensor_state.dart';

class SensorWidget extends StatelessWidget {
  final DoubleSensorState ?sensor;

  const SensorWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return
      Material(
        elevation: 2,
        child:
        n.Column([
          (sensor?.name ?? "N/A")
          .bodyMedium
          ..color = Colors.black54
          ..center,
          AutoSizeText(
            "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit}",
            maxLines: 1,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),
          )
        ])
          ..p = 12
          ..center
    );
  }
}
