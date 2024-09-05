import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/niku.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class SensorWidget extends StatelessWidget {
  final DoubleSensorState ?sensor;

  const SensorWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    switch(sensor?.unit) {
      case "rpm":
        // Thresholds or some reasonable defaults
        double lowerCriticalValue = ((sensor?.hasCriticalLow ?? false)
            ? (sensor?.lowerCriticalValue ?? 0)
            : 2300);
        double minValue =
            ((sensor?.hasMinMax ?? false) ? (sensor?.minValue ?? 0) : 2800);
        double maxValue =
            ((sensor?.hasMinMax ?? false) ? (sensor?.maxValue ?? 0) : 3800);

        return Material(
            elevation: 2,
            // RadialGauge Widget has issues with GaugeSegments when used in Column. Workaround by use of ListView
            child: n.ListView.children([
              (sensor?.name ?? "N/A").bodyMedium
                ..color = Colors.black54
                ..center,
              RadialGauge(
                value: (sensor?.value ?? 0),
                axis: GaugeAxis(
                  max: maxValue,
                  degrees: 240,
                  progressBar: null,
                  segments: [
                    GaugeSegment(
                      from: 0,
                      to: lowerCriticalValue,
                      color: (Colors.red[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                    GaugeSegment(
                      from: lowerCriticalValue,
                      to: minValue,
                      color: (Colors.orange[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                    GaugeSegment(
                      from: minValue,
                      to: maxValue,
                      color: (Colors.green[200])!,
                      cornerRadius: const Radius.circular(5),
                    ),
                  ],
                  style: const GaugeAxisStyle(
                    thickness: 10,
                    background: Colors.white54,
                    segmentSpacing: 4,
                  ),
                  pointer: const GaugePointer.triangle(
                      width: 15,
                      height: 20,
                      borderRadius: 1,
                      color: Colors.black54,
                      position:
                          GaugePointerPosition.surface(offset: Offset(0, 10)),
                      border:
                          GaugePointerBorder(color: Colors.white, width: 1)),
                ),
                child: n.Column([
                  (sensor?.unit ?? "rpm").bodyMedium..color = Colors.black54,
                  RadialGaugeLabel(
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
