import 'package:flutter/material.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/map_overlay_model.dart';
import 'package:open_mower_app/models/robot_state.dart';

class MapWidget extends GetView<RobotStateController> {
  const MapWidget({super.key, required this.centerOnRobot});

  final bool centerOnRobot;

  // load the image async and then draw with `canvas.drawImage(image, Offset.zero, Paint());`
  Future<ui.Image> loadImageAsset(String assetName) async {
    final data = await rootBundle.load(assetName);
    return decodeImageFromList(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        panEnabled: !centerOnRobot,
        scaleEnabled: !centerOnRobot,
        maxScale: 10.0,
        minScale: 0.1,
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RepaintBoundary(
                child: Obx(() => CustomPaint(
                      isComplex: true,
                      painter: MapPainter(
                          controller.map.value,
                          controller.mapOverlay.value,
                          controller.robotState.value,
                          centerOnRobot),
                    )))));
  }
}

class MapPainter extends CustomPainter {
  MapPainter(this.mapModel, this.mapOverlayModel, this.robotState,
      this.centerOnRobot) {
    // "robot" arrow
    path_0.reset();
    path_0.moveTo(0.1979167, 0.8750000);
    path_0.lineTo(0.1666667, 0.8437500);
    path_0.lineTo(0.5000000, 0.08333333);
    path_0.lineTo(0.8333333, 0.8437500);
    path_0.lineTo(0.8020833, 0.8750000);
    path_0.lineTo(0.5000000, 0.7375000);

    path_0.moveTo(0.5000000, 0.6708333);
    path_0.close();

    // "home" icon

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
  final _coordinateLinesPaint = Paint()
    ..color = const Color.fromRGBO(210, 210, 210, 1)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 0;
  final _coordinateLinesPaintOrigin = Paint()
    ..color = const Color.fromRGBO(190, 190, 190, 1)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 0.1;

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
    // backgroundPattern.paintOnRect(canvas, backgroundRect.size, backgroundRect);

/*
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
        drawingRect.topLeft,
        drawingRect.bottomRight,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    canvas.drawLine(
        drawingRect.topRight,
        drawingRect.bottomLeft,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
*/

    // don't try to draw map if it has size 0

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

    canvas.drawPath(grid, _coordinateLinesPaint);
    canvas.drawPath(axes, _coordinateLinesPaintOrigin);
    canvas.drawCircle(Offset.zero, 0.5,
        _coordinateLinesPaintOrigin..style = PaintingStyle.fill);

/*
    for (final area in mapModel.mowingAreas) {
      canvas.drawShadow(area.outline, Colors.black, 5, false);
    }
    for (final area in mapModel.navigationAreas) {
      canvas.drawShadow(area.outline, Colors.black, 5, false);
    }
*/

    //
    // for(final area in mapModel.navigationAreas) {
    //   shadowPath = Path.combine(PathOperation.union, shadowPath, area.outline);
    // }
    //
    // remove all obstacles
    // for(final area in mapModel.mowingAreas) {
    //   for(final obstacle in area.obstacles) {
    //     shadowPath =
    //         Path.combine(PathOperation.difference, shadowPath, obstacle);
    //   }
    // }
    //
    // for(final area in mapModel.navigationAreas) {
    //   for(final obstacle in area.obstacles) {
    //     shadowPath =
    //         Path.combine(PathOperation.difference, shadowPath, obstacle);
    //   }
    // }

    //

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
      canvas.translate(robotState.posX, robotState.posY);
      // canvas.drawCircle(Offset.zero, 0.3, Paint()..color = Colors.blueAccent.withOpacity(0.8) ..style = PaintingStyle.fill);
      canvas.drawCircle(
          Offset.zero,
          0.3,
          Paint()
            ..color = Colors.blueAccent.withOpacity(0.4)
            ..style = PaintingStyle.fill);

      canvas.rotate(-(robotState.heading - pi / 2) % (2.0 * pi));
      canvas.scale(0.5);
      canvas.translate(-0.5, -0.5);
      canvas.drawPath(path_0, _robotPaint);
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
      if (oldDelegate.robotState != robotState ||
          oldDelegate.mapModel != mapModel) {
        // print("new map model, should repaint!");
        return true;
      } else {
        // print("same map model, should NOT repaint!");
      }
    }
    return false;
  }
}
