import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:open_mower_app/views/map_widget.dart';

class RemoteControl extends GetView<RemoteController> {
  const RemoteControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            const MapWidget(),
            Align(
              alignment: const Alignment(0, 0.8),
              child: Joystick(
                mode: JoystickMode.all,
                onStickDragEnd: () {
                  controller.forceSendUpdate(const JoystickCommand(0,0));
                },
                listener: (details) {
                  controller.joystickCommand.value = JoystickCommand(-details.y*1.0, -details.x*1.6);
                },
              ),
            ),
          ],
        );
  }

}