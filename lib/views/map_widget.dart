import 'package:flutter/material.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/map_overlay_model.dart';
import 'package:open_mower_app/models/robot_state.dart';

class MapWidget extends GetView<RobotStateController> {
  const MapWidget({
    super.key, 
    required this.centerOnRobot, 
    this.robotLength = 0.6, // 60cm by default
  });

  final bool centerOnRobot;
  final double robotLength; // Robot size in meters

  // load the image async and then draw with `canvas.drawImage(image, Offset.zero, Paint());`
  Future<ui.Image> loadImageAsset(String assetName) async {
    final data = await rootBundle.load(assetName);
    return decodeImageFromList(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    // Create a future for the robot image
    final robotImageFuture = loadImageAsset('assets/yardforce.png');
    
    return InteractiveViewer(
        panEnabled: !centerOnRobot,
        scaleEnabled: !centerOnRobot,
        maxScale: 10.0,
        minScale: 0.1,
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RepaintBoundary(
                child: FutureBuilder<ui.Image>(
                  future: robotImageFuture,
                  builder: (context, snapshot) {
                    // This builder is called whenever the future's state changes
                    return Obx(() => CustomPaint(
                      isComplex: true,
                      painter: MapPainter(
                          controller.map.value,
                          controller.mapOverlay.value,
                          controller.robotState.value,
                          centerOnRobot,
                          robotLength,
                          snapshot.data, // Pass the actual image, will be null until loaded
                      ),
                    ));
                  },
                )
            )));
  }
}

// A simple painter that just subscribes to the repaint notifier
// Not needed anymore with the FutureBuilder approach

class MapPainter extends CustomPainter {
  MapPainter(
    this.mapModel, 
    this.mapOverlayModel, 
    this.robotState,
    this.centerOnRobot,
    this.robotLength,
    this.robotImage
  ) {
    // "home" icon (keep this part for the dock)
    path_1.moveTo(0.2291667, 0.8125000);
    path_1.lineTo(0.3854167, 0.8125000);
    path_1.lineTo(0.3854167, 0.5520833);
    path_1.lineTo(0.6145833, 0.5520833);
    path_1.lineTo(0.6145833, 0.8125000);
    path_1.lineTo(0.7708333, 0.8125000);
    path_1.lineTo(0.7708333, 0.4062500);
    path_1.lineTo(0.5000000, 0.2031250);
    path_1.lineTo(0.2291667, 0.4062500);
    path_1.close();
    path_1.moveTo(0.1666667, 0.8750000);
    path_1.lineTo(0.1666667, 0.3750000);
    path_1.lineTo(0.5000000, 0.1250000);
    path_1.lineTo(0.8333333, 0.3750000);
    path_1.lineTo(0.8333333, 0.8750000);
    path_1.lineTo(0.5520833, 0.8750000);
    path_1.lineTo(0.5520833, 0.6145833);
    path_1.lineTo(0.4479167, 0.6145833);
    path_1.lineTo(0.4479167, 0.8750000);
    path_1.close();
    path_1.moveTo(0.5000000, 0.5072917);
    path_1.close();
  }

  final MapModel mapModel;
  final MapOverlayModel mapOverlayModel;
  final RobotState robotState;
  final bool centerOnRobot;
  final double robotLength; // Robot size in meters (configurable)
  final ui.Image? robotImage;

  final _backgroundPaint = Paint()
    ..color = const Color.fromRGBO(0, 0, 0, 0.1)
    ..style = PaintingStyle.fill;
  final _mowOutlinePaint = Paint()
    ..strokeWidth = 0.02
    ..color = const Color.fromRGBO(50, 50, 50, 1.0)
    ..style = PaintingStyle.stroke;
  final _mowFillPaint = Paint()
    ..color = Colors.lightGreen
    ..style = PaintingStyle.fill;
  final _navigationFillPaint = Paint()
    ..color = const Color.fromRGBO(250, 250, 250, 1.0)
    ..style = PaintingStyle.fill;
  final _obstaclePaint = Paint()
    ..color = const Color.fromRGBO(50, 50, 50, 1.0)
    ..style = PaintingStyle.fill;

  final _robotPaint = Paint()
    ..color = const Color.fromRGBO(25, 25, 25, 1.0)
    ..style = PaintingStyle.fill;
  
  final Path path_0 = Path();
  final Path path_1 = Path();

