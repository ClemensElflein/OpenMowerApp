import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_joystick/flutter_joystick.dart';

class RemoteControl extends StatelessWidget {
  const RemoteControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: Joystick(
                mode: JoystickMode.all,
                listener: (details) {

                },
              ),
            ),
          ],
        );
  }

}