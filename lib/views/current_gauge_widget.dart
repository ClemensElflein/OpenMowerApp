import 'package:flutter/material.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'flex_axis.dart';

class CurrentGaugeWidget extends StatelessWidget with FlexAxis {
  final DoubleSensorState? sensor;

  CurrentGaugeWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    computeFlexAxis(sensor, 2);

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
            if (hasCriticalLow) Colors.red.shade300 else Colors.grey.shade400,
            if (minValue != 0) Colors.green.shade300,
            if (minValue != 0 && maxValue != 0) Colors.yellow.shade300,
            if (maxValue != 0) Colors.orange.shade300,
            if (hasCriticalHigh) Colors.red.shade300,
            Colors.red.shade300, // maxAxis
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
            color: Colors.red.shade300,
            width: 8,
            height: 8,
            pointerPosition: PointerPosition.center,
          ),
        if (minValue != 0)
          Pointer(
            value: minValue,
            shape: PointerShape.diamond,
            color: Colors.green.shade300,
            width: 8,
            height: 8,
            pointerPosition: PointerPosition.center,
          ),
        if (maxValue != 0)
          Pointer(
            value: maxValue,
            shape: PointerShape.diamond,
            color: Colors.orange.shade300,
            width: 8,
            height: 8,
            pointerPosition: PointerPosition.center,
          ),
        if (hasCriticalHigh)
          Pointer(
            value: upperCriticalValue,
            shape: PointerShape.diamond,
            color: Colors.red.shade300,
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
