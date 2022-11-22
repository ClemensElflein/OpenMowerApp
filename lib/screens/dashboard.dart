import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class Dashboard extends GetView<RobotStateController> {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return n.Stack(
      [
        MapWidget(),
        n.Column([
          n.Column([
            Card(
              elevation: 3,
              child: n.Column([
                "Current State:".bodyLarge..m = 4,
                "Mowing - Docking".h4..m = 4
              ])
                ..p = 16
                ..mainAxisAlignment = MainAxisAlignment.start
                ..crossAxisAlignment = CrossAxisAlignment.start
                ..fullWidth,
            ),
          ])
            ..p = 16
            ..expanded,
          Material(
              elevation: 5,
              child: n.Row([
                Obx(() {
                  return n.Button.elevatedIcon(
                      !controller.robotState.value.isRunning
                          ? "Start".n
                          : "Pause".n,
                      !controller.robotState.value.isRunning
                          ? n.Icon(Icons.play_arrow)
                          : n.Icon(Icons.pause), onPressed: () {
                    if (controller.robotState.value.isRunning) {
                      controller.stop();
                    } else {
                      controller.start();
                    }
                  })
                    ..expanded
                    ..elevation = 2
                    ..p = 24;
                }),
                n.Button.elevatedIcon("Stop".n, n.Icon(Icons.stop),
                    onPressed: () {})
                  ..elevation = 2
                  ..style = n.ButtonStyle(backgroundColor: Colors.grey)
                  ..p = 24,
              ])
                ..gap = 8
                ..p = 24)
        ])
          ..mt = 60,
        const RobotStateWidget(),
      ],
    )..fullSize;
  }
}
