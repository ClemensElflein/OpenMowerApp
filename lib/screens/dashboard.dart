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
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Obx(() {
              final state = controller.robotState.value.currentState;
              final statusColor = _getStatusColor(state);
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen = screenSize.width < 600;
              
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16, 
                  vertical: isSmallScreen ? 6 : 8
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
                      width: isSmallScreen ? 10 : 12,
                      height: isSmallScreen ? 10 : 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
                    ),
                    Text(
                      _getStatusText(state),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 15.0 : 30.0),
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.8,
              child: Joystick(
                base: JoystickBase(
                  size: MediaQuery.of(context).size.width < 600 ? 120 : 150,
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
      final isSmallScreen = MediaQuery.of(context).size.width < 600;
      final buttonPadding = isSmallScreen ? 8.0 : 16.0;
      final containerPadding = isSmallScreen ? 8.0 : 16.0;
      final gapSize = isSmallScreen ? 4.0 : 8.0;

      Widget startPauseButton = !controller.hasAction("mower_logic:mowing/pause")
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
            ..p = buttonPadding)
          : (n.Button.elevatedIcon("Pause".n, n.Icon(Icons.pause))
            ..enable = controller.hasAction("mower_logic:mowing/pause")
            ..onPressed = () {
              remoteControl.callAction("mower_logic:mowing/pause");
            }
            ..expanded
            ..elevation = 2
            ..p = buttonPadding);

      Widget stopButton = n.Button.elevatedIcon("Stop".n, n.Icon(Icons.home))
        ..enable = controller.hasAction("mower_logic:mowing/abort_mowing")
        ..onPressed = () {
          remoteControl.callAction("mower_logic:mowing/abort_mowing");
        }
        ..elevation = 2
        ..p = buttonPadding;

      Widget recordButton = n.Button.elevatedIcon(
          "Area Recording".n, n.Icon(Icons.fiber_manual_record))
        ..enable =
            controller.hasAction("mower_logic:idle/start_area_recording")
        ..onPressed = () {
          remoteControl.callAction("mower_logic:idle/start_area_recording");
        }
        ..elevation = 2
        ..p = buttonPadding;

      // For very small screens, switch to a 2-row layout
      if (isSmallScreen && MediaQuery.of(context).size.width < 400) {
        return n.Column([
          n.Row([
            startPauseButton,
            stopButton,
          ])
            ..gap = gapSize
            ..px = containerPadding
            ..py = containerPadding / 2,
          n.Row([
            recordButton
          ])
            ..px = containerPadding
            ..py = containerPadding / 2,
        ])
          ..py = containerPadding / 2;
      } else {
        return n.Row([
          startPauseButton,
          stopButton,
          recordButton,
        ])
          ..gap = gapSize
          ..p = containerPadding;
      }
    } else {
      final isSmallScreen = MediaQuery.of(context).size.width < 600;
      final buttonPadding = isSmallScreen ? 8.0 : 16.0;
      final containerPadding = isSmallScreen ? 8.0 : 16.0;
      final gapSize = isSmallScreen ? 4.0 : 8.0;
      final verySmallScreen = isSmallScreen && MediaQuery.of(context).size.width < 400;
      
      // First row buttons
      Widget recordButton = !controller.hasAction("mower_logic:area_recording/stop_recording")
          ? (n.Button.elevatedIcon(
              verySmallScreen ? "Start".n : "Start Recording".n, 
              n.Icon(Icons.fiber_manual_record))
            ..enable = controller
                .hasAction("mower_logic:area_recording/start_recording")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/start_recording");
            }
            ..expanded
            ..elevation = 2
            ..p = buttonPadding)
          : (n.Button.elevatedIcon(
              verySmallScreen ? "Stop".n : "Stop Recording".n, 
              n.Icon(Icons.fiber_manual_record))
            ..visible = controller
                .hasAction("mower_logic:area_recording/stop_recording")
            ..onPressed = () {
              remoteControl
                  .callAction("mower_logic:area_recording/stop_recording");
            }
            ..style = n.ButtonStyle(backgroundColor: Colors.red)
            ..expanded
            ..elevation = 2
            ..p = buttonPadding);
      
      Widget finishButton = n.Button.elevatedIcon(
          verySmallScreen ? "Finish".n : "Finish Area".n, 
          n.Icon(Icons.stop),
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
        ..p = buttonPadding;
        
      // Second row buttons
      Widget dockButton = n.Button.elevatedIcon(
          verySmallScreen ? "Dock".n : "Record Docking".n, 
          n.Icon(Icons.home))
        ..enable =
            controller.hasAction("mower_logic:area_recording/record_dock")
        ..onPressed = () {
          remoteControl
              .callAction("mower_logic:area_recording/record_dock");
        }
        ..elevation = 2
        ..expanded
        ..p = buttonPadding;
        
      Widget exitButton = n.Button.elevatedIcon(
          verySmallScreen ? "Exit".n : "Exit Recording Mode".n, 
          n.Icon(Icons.exit_to_app))
        ..enable = controller
            .hasAction("mower_logic:area_recording/exit_recording_mode")
        ..onPressed = () {
          remoteControl
              .callAction("mower_logic:area_recording/exit_recording_mode");
        }
        ..elevation = 2
        ..expanded
        ..p = buttonPadding;
      
      // Third row buttons
      Widget autoCollectButton = controller.hasAction("mower_logic:area_recording/auto_point_collecting_disable")
          ? (n.Button.elevatedIcon(
          verySmallScreen ? "Disable Auto".n : "Disable auto collecting".n, 
          n.Icon(Icons.route))
        ..visible = controller
            .hasAction("mower_logic:area_recording/auto_point_collecting_disable")
        ..onPressed = () {
          remoteControl
              .callAction("mower_logic:area_recording/auto_point_collecting_disable");
        }
        ..style = n.ButtonStyle(backgroundColor: Colors.orangeAccent)
        ..elevation = 2
        ..p = buttonPadding)
          : (n.Button.elevatedIcon(
          verySmallScreen ? "Enable Auto".n : "Enable auto collecting".n, 
          n.Icon(Icons.route))
        ..visible = controller
            .hasAction("mower_logic:area_recording/auto_point_collecting_enable")
        ..onPressed = () {
          remoteControl
              .callAction("mower_logic:area_recording/auto_point_collecting_enable");
        }
        ..elevation = 2
        ..p = buttonPadding);
      
      Widget addPointButton = n.Button.elevatedIcon(
          verySmallScreen ? "Add Pt".n : "Add point".n, 
          n.Icon(Icons.add_location))
        ..visible = controller
            .hasAction("mower_logic:area_recording/collect_point")
        ..onPressed = () {
          remoteControl
              .callAction("mower_logic:area_recording/collect_point");
        }
        ..style = n.ButtonStyle(backgroundColor: Colors.green)
        ..elevation = 2
        ..expanded
        ..p = buttonPadding;

      return n.Column([
        n.Row([recordButton, finishButton])
          ..gap = gapSize
          ..px = containerPadding
          ..py = containerPadding/2,
        n.Row([dockButton, exitButton])
          ..gap = gapSize
          ..px = containerPadding
          ..py = containerPadding/2,
        n.Row([autoCollectButton, addPointButton])
          ..gap = gapSize
          ..px = containerPadding
          ..py = containerPadding/2,
      ])
        ..py = containerPadding/2;
    }
  }

  Widget buildSaveAreaDialog() {
    final isSmallScreen = MediaQuery.of(Get.context!).size.width < 600;
    final buttonPadding = isSmallScreen ? 12.0 : 24.0;
    
    return n.Alert.adaptive()
      ..title = "Save Area".n
      ..content = "Save area as navigation area or as mowing area?".n
      ..actions = [
        n.Button("Mowing Area".n)
          ..onPressed = () {
            remoteControl
                .callAction("mower_logic:area_recording/finish_mowing_area");
            Get.back();
          }
          ..bold
          ..p = buttonPadding,
        n.Button("Navigation Area".n)
          ..onPressed = () {
            remoteControl.callAction(
                "mower_logic:area_recording/finish_navigation_area");
            Get.back();
          }
          ..bold
          ..p = buttonPadding,
        n.Button("Don't Save".n)
          ..onPressed = () {
            remoteControl
                .callAction("mower_logic:area_recording/finish_discard");
            Get.back();
          }
          ..bold
          ..color = Colors.red
          ..p = buttonPadding
      ];
  }
}
