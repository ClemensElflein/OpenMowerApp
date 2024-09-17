import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/niku.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class RpmGaugeWidget extends StatelessWidget {
  final DoubleSensorState? sensor;

  RpmGaugeWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    // Use some reasonable defaults if not given
    double lowerCriticalValue = ((sensor?.hasCriticalLow ?? false)
        ? sensor?.lowerCriticalValue ?? 2300
        : 2300);
    double minValue =
        ((sensor?.minValue ?? 0) > 0 ? sensor?.minValue ?? 2800 : 2800);
    double maxValue =
        ((sensor?.maxValue ?? 0) > 0 ? sensor?.maxValue ?? 3800 : 3800);

    return RadialGauge(
      value: (sensor?.value ?? 0),
      axis: GaugeAxis(
        max: maxValue,
        degrees: 240,
        progressBar: null,
        segments: [
          GaugeSegment(
            from: 0,
            to: lowerCriticalValue,
            color: Colors.red.shade400,
            cornerRadius: const Radius.circular(5),
          ),
          GaugeSegment(
            from: lowerCriticalValue,
            to: minValue,
            color: Colors.orange.shade400,
            cornerRadius: const Radius.circular(5),
          ),
          GaugeSegment(
            from: minValue,
            to: maxValue,
            color: Colors.green.shade400,
            cornerRadius: const Radius.circular(5),
          ),
        ],
        style: const GaugeAxisStyle(
          thickness: 6,
          background: Colors.white54,
          segmentSpacing: 4,
        ),
        pointer: const GaugePointer.triangle(
            width: 12,
            height: 12,
            borderRadius: 1,
            color: Colors.black54,
            position: GaugePointerPosition.surface(offset: Offset(0, 6)),
            border: GaugePointerBorder(color: Colors.white, width: 1)),
      ),
      child: n.Column([
        (sensor?.name ?? "N/A").bodyMedium
          ..color = Colors.black54
          ..center,
        RadialGaugeLabel(
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          value: (sensor?.value ?? 0),
        ),
        "${sensor?.unit}".bodyMedium..color = Colors.black54,
      ]),
    );
  }
}
