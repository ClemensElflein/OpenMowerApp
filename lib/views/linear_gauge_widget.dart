import 'package:flutter/material.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'dart:math';

/// Standard color for all non-matching or null-safety colors
const Color stdColor = Color.fromRGBO(189, 189, 189, 1);

/// GradienColorSchemes
enum GradientColorScheme {
  // MaterialColors in shade 400
  redYellowGreen({
    'criticalLow': Color.fromRGBO(239, 83, 80, 1),
    'min': Color.fromRGBO(255, 167, 38, 1),
    'midMinMax': Color.fromRGBO(255, 238, 88, 1),
    'max': Color.fromRGBO(102, 187, 106, 1),
    'criticalHeight': Color.fromRGBO(239, 83, 80, 1),
  }),
  greenYellowRed({
    'criticalLow': Color.fromRGBO(239, 83, 80, 1), // untested, no case ATM
    'min': Color.fromRGBO(102, 187, 106, 1), // untested, no case ATM
    'midMinMax': Color.fromRGBO(255, 238, 88, 1), // untested, no case ATM
    'max': Color.fromRGBO(255, 167, 38, 1),
    'criticalHeight': Color.fromRGBO(239, 83, 80, 1),
  });

  const GradientColorScheme(this.colors);
  final Map<String, Color> colors;
}

class LinearGaugeWidget extends StatelessWidget {
  final DoubleSensorState? sensor;

  /// Color scheme of the gauge axis
  final GradientColorScheme gradientColorScheme;

  const LinearGaugeWidget(
      {super.key,
      required this.sensor,
      this.gradientColorScheme = GradientColorScheme.redYellowGreen});

  @override
  Widget build(BuildContext context) {
    // Prepare some often used gauge vars for easier usage
    double minValue = (sensor?.minValue ?? 0);
    double maxValue = (sensor?.maxValue ?? 0);

    bool hasCriticalLow = (sensor?.hasCriticalLow ?? false);
    double lowerCriticalValue = (sensor?.lowerCriticalValue ?? 0);

    bool hasCriticalHigh = (sensor?.hasCriticalHigh ?? false);
    double upperCriticalValue = (sensor?.upperCriticalValue ?? 0);

    // Calculative axis values
    double minAxis = min(minValue, lowerCriticalValue);
    double maxAxis = max(maxValue, upperCriticalValue).ceilToDouble();
    double axisRange = (maxAxis - minAxis);

    // Optimize minAxis value
    double axisDivider = axisRange / 4; // Lets assume 4 divider over the range
    minAxis = (((minAxis + axisDivider - 1) / axisDivider).toInt() * axisDivider).ceilToDouble(); // Prev ceil divider

    axisRange = (maxAxis - minAxis);

    return LinearGauge(
      start: minAxis,
      end: maxAxis,
      gaugeOrientation: GaugeOrientation.vertical,
      linearGaugeBoxDecoration: LinearGaugeBoxDecoration(
        thickness: 3,
        linearGradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [
            // A stop is a fraction of axis range
            if (hasCriticalLow)
              (lowerCriticalValue - minAxis) / axisRange
            else
              0,
            if (minValue != 0) (minValue - minAxis) / axisRange,
            if (minValue != 0 && maxValue != 0)
              ((((maxValue - minValue) / 2) + minValue) - minAxis) / axisRange,
            if (maxValue != 0) (maxValue - minAxis) / axisRange,
            if (hasCriticalHigh) (upperCriticalValue - minAxis) / axisRange,
            1, // maxAxis
          ],
          colors: [
            if (hasCriticalLow)
              gradientColorScheme.colors['criticalLow'] ?? stdColor
            else
              stdColor,
            if (minValue != 0) gradientColorScheme.colors['min'] ?? stdColor,
            if (minValue != 0 && maxValue != 0)
              gradientColorScheme.colors['midMinMax'] ?? stdColor,
            if (maxValue != 0) gradientColorScheme.colors['max'] ?? stdColor,
            if (hasCriticalHigh)
              gradientColorScheme.colors['criticalHeight'] ?? stdColor,
            gradientColorScheme.colors['criticalHeight'] ?? stdColor, // maxAxis
          ],
        ),
      ),
      pointers: [
        // Actual value pointer
        Pointer(
          value: sensor?.value ?? 0,
          shape: PointerShape.triangle,
          color: Colors.black54,
          pointerPosition: PointerPosition.left,
        ),
        if (hasCriticalLow)
          Pointer(
            value: lowerCriticalValue,
            shape: PointerShape.diamond,
            color: gradientColorScheme.colors['criticalLow'] ?? stdColor,
            width: 8,
            height: 8,
            pointerPosition: PointerPosition.center,
          ),
        if (minValue != 0)
          Pointer(
            value: minValue,
            shape: PointerShape.diamond,
            color: gradientColorScheme.colors['min'] ?? stdColor,
            width: 8,
            height: 8,
            pointerPosition: PointerPosition.center,
          ),
        if (maxValue != 0)
          Pointer(
            value: maxValue,
            shape: PointerShape.diamond,
            color: gradientColorScheme.colors['max'] ?? stdColor,
            width: 8,
            height: 8,
            pointerPosition: PointerPosition.center,
          ),
        if (hasCriticalHigh)
          Pointer(
            value: upperCriticalValue,
            shape: PointerShape.diamond,
            color: gradientColorScheme.colors['criticalHeight'] ?? stdColor,
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
    );
  }
}
