import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:open_mower_app/screens/remote_control.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class Dashboard extends GetView<RobotStateController> {
  Dashboard({super.key});

  final RemoteController remoteControl = Get.find();

  @override
  Widget build(BuildContext context) {
    return n.Column([
      const RobotStateWidget(),
      n.Stack([
        const MapWidget(centerOnRobot: false),
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
      ])
        ..expanded,
      Material(elevation: 5, child: Obx(() => getButtonPanel(context, controller)))
    ]);
  }

  Widget getButtonPanel(BuildContext context, RobotStateController controller) {
    if (controller.robotState.value.currentState != "AREA_RECORDING") {
      return n.Row([
        !controller.hasAction("mower_logic:mowing/pause")
            ? (n.Button.elevatedIcon("Start".n, n.Icon(Icons.play_arrow))
              ..enable =
                  (controller.hasAction("mower_logic:idle/start_mowing") ||
                      controller.hasAction("mower_logic:mowing/continue"))
              ..onPressed = () {
                if (controller.hasAction("mower_logic:idle/start_mowing")) {
                  remoteControl.callAction("mower_logic:idle/start_mowing");
                } else if (controller
                    .hasAction("mower_logic:mowing/continue")) {
                  remoteControl.callAction("mower_logic:mowing/continue");
                }
              }
              ..expanded
              ..elevation = 2
              ..p = 16)
            : (n.Button.elevatedIcon("Pause".n, n.Icon(Icons.pause))
              ..enable = controller.hasAction("mower_logic:mowing/pause")
              ..onPressed = () {
                remoteControl.callAction("mower_logic:mowing/pause");
              }
              ..expanded
              ..elevation = 2
              ..p = 16),
        n.Button.elevatedIcon("Stop".n, n.Icon(Icons.home))
          ..enable = controller.hasAction("mower_logic:mowing/abort_mowing")
          ..onPressed = () {
            remoteControl.callAction("mower_logic:mowing/abort_mowing");
          }
          ..elevation = 2
          ..p = 16,
        n.Button.elevatedIcon(
            "Area Recording".n, n.Icon(Icons.fiber_manual_record))
          ..enable =
              controller.hasAction("mower_logic:idle/start_area_recording")
          ..onPressed = () {
            remoteControl.callAction("mower_logic:idle/start_area_recording");
          }
          ..elevation = 2
          ..p = 16,
      ])
        ..gap = 8
        ..p = 16;
    } else {
      return n.Column([
        Padding(padding: EdgeInsets.all(30), child:
        Joystick(
          mode: JoystickMode.all,
          onStickDragEnd: () {
            remoteControl.sendMessage(0, 0);
          },
          listener: (details) {
            remoteControl.joystickCommand.value =
                JoystickCommand(-details.y * 1.0, -details.x * 1.6);
          },
        )),
        n.Row([
          !controller.hasAction("mower_logic:area_recording/stop_recording")
              ? (n.Button.elevatedIcon(
                  "Start Recording".n, n.Icon(Icons.fiber_manual_record))
                ..enable = controller
                    .hasAction("mower_logic:area_recording/start_recording")
                ..onPressed = () {
                  remoteControl
                      .callAction("mower_logic:area_recording/start_recording");
                }
                ..expanded
                ..elevation = 2
                ..p = 16)
              : (n.Button.elevatedIcon(
                  "Stop Recording".n, n.Icon(Icons.fiber_manual_record))
                ..visible = controller
                    .hasAction("mower_logic:area_recording/stop_recording")
                ..onPressed = () {
                  remoteControl
                      .callAction("mower_logic:area_recording/stop_recording");
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
            ..enable = controller.hasAnyAction([
              "mower_logic:area_recording/finish_navigation_area",
              "mower_logic:area_recording/finish_mowing_area",
              "mower_logic:area_recording/finish_discard"
            ])
            ..elevation = 2
            ..p = 16,
        ])
          ..gap = 8
          ..px = 16
          ..py = 8,
        n.Row([
          n.Button.elevatedIcon("Record Docking".n, n.Icon(Icons.home))
            ..enable =
                controller.hasAction("mower_logic:area_recording/record_dock")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/record_dock");
            }
            ..elevation = 2
            ..expanded
            ..p = 16,
          n.Button.elevatedIcon(
              "Exit Recording Mode".n, n.Icon(Icons.exit_to_app))
            ..enable = controller
                .hasAction("mower_logic:area_recording/exit_recording_mode")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/exit_recording_mode");
            }
            ..elevation = 2
            ..expanded
            ..p = 16,
        ])
          ..gap = 8
          ..px = 16
          ..py = 8,
      ])
        ..py = 8;
    }
  }

  Widget buildSaveAreaDialog() {
    return n.Alert.adaptive()
      ..title = "Save Area".n
      ..content = "Save area as navigation area or as mowing area?".n
      ..actions = [
        n.Button("Mowing Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_mowing_area")
          ..onPressed = () {
            remoteControl
                .callAction("mower_logic:area_recording/finish_mowing_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Navigation Area".n)
          // ..enable = robotState
          //     .hasAction("mower_logic:area_recording/finish_navigation_area")
          ..onPressed = () {
            remoteControl.callAction(
                "mower_logic:area_recording/finish_navigation_area");
            Get.back();
          }
          ..bold
          ..p = 24,
        n.Button("Don't Save".n)
          ..onPressed = () {
            remoteControl
                .callAction("mower_logic:area_recording/finish_discard");
            Get.back();
          }
          ..bold
          ..color = Colors.red
          ..p = 24
      ];
  }
}
