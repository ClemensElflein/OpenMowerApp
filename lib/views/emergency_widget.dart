import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';

class EmergencyWidget extends StatefulWidget {
  final bool emergency;
  final RemoteController remoteControl = Get.find();

  EmergencyWidget({super.key, required this.emergency});

  @override
  State<EmergencyWidget> createState() => _EmergencyWidgetState();
}

class _EmergencyWidgetState extends State<EmergencyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.emergency) {
      return FadeTransition(
        opacity: _animationController,
        child: IconButton(
          icon: Icon(Icons.gpp_maybe, color: Colors.red[500]),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minHeight: 24.0),
          onPressed: () => {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Emergency Reset'),
                content: const Text(
                    'Only confirm this if you are sure the emergency has been resolved (e.g. no one is carrying the robot).\n\nAre you sure you want to reset the emergency?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      widget.remoteControl
                          .callAction("mower_logic/reset_emergency");
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
