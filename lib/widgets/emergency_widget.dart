import 'package:flutter/material.dart';

class EmergencyIconButton extends StatefulWidget {
  final bool emergency;

  const EmergencyIconButton({super.key, required this.emergency});

  @override
  State<EmergencyIconButton> createState() => _EmergencyIconButtonState();
}

class _EmergencyIconButtonState extends State<EmergencyIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.emergency) {
    return FadeTransition(
      opacity: _animationController,
      child: IconButton(
        onPressed: () => {
          //print("TODO: Release emergency")
        },
        icon: Icon(Icons.gpp_maybe, color: Colors.red[500]),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minHeight: 24.0),
      ),
    );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
