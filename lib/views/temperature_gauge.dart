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
            ),
            if (sensor?.minValue != 0)
              Pointer(
                value: sensor?.minValue ?? 40,
                shape: PointerShape.diamond,
                color: Colors.green.shade300,
              ),
            if (sensor?.maxValue != 0)
              Pointer(
                value: sensor?.maxValue ?? 80,
                shape: PointerShape.diamond,
                color: Colors.orange.shade300,
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
            thickness: 5,
            linearGradient: LinearGradient(
              colors: [
                Colors.purpleAccent,
                Colors.blue,
                Colors.blueAccent,
                Colors.greenAccent,
                Colors.green,
                Colors.lightGreen,
                Color.fromARGB(148, 255, 193, 7),
                Color.fromARGB(186, 255, 153, 0),
                Color.fromARGB(255, 255, 94, 94),
                Color.fromARGB(255, 236, 75, 63),
              ],
            ),
          ),
        );
}
