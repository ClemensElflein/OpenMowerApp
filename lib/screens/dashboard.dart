import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/screens/remote_control.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class Dashboard extends GetView<RobotStateController> {
  Dashboard({super.key});

  final RemoteController remoteControl = Get.find();

  @override
  Widget build(BuildContext context) {
    return n.Stack(
      [
        const MapWidget(),
        n.Column([
          n.Column([
            Card(
              elevation: 3,
              child: n.Column([
                "Current State:".bodyLarge..m = 4,
                Obx(() => controller.robotState.value.currentState.h4..m = 4)
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
              child: Obx(() => n.Row([
                    !controller.hasAction("mower_logic:mowing/pause")
                        ? (n.Button.elevatedIcon(
                            "Start Mowing".n, n.Icon(Icons.play_arrow))
                          ..enable = (controller
                                  .hasAction("mower_logic:idle/start_mowing") ||
                              controller
                                  .hasAction("mower_logic:mowing/continue"))
                          ..onPressed = () {
                            if (controller
                                .hasAction("mower_logic:idle/start_mowing")) {
                              remoteControl
                                  .callAction("mower_logic:idle/start_mowing");
                            } else if (controller
                                .hasAction("mower_logic:mowing/continue")) {
                              remoteControl
                                  .callAction("mower_logic:mowing/continue");
                            }
                          }
                          ..expanded
                          ..elevation = 2
                          ..p = 24)
                        : (n.Button.elevatedIcon(
                            "Pause Mowing".n, n.Icon(Icons.pause))
                          ..enable =
                              controller.hasAction("mower_logic:mowing/pause")
                          ..onPressed = () {
                            remoteControl
                                .callAction("mower_logic:mowing/pause");
                          }
                          ..expanded
                          ..elevation = 2
                          ..p = 24),
                    n.Button.elevatedIcon("Stop".n, n.Icon(Icons.home))
                      ..enable = controller
                          .hasAction("mower_logic:mowing/abort_mowing")
                      ..onPressed = () {
                        remoteControl
                            .callAction("mower_logic:mowing/abort_mowing");
                      }
                      ..elevation = 2
                      ..p = 24,
                    n.Button.elevatedIcon(
                        "Area Recording".n, n.Icon(Icons.fiber_manual_record))
                      ..enable = controller
                          .hasAction("mower_logic:idle/start_area_recording")
                      ..onPressed = () {
                        remoteControl.callAction(
                            "mower_logic:idle/start_area_recording");
                      }
                      ..elevation = 2
                      ..p = 24,
                  ])
                    ..gap = 8
                    ..p = 24))
        ])
          ..mt = 60,
        const RobotStateWidget(),
      ],
    )..fullSize;
  }
}
