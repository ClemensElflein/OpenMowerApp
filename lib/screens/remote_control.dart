import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class RemoteControl extends GetView<RemoteController> {
  RemoteControl({super.key});

  final RobotStateController robotState = Get.find();

  Widget buildSaveAreaDialog() {
    return n.Alert.adaptive()
      ..title = "Save Area".n
      ..content = "Save area as navigation area or as mowing area?".n
      ..actions = [
        n.Button("Mowing Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_mowing_area")
          ..onPressed = () {
            controller
                .callAction("mower_logic:area_recording/finish_mowing_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Navigation Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_navigation_area")
          ..onPressed = () {
            controller.callAction(
                "mower_logic:area_recording/finish_navigation_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Don't Save".n)
          ..onPressed = () {
            controller.callAction("mower_logic:area_recording/finish_discard");
            Get.back();
          }
          ..bold
          ..color = Colors.red
          ..p = 24
      ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapWidget(centerOnRobot: true),
        n.Column([
          Expanded(
              child: Align(
            alignment: const Alignment(0, 0.8),
            child: Joystick(
              mode: JoystickMode.all,
              onStickDragEnd: () {
                controller.sendMessage(0, 0);
              },
              listener: (details) {
                controller.joystickCommand.value =
                    JoystickCommand(-details.y * 1.0, -details.x * 1.6);
              },
            ),
          )),
          Material(
              elevation: 5,
              child: Obx(() => n.Column([
                /*Padding(padding: const EdgeInsets.all(32), child:
                Joystick(
                  mode: JoystickMode.all,
                  onStickDragEnd: () {
                    controller.sendMessage(0, 0);
                  },
                  listener: (details) {
                    controller.joystickCommand.value =
                        JoystickCommand(-details.y * 1.0, -details.x * 1.6);
                  },
                )),*/
                    n.Row([
                      !robotState.hasAction(
                              "mower_logic:area_recording/stop_recording")
                          ? (n.Button.elevatedIcon("Start Recording".n,
                              n.Icon(Icons.fiber_manual_record))
                            ..enable = robotState.hasAction(
                                "mower_logic:area_recording/start_recording")
                            ..onPressed = () {
                              controller.callAction(
                                  "mower_logic:area_recording/start_recording");
                            }
                            ..expanded
                            ..elevation = 2
                            ..p = 16)
                          : (n.Button.elevatedIcon("Stop Recording".n,
                              n.Icon(Icons.fiber_manual_record))
                            ..visible = robotState.hasAction(
                                "mower_logic:area_recording/stop_recording")
                            ..onPressed = () {
                              controller.callAction(
                                  "mower_logic:area_recording/stop_recording");
                            }
                            ..style = n.ButtonStyle(backgroundColor: Colors.red)
                            ..expanded
                            ..elevation = 2
                            ..p = 16),
                      n.Button.elevatedIcon("Finish Area".n, n.Icon(Icons.stop),
                          onPressed: () {
                        n.showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => buildSaveAreaDialog());
                      })
                        ..enable = robotState
                            .hasAnyAction(["mower_logic:area_recording/finish_navigation_area","mower_logic:area_recording/finish_mowing_area","mower_logic:area_recording/finish_discard"])
                        ..elevation = 2
                        ..p = 16,
                    ])
                      ..gap = 8
                      ..px = 16
                      ..py = 8,
                    n.Row([
                      n.Button.elevatedIcon(
                          "Record Docking".n, n.Icon(Icons.home))
                        ..enable = robotState
                            .hasAction("mower_logic:area_recording/record_dock")
                        ..onPressed = () {
                          controller.callAction(
                              "mower_logic:area_recording/record_dock");
                        }
                        ..elevation = 2
                        ..expanded
                        ..p = 16,
                      n.Button.elevatedIcon(
                          "Exit Recording Mode".n, n.Icon(Icons.exit_to_app))
                        ..enable = robotState.hasAction(
                            "mower_logic:area_recording/exit_recording_mode")
                        ..onPressed = () {
                          controller.callAction(
                              "mower_logic:area_recording/exit_recording_mode");
                        }
                        ..elevation = 2
                        ..expanded
                        ..p = 16,
                    ])
                      ..gap = 8
                      ..px = 16
                      ..py = 8,
                  ])..py=8)),
        ]),
        const RobotStateWidget(),
      ],
    );
  }
}
