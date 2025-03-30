import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:open_mower_app/views/map_widget.dart';
import 'package:open_mower_app/views/robot_state_widget.dart';

class Dashboard extends GetView<RobotStateController> {
  Dashboard({super.key});

  final RemoteController remoteControl = Get.find();
  
  // Helper method to format the robot status text
  String _getStatusText(String status) {
    // Convert UPPERCASE_WITH_UNDERSCORES to Title Case With Spaces
    if (status.isEmpty) return "Unknown Status";
    
    // Replace underscores with spaces and convert to title case
    final words = status.split('_');
    final formattedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    });
    
    return formattedWords.join(' ');
  }
  
  // Helper method to get status color based on state
  Color _getStatusColor(String status) {
    if (status.contains('ERROR') || status.contains('EMERGENCY')) {
      return Colors.red.shade400;
    } else if (status == 'IDLE') {
      return Colors.blue.shade400;
    } else if (status == 'MOWING') {
      return Colors.green.shade400;
    } else if (status == 'DOCKING' || status == 'CHARGING') {
      return Colors.amber.shade400;
    } else if (status == 'AREA_RECORDING') {
      return Colors.purple.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return n.Column([
      n.Stack([
        Obx(() => MapWidget(
            centerOnRobot:
                controller.robotState.value.currentState == "XD")),
        const Positioned(
          top: 0,
          right: 0,
          child: RobotStateWidget(),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Obx(() {
              final state = controller.robotState.value.currentState;
              final statusColor = _getStatusColor(state);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(
                      _getStatusText(state),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
    Obx(()=>(controller.robotState.value.currentState == "AREA_RECORDING") ?
        Container(
            padding: const EdgeInsets.all(30.0),
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.8,
              child: Joystick(
                base: JoystickBase(
                  decoration: JoystickBaseDecoration(
                    drawOuterCircle: false,
                  )),
                mode: JoystickMode.all,
                onStickDragEnd: () {
                  remoteControl.sendMessage(0, 0);
                },
                listener: (details) {
                  remoteControl.joystickCommand.value = JoystickCommand(-details.y * 1.0, -details.x * 1.6);
                },
              )
            )
        ) : n.Row(const [])),
      ])
        ..expanded,
      Material(
          elevation: 5, child: Obx(() => getButtonPanel(context, controller)))
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
        n.Row([
          controller.hasAction("mower_logic:area_recording/auto_point_collecting_disable")
              ? (n.Button.elevatedIcon(
              "Disable auto collecting".n, n.Icon(Icons.route))
            ..visible = controller
                .hasAction("mower_logic:area_recording/auto_point_collecting_disable")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/auto_point_collecting_disable");
            }
            ..style = n.ButtonStyle(backgroundColor: Colors.orangeAccent)
            ..elevation = 2
            ..p = 16)
              : (n.Button.elevatedIcon(
              "Enable auto collecting".n, n.Icon(Icons.route))
            ..visible = controller
                .hasAction("mower_logic:area_recording/auto_point_collecting_enable")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/auto_point_collecting_enable");
            }
            ..elevation = 2
            ..p = 16),
          n.Button.elevatedIcon(
              "Add point".n, n.Icon(Icons.add_location))
            ..visible = controller
                .hasAction("mower_logic:area_recording/collect_point")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/collect_point");
            }
            ..style = n.ButtonStyle(backgroundColor: Colors.green)
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
