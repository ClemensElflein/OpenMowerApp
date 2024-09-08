import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/niku.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_mower_app/controllers/remote_controller.dart';
import 'package:open_mower_app/controllers/sensors_controller.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:gauge_indicator/gauge_indicator.dart' as gauge_indicator;
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'dart:math';

class SensorWidget extends StatelessWidget {
  final DoubleSensorState? sensor;

  const SensorWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    // Prepare some often used gauge vars for easier usage
    bool hasMinMax = (sensor?.hasMinMax ?? false);
    double minValue = (sensor?.minValue ?? 0);
    double maxValue = (sensor?.maxValue ?? 0);

    bool hasCriticalLow = (sensor?.hasCriticalLow ?? false);
    double lowerCriticalValue = (sensor?.lowerCriticalValue ?? 0);

    bool hasCriticalHigh = (sensor?.hasCriticalHigh ?? false);
    double upperCricticalValue = (sensor?.upperCricticalValue ?? 0);

    double minAxis = min(minValue, lowerCriticalValue);
    minAxis = (((minAxis + 5 - 1) / 5).toInt() * 5); // Next multiple of 5
    if (minAxis > 0) minAxis -= 5; // Previous multiple of 5

    switch (sensor?.unit) {
      case "rpm":
        // Use some reasonable defaults if not given
        lowerCriticalValue = hasCriticalLow ? lowerCriticalValue : 2300;
        minValue = hasMinMax ? minValue : 2800;
        maxValue = hasMinMax ? maxValue : 3800;

        return Material(
            elevation: 2,
            // RadialGauge Widget has issues with GaugeSegments when used in Column. Workaround by use of ListView
            child: n.ListView.children([
              (sensor?.name ?? "N/A").bodyMedium
                ..color = Colors.black54
                ..center,
              gauge_indicator.RadialGauge(
                value: (sensor?.value ?? 0),
                axis: gauge_indicator.GaugeAxis(
                  max: maxValue,
                  degrees: 240,
                  progressBar: null,
                  segments: [
                    gauge_indicator.GaugeSegment(
                      from: 0,
                      to: lowerCriticalValue,
                      color: (Colors.red[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                    gauge_indicator.GaugeSegment(
                      from: lowerCriticalValue,
                      to: minValue,
                      color: (Colors.orange[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                    gauge_indicator.GaugeSegment(
                      from: minValue,
                      to: maxValue,
                      color: (Colors.green[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                  ],
                  style: const gauge_indicator.GaugeAxisStyle(
                    thickness: 10,
                    background: Colors.white54,
                    segmentSpacing: 4,
                  ),
                  pointer: const gauge_indicator.GaugePointer.triangle(
                      width: 15,
                      height: 20,
                      borderRadius: 1,
                      color: Colors.black54,
                      position: gauge_indicator.GaugePointerPosition.surface(
                          offset: Offset(0, 10)),
                      border: gauge_indicator.GaugePointerBorder(
                          color: Colors.white, width: 1)),
                ),
                child: n.Column([
                  (sensor?.unit ?? "rpm").bodyMedium..color = Colors.black54,
                  gauge_indicator.RadialGaugeLabel(
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    value: (sensor?.value ?? 0),
                  )
                ]),
              )
            ])
              ..p = 12
            //..center
            );
      case "A":
        // Vertical gauge for ampere where "higher is more worse" = red
        double maxAxis = max(maxValue, upperCricticalValue);
        maxAxis = maxAxis.ceil().toDouble();

        double axisRange = (maxAxis - minAxis);

        return Material(
          elevation: 2,
          child: n.Row([
            n.Column([
              (sensor?.name ?? "N/A").bodyMedium
                ..color = Colors.black54
                ..center,
              AutoSizeText(
                "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit}",
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              )
            ])
              ..expanded
              ..center,
            LinearGauge(
              start: minAxis,
              end: maxAxis,
              gaugeOrientation: GaugeOrientation.vertical,
              linearGaugeBoxDecoration: LinearGaugeBoxDecoration(
                thickness: 3,
                linearGradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    // A stop = fraction of axis range
                    0,
                    if (hasMinMax)
                      ((((maxValue - minValue) / 2) + minValue) - minAxis) /
                          axisRange,
                    if (hasMinMax) (maxValue - minAxis) / axisRange,
                  ],
                  colors: [
                    if (hasMinMax) Colors.green else Colors.grey.shade400,
                    if (hasMinMax) Colors.yellow,
                    if (hasMinMax) Colors.red,
                  ],
                ),
              ),
              pointers: [
                Pointer(
                  value: sensor?.value ?? 0,
                  shape: PointerShape.triangle,
                  color: Colors.black54,
                  pointerPosition: PointerPosition.left,
                ),
                if (hasMinMax)
                  Pointer(
                    value: minValue,
                    shape: PointerShape.diamond,
                    color: Colors.green.shade400,
                    width: 8,
                    height: 8,
                    pointerPosition: PointerPosition.center,
                  ),
                if (hasMinMax)
                  Pointer(
                    value: maxValue,
                    shape: PointerShape.diamond,
                    color: Colors.orange.shade400,
                    width: 8,
                    height: 8,
                    pointerPosition: PointerPosition.center,
                  ),
                if (hasCriticalHigh)
                  Pointer(
                    value: upperCricticalValue,
                    shape: PointerShape.diamond,
                    color: Colors.red.shade400,
                    width: 8,
                    height: 8,
                    pointerPosition: PointerPosition.center,
                  ),
              ],
              rulers: RulerStyle(
                rulerPosition: RulerPosition.center,
                primaryRulerColor: Colors.grey,
                textStyle: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal),
              ),
            )
          ])
            ..p = 12,
        );
      case "V":
        // Vertical gauge for voltage where "higher is better" = green
        double maxAxis = max(maxValue, upperCricticalValue);
        maxAxis = ((maxAxis + 5 - 1) / 5).toInt() * 5; // Next multiple of 5

        double axisRange = (maxAxis - minAxis);

        return Material(
          elevation: 2,
          child: n.Row([
            n.Column([
              (sensor?.name ?? "N/A").bodyMedium
                ..color = Colors.black54
                ..center,
              AutoSizeText(
                "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit}",
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              )
            ])
              ..expanded
              ..center,
            LinearGauge(
              start: minAxis,
              end: maxAxis,
              gaugeOrientation: GaugeOrientation.vertical,
              linearGaugeBoxDecoration: LinearGaugeBoxDecoration(
                thickness: 3,
                linearGradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    // A stop = fraction of axis range

                    if (hasCriticalLow || hasMinMax)
                      (lowerCriticalValue - minAxis) / axisRange
                    else
                      0,
                    if (hasMinMax) (minValue - minAxis) / axisRange,
                    if (hasMinMax)
                      ((((maxValue - minValue) / 2) + minValue) - minAxis) /
                          axisRange,
                    if (hasMinMax) (maxValue - minAxis) / axisRange,
                    if (hasCriticalHigh)
                      (upperCricticalValue - minAxis) / axisRange,
                    if (hasCriticalHigh) 1,
                  ],
                  colors: [
                    if (hasCriticalLow || hasMinMax)
                      Colors.red.shade400
                    else
                      Colors.grey.shade400,
                    if (hasMinMax) Colors.orange.shade400,
                    if (hasMinMax) Colors.yellow.shade400,
                    if (hasMinMax) Colors.green.shade400,
                    if (hasCriticalHigh) Colors.orange.shade400,
                    if (hasCriticalHigh) Colors.red.shade400,
                  ],
                ),
              ),
              pointers: [
                Pointer(
                  value: sensor?.value ?? 0,
                  shape: PointerShape.triangle,
                  color: Colors.black54,
                  pointerPosition: PointerPosition.left,
                ),
                if (hasMinMax)
                  Pointer(
                  value: minValue,
                  shape: PointerShape.diamond,
                  color: Colors.orange.shade400,
                  width: 8,
                  height: 8,
                  pointerPosition: PointerPosition.center,
                ),
                if (hasMinMax)
                  Pointer(
                    value: maxValue,
                    shape: PointerShape.diamond,
                    color: Colors.green.shade400,
                    width: 8,
                    height: 8,
                    pointerPosition: PointerPosition.center,
                  ),
                if (hasCriticalLow)
                  Pointer(
                    value: lowerCriticalValue,
                    shape: PointerShape.diamond,
                    color: Colors.red.shade400,
                    width: 8,
                    height: 8,
                    pointerPosition: PointerPosition.center,
                  ),
                if (hasCriticalHigh)
                  Pointer(
                    value: upperCricticalValue,
                    shape: PointerShape.diamond,
                    color: Colors.red.shade400,
                    width: 8,
                    height: 8,
                    pointerPosition: PointerPosition.center,
                  ),
              ],
              rulers: RulerStyle(
                rulerPosition: RulerPosition.center,
                primaryRulerColor: Colors.grey,
                textStyle: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal),
              ),
            )
          ])
            ..p = 12,
        );
      default:
        return Material(
            elevation: 2,
            child: n.Column([
              (sensor?.name ?? "N/A").bodyMedium
                ..color = Colors.black54
                ..center,
              AutoSizeText(
                "${sensor?.value.toStringAsFixed(2) ?? "N/A"} ${sensor?.unit.replaceAll("deg.C", "°C")}",
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              )
            ])
              ..p = 12
              ..center);
    }
  }
}
