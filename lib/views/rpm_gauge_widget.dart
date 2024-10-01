import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/niku.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class RpmGaugeWidget extends StatelessWidget {
  final DoubleSensorState? sensor;

  // We (mostly) don't know the maxValue, so it get computed
  // and buffered in this static sensor.name->maxValue Map,
  // to survive the nature of this StatelessWidget
  static final Map<String, double> _maxValues = HashMap();

  const RpmGaugeWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    double absValue = (sensor?.value ?? 0).abs();

    // Use some reasonable defaults (for YF-C500 model) if not given
    double lowerCriticalValue = ((sensor?.hasCriticalLow ?? false)
        ? sensor?.lowerCriticalValue ?? 2300
        : 2300);
    double minValue =
        ((sensor?.minValue ?? 0) > 0 ? sensor?.minValue ?? 2800 : 2800);

    // Get maxValue for this sensor name from _maxValues static buffer,
    // or set (and return) it to given/default value
    double maxValue = _maxValues.putIfAbsent(sensor?.name ?? "N/A",
        () => ((sensor?.maxValue ?? 0) > 0 ? sensor?.maxValue ?? 3800 : 3800));

    // If absValue is higher than maxValue, which might happen due to higher RPMs than rated,
    // as well as higher voltage or higher xESC trigger, adapt maxValue accordingly
    if (absValue > maxValue) {
      maxValue = absValue;
      _maxValues.update(sensor?.name ?? "N/A", (value) => maxValue);
    }

    return RadialGauge(
      value: absValue,
      axis: GaugeAxis(
        max: maxValue,
        degrees: 240,
        progressBar: null,
        segments: [
          GaugeSegment(
            from: 0,
            to: lowerCriticalValue,
            color: Colors.red.shade300,
            cornerRadius: const Radius.circular(5),
          ),
          GaugeSegment(
            from: lowerCriticalValue,
            to: minValue,
            color: Colors.orange.shade300,
            cornerRadius: const Radius.circular(5),
          ),
          GaugeSegment(
            from: minValue,
            to: maxValue,
            color: Colors.green.shade300,
            cornerRadius: const Radius.circular(5),
          ),
        ],
        style: const GaugeAxisStyle(
          thickness: 4,
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
