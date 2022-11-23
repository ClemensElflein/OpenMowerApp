import 'package:flutter/material.dart';
import 'package:open_mower_app/controllers/robot_state_controller.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:open_mower_app/models/map_model.dart';
import 'package:open_mower_app/models/robot_state.dart';

class MapWidget extends GetView<RobotStateController> {
  const MapWidget({super.key});

  // load the image async and then draw with `canvas.drawImage(image, Offset.zero, Paint());`
  Future<ui.Image> loadImageAsset(String assetName) async {
    final data = await rootBundle.load(assetName);
    return decodeImageFromList(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {

    return InteractiveViewer(
        maxScale: 10.0,
        minScale: 0.1,
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RepaintBoundary(child:Obx(() => CustomPaint(
                  willChange: false,
                  isComplex: true,
                  painter: MapPainter(controller.map.value),
              foregroundPainter: RobotPainter(controller.map.value, controller.robotState.value),
                )))));
  }
}

class RobotPainter extends CustomPainter {


  final MapModel mapModel;
  final RobotState robotState;

  @override
  void paint(Canvas canvas, Size size) {
    // don't try to draw map if it has size 0
    if(mapModel.width == 0 || mapModel.height == 0) {
      return;
    }

    final backgroundRect = Offset.zero & size;

    final drawingRect =
    Rect.fromLTRB(25, 200, size.width - 25, size.height - 125);

    final mapScale = min(drawingRect.width / mapModel.width,
        drawingRect.height / mapModel.height);



    canvas.translate(
        drawingRect.topLeft.dx +
            (drawingRect.width - mapModel.width * mapScale) / 2.0,
        drawingRect.topLeft.dy +
            (drawingRect.height - mapModel.height * mapScale) / 2.0);
    canvas.scale(mapScale);
    canvas.translate(mapModel.width / 2 - mapModel.centerX,
        mapModel.height / 2 + mapModel.centerY);

    canvas.drawCircle(Offset(robotState.posX, robotState.posY), 0.4, Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if(oldDelegate is RobotPainter) {
      return true;
    }
    return false;
  }

  RobotPainter(this.mapModel, this.robotState);
}

class MapPainter extends CustomPainter {
  MapPainter(this.mapModel);

  final MapModel mapModel;

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
    ..color = const Color.fromRGBO(210,210,210,1)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 0;
  final _coordinateLinesPaintOrigin = Paint()
    ..color = const Color.fromRGBO(190,190,190,1)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    print("map paint");
    final backgroundRect = Offset.zero & size;

    final drawingRect =
        Rect.fromLTRB(25, 200, size.width - 25, size.height - 125);

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
    if(mapModel.width == 0 || mapModel.height == 0) {
      return;
    }

    final mapScale = min(drawingRect.width / mapModel.width,
        drawingRect.height / mapModel.height);



    canvas.translate(
        drawingRect.topLeft.dx +
            (drawingRect.width - mapModel.width * mapScale) / 2.0,
        drawingRect.topLeft.dy +
            (drawingRect.height - mapModel.height * mapScale) / 2.0);
    canvas.scale(mapScale);

    /* draw map outline
    canvas.drawRect(
        // Rect.fromCenter(
        //     center: Offset(mapModel.centerX, mapModel.centerY),
        //     width: mapModel.width,
        //     height: mapModel.height),
        Offset(0,0) & Size(mapModel.width, mapModel.height),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 0.1
          ..style = PaintingStyle.stroke);
    */

    canvas.translate(mapModel.width / 2 - mapModel.centerX,
        mapModel.height / 2 + mapModel.centerY);




    final startX = ((-mapModel.width / 2 +
                    mapModel.centerX -
                    (drawingRect.topLeft.dx +
                            (drawingRect.width - mapModel.width * mapScale) /
                                2.0) /
                        mapScale) /
                5)
            .round() *
        5;
    final startY = ((-(mapModel.height / 2 + mapModel.centerY) -
        (drawingRect.topLeft.dy +
                (drawingRect.height - mapModel.height * mapScale) / 2.0) /
            mapScale) / 5).round() * 5;

    final Path grid = Path();

    final width = backgroundRect.width * mapScale;
    final height = backgroundRect.height * mapScale;
    for (int x = startX.round(); x < startX + width; x += 5) {
      if(x != 0) {
        grid.moveTo(x.toDouble(), startY.toDouble());
        grid.lineTo(x.toDouble(), startY + height);
      }
    }
    for (int y = startY; y < startY + height; y += 5) {
      if(y != 0) {
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
    canvas.drawCircle(
        Offset.zero,
        0.5,
        _coordinateLinesPaintOrigin
          ..style = PaintingStyle.fill);


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
      for(final obstacle in area.obstacles) {
        canvas.drawPath(obstacle, _obstaclePaint);
      }
    }

    for (final area in mapModel.mowingAreas) {
      canvas.drawPath(area.outline, _mowFillPaint);
      // grassPattern.paintOnPath(canvas, Size(mapModel.width, mapModel.height), area.outline);

      canvas.drawPath(area.outline, _mowOutlinePaint);
      for(final obstacle in area.obstacles) {
        canvas.drawPath(obstacle, _obstaclePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is MapPainter) {
      if (oldDelegate.mapModel != mapModel) {
        print("new map model, should repaint!");
        return true;
      } else {
        print("same map model, should NOT repaint!");
      }
    }
    return false;
  }
}