  @override
  void paint(Canvas canvas, Size size) {
    // print("map paint");
    final backgroundRect = Offset.zero & size;

    final drawingRect =
        Rect.fromLTRB(25, 150, size.width - 25, size.height - 25);

    canvas.drawRect(backgroundRect, _backgroundPaint);

    double mapWidth = max(mapModel.width, 15);
    double mapHeight = max(mapModel.height, 15);


    double mapScale = 80;

    if (!centerOnRobot) {
      mapScale = min(drawingRect.width / mapWidth,
          drawingRect.height / mapHeight);
    }

    canvas.translate(
        drawingRect.topLeft.dx +
            (drawingRect.width - mapWidth * mapScale) / 2.0,
        drawingRect.topLeft.dy +
            (drawingRect.height - mapHeight * mapScale) / 2.0);


    canvas.scale(mapScale);

    /* draw map outline
    canvas.drawRect(
        // Rect.fromCenter(
        //     center: Offset(mapModel.centerX, mapModel.centerY),
        //     width: mapWidth,
        //     height: mapHeight),
        Offset(0,0) & Size(mapWidth, mapHeight),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 0.1
          ..style = PaintingStyle.stroke);
    */

    if (!centerOnRobot) {
      // fit map to the center
      canvas.translate(mapWidth / 2 - mapModel.centerX,
          mapHeight / 2 - mapModel.centerY);
    } else {
      // center on robot
      canvas.translate(mapWidth / 2 - robotState.posX,
          mapHeight / 2 - robotState.posY);
      // canvas.rotate((robotState.heading - pi/2) % (2.0*pi));
      // canvas.translate(, );
    }

    final startX = ((-mapWidth / 2 +
                    mapModel.centerX -
                    (drawingRect.topLeft.dx +
                            (drawingRect.width - mapWidth * mapScale) /
                                2.0) /
                        mapScale) /
                5)
            .round() *
        5;
    final startY = ((-(mapHeight / 2 - mapModel.centerY) -
                    (drawingRect.topLeft.dy +
                            (drawingRect.height - mapHeight * mapScale) /
                                2.0) /
                        mapScale) /
                5)
            .round() *
        5;

    final Path grid = Path();

    final width = backgroundRect.width * mapScale;
    final height = backgroundRect.height * mapScale;
    for (int x = startX.round(); x < startX + width; x += 5) {
      if (x != 0) {
        grid.moveTo(x.toDouble(), startY.toDouble());
        grid.lineTo(x.toDouble(), startY + height);
      }
    }
    for (int y = startY; y < startY + height; y += 5) {
      if (y != 0) {
        grid.moveTo(startX.toDouble(), y.toDouble());
        grid.lineTo(startX + width, y.toDouble());
      }
    }

    final Path axes = Path();

    axes.moveTo(startX.toDouble(), 0);
    axes.lineTo(startX + width, 0);
    axes.moveTo(0, startY.toDouble());
    axes.lineTo(0, startY + height);

    for (final area in mapModel.navigationAreas) {
      canvas.drawPath(area.outline, _navigationFillPaint);
      canvas.drawPath(area.outline, _mowOutlinePaint);
      for (final obstacle in area.obstacles) {
        canvas.drawPath(obstacle, _obstaclePaint);
      }
    }

    for (final area in mapModel.mowingAreas) {
      canvas.drawPath(area.outline, _mowFillPaint);
      // grassPattern.paintOnPath(canvas, Size(mapWidth, mapHeight), area.outline);

      canvas.drawPath(area.outline, _mowOutlinePaint);
      for (final obstacle in area.obstacles) {
        canvas.drawPath(obstacle, _obstaclePaint);
      }
    }

    // draw dock
    {
      canvas.save();
      canvas.translate(mapModel.dockX, mapModel.dockY);
      canvas.drawCircle(
          Offset.zero,
          0.3,
          Paint()
            ..color = Colors.greenAccent.withOpacity(0.4)
            ..style = PaintingStyle.fill);
      // canvas.rotate(-(mapModel.dockHeading - pi / 2) % (2.0 * pi));
      canvas.scale(0.5);
      canvas.translate(-0.5, -0.5);
      canvas.drawPath(path_1, _robotPaint);
      canvas.restore();
    }

    // draw overlays
    for (final overlay in mapOverlayModel.polygons) {
      canvas.drawPath(overlay.overlay, getOverlayPaint(overlay));
    }

    // Draw robot icon
    {
      // Save current canvas state
      canvas.save();
      
      // Move to robot position
      canvas.translate(robotState.posX, robotState.posY);
      
      // Rotate according to robot heading
      // Subtract pi/2 to make the robot's front point in the heading direction
      // The image is a top-view with robot heading south
      canvas.rotate(-(robotState.heading + pi / 2) % (2.0 * pi));
      
      if (robotImage != null) {
        // Calculate the scale to make the robot the correct size
        // Convert image dimensions to map scale
        final aspectRatio = robotImage!.width / robotImage!.height;
        final robotWidth = robotLength * aspectRatio;

        // Scale and position the image
        // Center the image on the robot position
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: robotWidth,
          height: robotLength
        );

        // Draw the robot image
        canvas.drawImageRect(
            robotImage!,
          Rect.fromLTWH(0, 0, robotImage!.width.toDouble(), robotImage!.height.toDouble()),
          rect,
          Paint()
        );
      } else {
        // Only show a simple position indicator if image is not loaded
        canvas.drawCircle(
          Offset.zero,
          0.15,
          Paint()
            ..color = Colors.red.withOpacity(0.7)
            ..style = PaintingStyle.fill
        );
      }
      
      // Restore canvas to previous state
      canvas.restore();
    }
  }

  Paint getOverlayPaint(OverlayPolygon overlay) {
    final p = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = overlay.lineWidth;

    switch (overlay.color) {
      case "red":
        p.color = Colors.red;
        break;
      case "green":
        p.color = Colors.lightGreenAccent;
        break;
      case "blue":
        p.color = Colors.blueAccent;
        break;
    }
    return p;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is MapPainter) {
      // Repaint if robot state or map model changed, or if image has been loaded since last paint
      if (oldDelegate.robotState != robotState ||
          oldDelegate.mapModel != mapModel ||
          oldDelegate.robotImage != robotImage
      ) {
        return true;
      }
    }
    return false;
  }
}
