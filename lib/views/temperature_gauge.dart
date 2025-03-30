import 'package:flutter/material.dart';
import 'package:open_mower_app/models/sensor_state.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

class TemperatureGauge extends LinearGauge {
  final DoubleSensorState? sensor;

  TemperatureGauge({super.key, required this.sensor})
      : super(
          start: 0,
          end: 100,
          gaugeOrientation: GaugeOrientation.horizontal,
          pointers: [
            // Actual value pointer
            Pointer(
              value: sensor?.value ?? 0,
              shape: PointerShape.triangle,
              color: Colors.black54,
              pointerPosition: PointerPosition.top,
              width: 8,
              height: 8,
            ),
            if (sensor?.minValue != 0)
              Pointer(
                value: sensor?.minValue ?? 40,
                shape: PointerShape.diamond,
                color: Color(0xFF81C784), // Colors.green[300]
                width: 8,
                height: 8,
              ),
            if (sensor?.maxValue != 0)
              Pointer(
                value: sensor?.maxValue ?? 80,
                shape: PointerShape.diamond,
                color: Color(0xFFFFB74D), // Colors.orange[300]
                width: 8,
                height: 8,
              ),
          ],
          rulers: RulerStyle(
            rulerPosition: RulerPosition.bottom,
            primaryRulerColor: Colors.grey,
            textStyle: const TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal),
          ),
          customLabels: const [
            CustomRulerLabel(text: "0", value: 0),
            CustomRulerLabel(text: "20", value: 20),
            CustomRulerLabel(text: "40", value: 40),
            CustomRulerLabel(text: "60", value: 60),
            CustomRulerLabel(text: "80", value: 80),
            CustomRulerLabel(text: "100", value: 100),
          ],
          linearGaugeBoxDecoration: const LinearGaugeBoxDecoration(
            thickness: 3,
            linearGradient: LinearGradient(
              colors: [
                Color(0xFFBA68C8), // Colors.purple[300]
                Color(0xFF42A5F5), // Colors.blue[400]
                Color(0xFF4DD0E1), // Colors.cyan[300]
                Color(0xFFB2EBF2), // Colors.cyan[100]
                Color(0xFF81C784), // Colors.green[300]
                Color(0xFFA5D6A7), // Colors.green[200]
                Color(0xFFFFF176), // Colors.yellow[300]
                Color(0xFFFFB74D), // Colors.orange[300]
                Color(0xFFEF9A9A), // Colors.red[200]
                Color(0xFFE57373), // Colors.red[300]
              ],
            ),
          ),
        );
}
