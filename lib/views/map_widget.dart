import 'package:flutter/material.dart';

class MapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        maxScale: 10.0,
        minScale: 0.1,
        child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              size: Size.infinite,
              painter: MapPainter(),
            )));
  }
}

class MapPainter extends CustomPainter {
  const MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    print("REPAINT");

    final backgroundRect = Offset.zero & size;

    final drawingRect = Rect.fromLTRB(25, 200, size.width - 25, size.height - 125);


    canvas.drawRect(
        backgroundRect,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill);
    canvas.drawRect(
        drawingRect,
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.fill);


    canvas.drawLine(
        drawingRect.topLeft, drawingRect.bottomRight,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    canvas.drawLine(
        drawingRect.topRight, drawingRect.bottomLeft,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
