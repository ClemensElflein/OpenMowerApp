import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';

class AdvancedOptions extends GetView<RobotStateController> {
  AdvancedOptions({super.key});
  final RemoteController remoteControl = Get.find();
  @override
  Widget build(BuildContext context) {
    return n.Column([
      n.Row([
            const Text("Current Area:   ",
                  style: TextStyle(fontSize: 22, color: Colors.black)),
             Obx(() => Text( controller.robotState.value.currentArea.toString(),
                     style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)) ,
            ),
            const SizedBox(
              width: 40, 
            ),
            Obx(()=>SizedBox(
                width: 200,
                child: (n.Button.elevatedIcon("Skip current Area".n,n.Icon(Icons.skip_next))
                      ..enable = (controller
                              .hasAction("mower_logic:mowing/skip_area"))
                      ..onPressed = () {
                        remoteControl.callAction("mower_logic:mowing/skip_area");
                      })
                  ..elevation = 2
                  ..p = 16),
            )
      ])
        ..gap = 8
        ..px = 16
        ..py = 8,
      n.Row([
        Obx(
         () =>!controller.hasAction("mower_logic:area_recording/stop_manual_mowing")
          ?(n.Button.elevatedIcon("Start Manual Mowing".n, n.Icon(Icons.autorenew))
          ..enable = (controller.hasAction("mower_logic:area_recording/start_manual_mowing"))
          ..onPressed = () {
            remoteControl.callAction("mower_logic:area_recording/start_manual_mowing");
          }
          ..elevation = 2
          ..p = 16)
          : (n.Button.elevatedIcon(
                  "Stop Manual Mowing".n, n.Icon(Icons.autorenew))
                ..style = n.ButtonStyle(backgroundColor: Colors.red)
                ..visible = controller
                    .hasAction("mower_logic:area_recording/stop_manual_mowing")
                ..onPressed = () {
                  remoteControl
                      .callAction("mower_logic:area_recording/stop_manual_mowing");
                }
          ..elevation = 2
          ..p = 16)
        )
      ])
        ..gap = 8
        ..px = 16
        ..py = 8,
    ]);
  }
}
